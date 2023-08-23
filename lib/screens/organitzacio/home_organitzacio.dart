import 'package:flutter/material.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/screens/login.dart';
import 'package:togethertest/screens/organitzacio/post_screen.dart';
import 'package:togethertest/screens/organitzacio/survey_historial.dart';
import 'package:togethertest/screens/profile.dart';
import 'package:togethertest/screens/organitzacio/survey_form.dart';
import 'package:togethertest/screens/organitzacio/survey_screen.dart';
import 'package:togethertest/screens/votant/votant_screen.dart';
import 'package:togethertest/services/user_service.dart';
import 'package:togethertest/models/user.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: _getBody(currentIndex), // Usa una función para seleccionar el body.
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: CircularNotchedRectangle(),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey, // Color del borde
                width: 1.0, // Grosor del borde
              ),
            ),
          ),
          child: BottomNavigationBar(
            selectedItemColor: Colors.black, // Color para el ícono seleccionado
            unselectedItemColor:
                Colors.grey, // Color para los íconos no seleccionados
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.poll),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.post_add),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '',
              ),
            ],
            currentIndex: currentIndex,
            onTap: (val) {
              setState(() {
                currentIndex = val;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return SurveyScreen();
      case 1:
        return SurveyHistorial();
      case 2:
        return PostScreen();
      case 3:
        return Profile();
      default:
        return Center(child: Text('No definido'));
    }
  }
}
