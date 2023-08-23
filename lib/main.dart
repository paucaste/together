import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:togethertest/providers/userProvider.dart';
import 'package:togethertest/screens/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Loading(),
      ),
    );
  }
}
