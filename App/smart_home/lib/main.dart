import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Account/Account.dart';

/*TODO:
  Drawer: Only manage account information
*/

String accountName = '', accountID = '', accountPic = '';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  await getUserInfo();
  runApp(MyApp());
}

Future<void> getUserInfo() async{
  print('Get user info');
  //get preserve user information
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SmartHome',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: SmartHomeMainPage(),
        initialRoute: '/',
        routes: {
          '/home': (context) => SmartHomeMainPage(),  //If the home property is specified, the routes table cannot include an entry for "/", since it would be redundant.
          '/account': (context) => AccountInfo(),
          '/temp': (context) => SmartHomeMainPage(),
        }
    );
  }
}

class SmartHomeMainPage extends StatefulWidget {
  SmartHomeMainPage({Key key}) : super(key: key);
  SmartHomeMainPageState createState() => SmartHomeMainPageState();
}
class SmartHomeMainPageState extends State<SmartHomeMainPage>{
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String content = 'Wait for build';
  List<String> dataCategoriesList = <String>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshStreamData,
        backgroundColor: Colors.white,
        color: Colors.red,
        child: ListView(
          children: dataCategoriesList.map((element){
            return ListTile(
              title: Text(element),
              onTap: () => getStreamData(element),
            );
          }).toList(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                '${(accountName.isEmpty || accountName == null) ? '未登入' : accountName}',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                ),
              ),
              accountEmail: Text(
                '${(accountID.isEmpty || accountID == null) ? '' : accountID}',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                ),
              ),
              currentAccountPicture: getUserImage(),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text("帳戶"),
              onTap: () async{
                dynamic result = await Navigator.of(context).pushNamed(
                    '/account',
                    arguments: {
                      'name': '$accountName',
                      'id': '$accountID',
                      'pic': '$accountPic'
                    }
                );

                if(result != null){
                  print('The return data is: ${result.toString()}');
                  try{
                    setState(() {
                      accountName = result['name'].toString();
                      accountID = result['id'].toString();
                      accountPic = result['pic'].toString();
                    });
                  }
                  catch(e) {
                    print('Return result exception: ' + e.toString());
                  }
                  //call data changed for update user account
                }
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.water),
              title: Text('新增'),
              onTap: () async{
                if(accountName != null && accountName.isNotEmpty){
                  await addNewDataCategories();
                  setState(() {
                    print('新增成功');
                    //change bottom navigation bar
                  });
                }
                else{
                  //尚未登入event
                }
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.temperatureHigh),
              title: Text('移除'),
              onTap: () async{
                await removeDataCategories();
                print('移除成功');
              },
            )
          ],
        ),
      ),
    );
  }

  Widget getUserImage(){
    if(user != null && user.containsKey('pic')){
      if(accountPic.toString().isNotEmpty){
        return Image.network(accountPic);
      }
    }
    return Icon(
      Icons.account_circle,
      color: Colors.white,
      size: 72,
    );
  }

  Future<void> getDataCategories() async{
    if(accountID != null && accountID.isNotEmpty){
      DocumentReference account = firestore.collection('Users').doc('GOOGLE$accountID');
      await account.get().then((value) {
        Map<String, dynamic> categoriesMap = value.get('dataCategories');
        categoriesMap.forEach((key, value) {
          print('Find categories: $key, value: $value');
          if(!dataCategoriesList.contains(value.toString())) {
            dataCategoriesList.add(value.toString());
          }
        });
      });
    }
    else{
      dataCategoriesList.clear();
    }
  }
  Future<void> refreshStreamData() async{
    await getDataCategories();
    setState(() {

    });
    return Future.delayed(Duration(seconds: 0));
  }
  Future<void> getStreamData(String key) async{
    try{
      CollectionReference collectionReference = firestore.collection('Users').doc('GOOGLE$accountID').collection(key);
      await collectionReference.get().then((value){
        List<QueryDocumentSnapshot<Object>> docs = value.docs;
        if(docs.isEmpty) {
          print('Collection is null');
          return;
        }
        var amount = 0, total = 0.0;

        docs.forEach((document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          print('Get document: $data');
          if(data['value'] != null){
            amount++;
            total += data['value'];
          }
        });

        print('The total data samples is $amount, and the avegrage value is: ${total/amount}');
      });
    }
    catch(exception){
      print('Get stream data error: $key, error: $exception');
    }
  }
  Future<void> addNewDataCategories(){
    //顯示新增監聽數據對話窗
  }
  Future<void> removeDataCategories(){
    //跳轉到溫度頁面
  }
}
