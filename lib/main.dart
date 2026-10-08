import 'package:flutter/material.dart';
import 'core/core_state.dart';

import 'presentation/pages/homepage.dart';
import 'presentation/pages/createtask.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePageState(),
      routes: {
        "/home": (context) => HomePageState(),
        "/create":(context) => CreateTaskState()

      },

      title: 'TaskTrack',
      
      
    );
  }
}

