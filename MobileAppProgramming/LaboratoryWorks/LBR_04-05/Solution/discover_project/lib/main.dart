import 'package:flutter/material.dart';
import 'screen/details_page.dart';
import 'screen/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        "detailsPage": (context) => const DetailsPage(),
      },
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}