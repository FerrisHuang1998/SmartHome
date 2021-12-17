import 'User.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

/*
TODO: 1. Logout Google/FB user,
      2. user page obvious
      3. user image limit with resolution(50x50 or other)
*/

User _user;

class AccountInfo extends StatelessWidget{

  AccountInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _user = ModalRoute.of(context).settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('個人資料'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(_user),
        ),
      ),
      body: AccountInfoBody(),
    );
  }

}

class AccountInfoBody extends StatefulWidget{

  AccountInfoBody({Key key}) : super(key: key);

  @override
  AccountInfoBodySate createState() => AccountInfoBodySate();
}

class AccountInfoBodySate extends State<AccountInfoBody>{
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  BoxDecoration infoDecroation = BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1.0,
          offset: Offset(0, 2),
      )],
      borderRadius: BorderRadius.circular(16.0)
  );

  AccountInfoBodySate({Key key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                child: getUserImage(),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_user.getName().isEmpty ? '未登入' : _user.getName()}',
                        style: TextStyle(
                            fontSize: 24.0
                        ),
                      ),
                      Text(
                        '${_user.getId().isEmpty ? 'ID' : _user.getId()}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
          decoration: infoDecroation,
          height: screenSize.height/4,
          margin: EdgeInsets.all(20.0),
        ),
        Container(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(
                        '活動紀錄',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28.0),
                      )
                  )
                ],
              ),
              Text('')
            ],
          ),
          decoration: infoDecroation,
          margin: EdgeInsets.all(20.0),
        ),
        Column(
          children: [
            GoogleAuthButton(
                darkMode: true,
                onPressed: () async{
                  await signInWithGoogle();
                  updateUser();
                }
            ),
            FacebookAuthButton(
                onPressed: ()async{
                  await signInWithFacebook();
                  updateUser();
                }
            ),
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: userLogout
            ),
          ],
        )
      ],
    );
  }

  Widget getUserImage(){
    try{
      if(_user.getPicture().isNotEmpty){
        return Image.network(_user.getPicture());
      }
    }
    catch(error){
      print('Get user image error: $error');
    }
    return Image.asset('images/user.png');
  }

  void updateUser(){
    CollectionReference userRef = firestore.collection('Users');
    if(_user.getId() == null){
      print('找不到使用者ID');
    }
    else if(_user.getId().isEmpty){
      print('使用者ID為空');
    }
    else{
      DocumentReference userDocumentReference = firestore.collection('Users').doc(_user.getId());
      userDocumentReference.get()
      .then((documentSnapshot){
        dynamic document = documentSnapshot.data();
        if(document == null){
          print('新用戶登入');
          Map<String, dynamic> data = {
            'name': _user.getName(),
            'id': _user.getId(),
            'pic': _user.getPicture(),
            'lastLogin': FieldValue.serverTimestamp()
          };
          userDocumentReference.set(data)
          .then((value) => {})
          .catchError((error) {
            print('Add new user document with error: $error');
          });
        }
        else{
          print('更新上次登入時間');
          userDocumentReference.update({'lastLogin': FieldValue.serverTimestamp()});
        }
      })
      .catchError((error) => print('Get document with error: $error'));
    }
    setState(() {

    });
  }
  void userLogout(){
    _user.clear();
    setState(() {
      print('登出');
    });
  }

  Future<void> signInWithGoogle() async{
    try{
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      _user.set(googleUser.displayName, 'GOOGLE' + googleUser.id, googleUser.photoUrl);
    }
    catch(error){
      print('Google登入失敗: $error');
    }
  }
  Future<void> signInWithFacebook() async{
    try{
      final LoginResult loginResult = await FacebookAuth.i.login();
      if(loginResult.status == LoginStatus.success){
        final Map<String, dynamic> userData = await FacebookAuth.i.getUserData(fields: 'name, id, picture');
        _user.set(userData['name'], 'FB' + userData['id'], userData['picture']['data']['url']);
      }
    }
    catch(error){
      print('Facebook登入失敗: $error');
    }
  }
}