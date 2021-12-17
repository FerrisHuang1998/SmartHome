import 'Account/User.dart';
import 'Account/Account.dart';
import 'home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  User user;
  await getUserInfo().then((value) => user = value);
  runApp(MyApp(user));
}

Future<User> getUserInfo() async{
  print('Get user info');
  //get preserve user information
  return User();
}

class MyApp extends StatelessWidget {
  User user;

  MyApp(this.user, {Key key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartHome',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SmartHomeMainPage(user),
      initialRoute: '/',
      routes: {
        '/home': (context) => SmartHomeMainPage(user),  //If the home property is specified, the routes table cannot include an entry for "/", since it would be redundant.
        '/account': (context) => AccountInfo(),
      }
    );
  }
}

