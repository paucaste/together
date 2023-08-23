import 'package:flutter/material.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/screens/login.dart';
import 'package:togethertest/screens/profile.dart';
import 'package:togethertest/screens/organitzacio/survey_form.dart';
import 'package:togethertest/screens/organitzacio/survey_screen.dart';
import 'package:togethertest/screens/votant/votant_screen.dart';
import 'package:togethertest/services/user_service.dart';
import 'package:togethertest/models/user.dart';

class HomeVotant extends StatefulWidget {
  const HomeVotant({Key? key}) : super(key: key);

  @override
  State<HomeVotant> createState() => _HomeVotantState();
}

class _HomeVotantState extends State<HomeVotant> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: getPageForIndex(),
      bottomNavigationBar: getBottomNavigationBar(),
    );
  }

  Widget getPageForIndex() {
    switch (currentIndex) {
      case 0:
        return VotantScreen();
      case 1:
        return Profile();
      default:
        return VotantScreen();
    }
  }

  BottomNavigationBar getBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '')
      ],
      currentIndex: currentIndex,
      onTap: (val) {
        setState(() {
          currentIndex = val;
        });
      },
    );
  }
}
