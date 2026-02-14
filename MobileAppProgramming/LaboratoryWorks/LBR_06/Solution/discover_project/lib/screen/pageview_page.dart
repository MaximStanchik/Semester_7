import 'package:flutter/material.dart';

class PageViewDemoPage extends StatelessWidget {
  const PageViewDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PageView Demo')),
      body: PageView(
        children: [
          Center(child: Text('Page 1', style: TextStyle(fontSize: 32, color: Colors.blue))),
          Center(child: Text('Page 2', style: TextStyle(fontSize: 32, color: Colors.red))),
          Center(child: Text('Page 3', style: TextStyle(fontSize: 32, color: Colors.green))),
        ],
      ),
    );
  }
}
