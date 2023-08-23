import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/survey.dart';
import 'package:togethertest/screens/organitzacio/survey_screen.dart';

class SurveyDetailsScreen extends StatelessWidget {
  final Survey survey;

  SurveyDetailsScreen({required this.survey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(survey.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(survey.description, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Total votos: ${survey.votesCount}',
                style: TextStyle(fontSize: 18, color: Colors.red)),
            SizedBox(height: 10),
            ...survey.responses.map((response) => Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(response.response),
                    ),
                    LinearPercentIndicator(
                      animation: true,
                      animationDuration: 1000,
                      lineHeight: 24.0,
                      percent: response.percentage / 100,
                      center:
                          Text('${(response.percentage).toStringAsFixed(2)}%'),
                      barRadius: Radius.circular(100),
                      backgroundColor: Colors.deepPurple.shade100,
                      progressColor: Colors.deepPurple,
                    ),
                    SizedBox(height: 5),
                  ],
                )),
            SizedBox(height: 15),
            Text(
              'Creada: ${survey.startDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Fecha de finalización: ${survey.endDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
