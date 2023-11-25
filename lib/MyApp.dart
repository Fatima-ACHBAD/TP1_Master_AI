import 'package:flutter/material.dart';
import 'package:tp1_master_ai/screens/ActivitiesPage.dart';

import 'screens/Login.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity',
    theme: ThemeData(
    primarySwatch: Colors.cyan,
    ),
    //  home: const Login(),
    home: const ActivitiesPage(),

    debugShowCheckedModeBanner: false,
    );
  }
}
