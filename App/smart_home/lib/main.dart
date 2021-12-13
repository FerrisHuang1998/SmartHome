import 'Account/User.dart';
import 'Account/Account.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

User user = User();

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
  List<String> dataCategoriesList = <String>[];
  Map<String, List<Map<String, dynamic>>> datasets = {};

  TextStyle categoriesTextStyle = TextStyle(
      color: Colors.lightBlue,
      fontSize: 16.0
  );
  TextStyle removeButtonTextStyle = TextStyle(
      color: Colors.grey[400],
      fontSize: 13.0,
      fontStyle: FontStyle.italic
  );
  TextStyle samplesTextStyle = TextStyle(
    color: Colors.grey[400],
    fontSize: 14.0
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home'),
        actions: [
          ElevatedButton(
            onPressed: () async{
              if(user.getName().isEmpty){
                print('尚未登入');
              }
              else{
                String newCategories;
                await showDialog(
                  context: context,
                  builder: (builder){
                    return AlertDialog(
                      title: Text('新增監聽類別'),
                      content: TextField(
                        autofocus: true,
                        onChanged: (value) => newCategories = value,
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(builder).pop(),
                          onLongPress: (){},
                          child: Text('取消'),
                        ),
                        TextButton(
                          onPressed: () async{
                            if(!dataCategoriesList.contains(newCategories)){
                              dataCategoriesList.add(newCategories);  //如果新增同樣的數據會疊加而不是
                              await updateDatabaseCategories(user.getId());
                              setState(() {
                                print('新增成功: $newCategories');
                              });
                            }
                            else{
                              print('已有相同類別於列表中: ${dataCategoriesList.indexOf(newCategories)}');
                            }

                            Navigator.of(builder).pop();
                          },
                          onLongPress: (){},
                          child: Text('送出'),
                        )
                      ],
                    );
                  }
                );
              }
            },
            child: Icon(Icons.add)
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshPageEvent,
        backgroundColor: Colors.white,
        color: Colors.red,
        child: ListView(
          children: dataCategoriesList.map((element){
            return Container(
              margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0)
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200],
                          width: 0.8,
                        )
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                              element,
                              style: categoriesTextStyle,
                            )
                        ),
                        TextButton(
                          onPressed: () async{
                            dataCategoriesList.remove(element);
                            datasets.remove(element);
                            await updateDatabaseCategories(user.getId());
                            setState(() {
                              print('項目已移除: $element');
                            });
                          },
                          child: Text(
                            'remove',
                            style: removeButtonTextStyle,
                          )
                        )
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: getSamples(element).map((sample){
                      return Container(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(3, 1, 3, 1),
                                    child: Text(
                                      'value: ${sample['value']}',
                                      style: samplesTextStyle,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                                    child: Text(
                                      'device: ${sample['device']}',
                                      style: samplesTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 5,
                              child: Container(
                                child: Text(
                                  'date: 2020-12-12 00:00:00',
                                  style: samplesTextStyle,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ]
              ),
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
                '${user.getName().isEmpty ? '未登入' : user.getName()}',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                ),
              ),
              accountEmail: Text(
                '${user.getId().isEmpty ? '' : user.getId()}',
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
                try{
                  User result = await Navigator.of(context).pushNamed(
                      '/account',
                      arguments: user
                  ) as User;
                }
                catch(e) {
                  print('Return result exception: ' + e.toString());
                }
                setState(() {
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getUserImage(){
    if(user.getPicture().isEmpty){
      return Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 72,
      );
    }
    else{
      return Image.network(user.getPicture());
    }
  }
  List<Map<String, dynamic>> getSamples(String key){
    if(datasets.containsKey(key)){
      return datasets[key];
    }
    else{
      return [];
    }
  }
  Future<void> refreshPageEvent() async{
    await getDatabaseCategories(user.getId());
    await Future.forEach(dataCategoriesList, (element) async{
      await getDatabaseSamples(user.getId(), element);
    });
    setState(() {
      print('刷新頁面');
    });
    return Future.delayed(Duration(seconds: 0));
  }

  Future<void> getDatabaseCategories(String userId) async{
    try{
      if(user.getId().isNotEmpty){
        DocumentReference accountReference = firestore.collection('Users').doc(userId);
        await accountReference.get().then((value) {
          List<dynamic> fieldSnapshot = value.get('categories') as List<dynamic>;
          fieldSnapshot.forEach((categories){
            //print('Find categories: $categories');
            if(!dataCategoriesList.contains(categories.toString())) {
              dataCategoriesList.add(categories.toString());
            }
          });
        });
      }
      else{
        dataCategoriesList.clear();
      }
    }
    catch(error){
      print('無法取得用戶監聽數據類別: $error');
    }
  }
  Future<void> getDatabaseSamples(String userId, String key) async{
    try{
      CollectionReference collectionReference = firestore.collection('Users').doc(userId).collection(key);
      await collectionReference.get().then((value){
        List<QueryDocumentSnapshot<Object>> docs = value.docs;
        if(docs.isEmpty) {
          //print('Collection is null');
          return;
        }
        List<Map<String, dynamic>> collectionData = [];

        docs.forEach((document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          //print('Get document: $data');
          collectionData.add(data);
        });

        datasets[key] = collectionData;
      });
    }
    catch(exception){
      print('Get stream data error: $key, error: $exception');
    }
  }
  Future<void> updateDatabaseCategories(String userId) async{
    DocumentReference accountReference = firestore.collection('Users').doc(userId);
    await accountReference.update({'categories': dataCategoriesList})
    .then((value) => print('更新成功'))
    .catchError((error) => print('無法更新監聽類別: $error'));
  }
}