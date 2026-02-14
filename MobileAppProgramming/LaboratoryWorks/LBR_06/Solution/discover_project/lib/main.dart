import 'package:flutter/material.dart';
import 'screen/details_page.dart';
import 'screen/home_page.dart';
import 'screen/pageview_page.dart';
import 'screen/platform_demo_page.dart';
import 'screen/camera_demo_page.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        "detailsPage": (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return DetailsPage(
            title: args?["title"],
            description: args?["description"],
            image: args?["image"],
          );
        },
        "pageViewDemo": (context) => const PageViewDemoPage(),
        "platformDemo": (context) => const PlatformDemoPage(),
        "cameraDemo": (context) => const CameraDemoPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}