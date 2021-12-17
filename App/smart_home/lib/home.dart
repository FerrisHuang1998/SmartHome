import 'Account/User.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//TODO: Future builder for body page

class SmartHomeMainPage extends StatefulWidget {
  User user;

  SmartHomeMainPage(this.user, {Key key}) : super(key: key);
  SmartHomeMainPageState createState() => SmartHomeMainPageState(user);
}
class SmartHomeMainPageState extends State<SmartHomeMainPage>{
  User user;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> dataCategoriesList = [];
  Future<List<Sample>> samplesList = Future.delayed(const Duration(seconds: 3), () => []);

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

  SmartHomeMainPageState(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home'),
        actions: [
          ElevatedButton(
              onPressed: () async{
                if(user.getName().isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('尚未登入')));
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
                                  dataCategoriesList.add(newCategories);
                                  await updateDatabaseCategories();
                                  print('新增成功: $newCategories');
                                  updatePage();
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已有相同類別')));
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
      body: FutureBuilder(
        future: samplesList,
        builder: (BuildContext context, AsyncSnapshot<List<Sample>> snapshot){
          List<Widget> widgetList = [];
          switch(snapshot.connectionState){
            case ConnectionState.none:
              widgetList = [
                Center(
                  child: SizedBox(
                    width: 60.0,
                    height: 60.0,
                    child: Icon(Icons.adb),
                  ),
                ),
                Center(
                  child: Text('Samples is unload, please refresh the page')
                )
              ];
              break;
            case ConnectionState.waiting:
              widgetList = [
                Center(
                  child: CircularProgressIndicator(),
                ),
                Center(
                    child: Text('Sample is loading, please wait')
                )
              ];
              break;
            case ConnectionState.active:
              print('Waiting');
              break;
            case ConnectionState.done:
              if(snapshot.data.isEmpty){
                widgetList = [
                  Center(
                    child: SizedBox(
                      width: 60.0,
                      height: 60.0,
                      child: Icon(Icons.error),
                    ),
                  ),
                  Center(
                    child: Text('No data available'),
                  ),
                ];
              }
              else{
                widgetList = dataCategoriesList.map((category){
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
                                    category,
                                    style: categoriesTextStyle,
                                  )
                              ),
                              TextButton(
                                  onPressed: () async{
                                    dataCategoriesList.remove(category);
                                    await updateDatabaseCategories();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('項目已移除: $category')));
                                    updatePage();
                                  },
                                  child: Text(
                                    'remove',
                                    style: removeButtonTextStyle,
                                  )
                              ),  //remove event
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: snapshot.data.where((element) => element.getType() == category).map((sample){
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
                                            'value: ${sample.getValue()}',
                                            style: samplesTextStyle,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                                          child: Text(
                                            'device: ${sample.getDevice()}',
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
                        ),
                      ]
                    ),
                  );
                }).toList();
              }
              break;
          }

          return RefreshIndicator(
            onRefresh: refreshPageEvent,
            backgroundColor: Colors.white,
            color: Colors.red,
            child: ListView(
              children: widgetList,
            ),
          );
        },
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
  void updatePage(){
    setState(() {
      print('refresh page');
      samplesList = getDatabaseSamples();
    });
  }
  Future<void> refreshPageEvent() async{
    await getDatabaseCategories();
    updatePage();
    return Future.delayed(Duration(seconds: 0));
  }

  Future<void> getDatabaseCategories() async{
    if(user.getId().isNotEmpty){
      DocumentReference accountReference = firestore.collection('Users').doc(user.getId());
      await accountReference.get()
      .then((value) {
        List<dynamic> fieldSnapshot = value.get('categories') as List<dynamic>;
        fieldSnapshot.forEach((categories){
          if(!dataCategoriesList.contains(categories)){
            dataCategoriesList.add(categories.toString());
          }
        });
      })
      .catchError((error) => print('Categories is unavailable: ${error.toString()}'));
    }
  }
  Future<List<Sample>> getDatabaseSamples() async{
    List<Sample> collectionData = [];
    if(user.getId().isNotEmpty){
      CollectionReference collectionReference = firestore.collection('Users').doc(user.getId()).collection('samples');
      await collectionReference.get().then((value){
        List<QueryDocumentSnapshot<Object>> docs = value.docs ;
        if(docs.isNotEmpty) {
          docs.forEach((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            //print('Get document: $data');
            collectionData.add(Sample(
              value: data['value'],
              device: data['device'],
              type: data['type'],
              date: data['date']
            ));
          });
        }
      });
    }

    return collectionData;
  }
  Future<void> updateDatabaseCategories() async{
    if(user.getId().isNotEmpty){
      DocumentReference accountReference = firestore.collection('Users').doc(user.getId());
      await accountReference.update({'categories': dataCategoriesList})
          .then((value) => print('更新成功'))
          .catchError((error) => print('無法更新監聽類別: $error'));
    }
  }
}

class Sample{
  dynamic value;
  String device, type;
  Timestamp date;

  Sample({this.value, this.device, this.date, this.type});

  String getDevice() => device;
  String getType() => type;
  dynamic getValue() => value;
  Timestamp getDate() => date;
}