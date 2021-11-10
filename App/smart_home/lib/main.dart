import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Account/Account.dart';

//TODO: email login method

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  //FirebaseFirestore firestore = FirebaseFirestore.instanceFor(app: app);
  runApp(MyApp());
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

class SmartHomeMainPage extends StatelessWidget {
  SmartHomeMainPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Home"),
      ),
      body: SmartHomeMainBody(),
      drawer: SmartHomeMainDrawer(
        accountName: '',
        accountID: '',
      ),
    );
  }
}

class SmartHomeMainDrawer extends StatelessWidget{
  final String accountName, accountID;

  SmartHomeMainDrawer({Key key, this.accountName, this.accountID});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              '${accountName.isEmpty ? 'User' : accountName}',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
              ),
            ),
            accountEmail: Text(
              '${accountID.isEmpty ? '' : accountID}',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
              ),
            ),
            currentAccountPicture: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 72,
            ),
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
                    'id': '$accountID'
                  }
              );

              if(result != null){
                print('The return data is: ${result.toString()}');
                //call data changed for update user account
              }
            },
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.water),
            title: Text('濕度'),
            onTap: (){
              //跳轉到濕度頁面
            },
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.temperatureHigh),
            title: Text('溫度'),
            onTap: (){
              //跳轉到溫度頁面
            },
          )
        ],
      ),
    );
  }
}


class SmartHomeMainBody extends StatefulWidget{
  @override
  SmartHomeMainBodyState createState() => SmartHomeMainBodyState();
}
class SmartHomeMainBodyState extends State<SmartHomeMainBody>{
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
          'Wait for build',
          style: TextStyle(
              fontSize: 32.0,
              color: Colors.lightGreen
          ),
        )
    );
  }

}
