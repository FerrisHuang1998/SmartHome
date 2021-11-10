import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

//TODO: AppBar actions login/logout method, login is complete, need to update user page

//Size size = MediaQuery.of(context).size;
Map<String, dynamic> user;

class AccountInfo extends StatelessWidget{

  AccountInfo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic argMap = ModalRoute.of(context).settings.arguments;
    user = {
      'name': argMap['name'].toString(),
      'id': argMap['id'].toString()
    };

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('個人資料'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop('Hello, ${user['name']}'),
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

  AccountInfoBodySate({Key key});

  @override
  Widget build(BuildContext context) {
    BoxDecoration infoDecroation = BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 3.0,
          offset: Offset(2, 2),
          blurRadius: 5.0
        )],
        borderRadius: BorderRadius.circular(24.0)
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: getUserImage(),
                        fit: BoxFit.fill
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(2, 2),
                        blurRadius: 5.0,
                        spreadRadius: 1.0
                    )]
                  ),
                  width: 150.0,
                  height: 150.0,
                )
              ),
              Flexible(
                flex: 6,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Text(
                          '${(user.containsKey('name') && user['name'].isNotEmpty) ? user['name'] : '未登入'}',
                          style: TextStyle(
                              fontSize: 32.0
                          ),
                        )
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(
                          'ID: ${(user.containsKey('id') && user['id'].isNotEmpty) ? user['id'] : ''}',
                          style: TextStyle(
                              fontSize: 14.0
                          ),
                        )
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(
                          '上次登入日期:\n1970/01/01 00:00:05',
                          style: TextStyle(
                              fontSize: 16.0
                          ),
                        ),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(4.0),
                )
              )
            ],
          ),
          decoration: infoDecroation,
          height: 250.0,
          width: 350,
          margin: EdgeInsets.all(20.0),
        ),
        Container(
          child: Text(
            '活動紀錄',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28.0),
          ),
          decoration: infoDecroation,
          height: 150,
          width: 350,
          margin: EdgeInsets.all(10.0),
        ),
        Column(
          children: [
            GoogleAuthButton(
              darkMode: true,
              onPressed: () async{
                user = await signInWithGoogle();
                updateUser('GOOGLE');
                setState(() {
                  if(user == null){
                    user = {};
                  }
                });
              }
            ),
            FacebookAuthButton(
              onPressed: ()async{
                user = await signInWithFacebook();
                updateUser('FB');
                setState(() {
                  if(user == null){
                    user = {};
                  }
                });
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

  ImageProvider getUserImage(){
    if(user != null && user.containsKey('pic')){
      if(user['pic'].toString().isNotEmpty){
        return NetworkImage(user['pic']);
      }
    }
    return AssetImage('images/user.png');
  }

  void updateUser(String signInMethod){
    /*print('Get user:');
    for(String key in user.keys){
      print('$key: ${user[key]}');
    }*/

    CollectionReference userRef = firestore.collection('Users');
    if(user == null){
      print('Login is cancel, please try again');
      return;
    }
    if(user['id'].isNotEmpty){
      String documentID = signInMethod + user['id'];
      userRef.doc(documentID).get().then((value){
        Map<String, Object> data = value.data() as Map<String, Object>;
        if(data != null){
          print('Update last login time...');
          data.addAll(user);
          data['lastLogin'] = FieldValue.serverTimestamp();
          userRef.doc(documentID).update(data);
        }
        else{
          print('New user is login, wait a sec...');
          data = {
            'lastLogin': FieldValue.serverTimestamp()
          };
          data.addAll(user);
          userRef.doc(documentID).set(data);
        }
      }).catchError((error) => print('Get document with error: $error'));
    }
    else{
      print('Cannot get user');
    }
  }
  Future<void> userLogout() async{
    if(user.containsKey('name')){
      print('User logout');
      user.clear();
    }
    else{
      print('No user need to log out');
    }
    setState(() {

    });
  }

  Future<Map<String, String>> signInWithGoogle() async{
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    Map<String, String> user = {
      'name': '',
      'id': '',
      'pic': '',
    };
    user['name'] = googleUser.displayName;
    user['id'] = googleUser.id;
    user['pic'] = googleUser.photoUrl;
    return user;
  }
  Future<Map<String, String>> signInWithFacebook() async{
    final FacebookAuth facebookAuth = FacebookAuth.instance;
    final LoginResult loginResult = await facebookAuth.login();
    if(loginResult.status == LoginStatus.success){
      final Map<String, dynamic> userData = await facebookAuth.getUserData(
        fields: 'name, id, picture'
      );

      Map<String, String> user = {
        'name': userData['name'],
        'id': userData['id'],
        'pic': userData['picture']['data']['url'],
      };
      return user;
    }
  }
}