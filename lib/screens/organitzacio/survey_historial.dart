import 'package:flutter/material.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/survey.dart';
import 'package:togethertest/services/survey_service.dart';
import 'package:togethertest/screens/organitzacio/survey_details_screen.dart';

class SurveyHistorial extends StatefulWidget {
  const SurveyHistorial({Key? key}) : super(key: key);

  @override
  State<SurveyHistorial> createState() => _SurveyHistorialState();
}

class _SurveyHistorialState extends State<SurveyHistorial> {
  Map<String, int?> selectedResponses = {};
  List<Survey> surveys = [];
  bool isLoading = true; // Añadimos el estado para saber si está cargando

  @override
  void initState() {
    super.initState();
    fetchInactiveSurveys();
  }

  fetchInactiveSurveys() async {
    ApiResponse apiResponse = await getInactiveSurveys();
    if (apiResponse.error == null) {
      List<Survey> newSurveys = apiResponse.data as List<Survey>;
      for (var survey in newSurveys) {
        int? userVote = await getUserVoteForSurvey(survey.id);

        if (userVote != null) {
          selectedResponses[survey.id.toString()] = userVote;
        }
      }
      setState(() {
        this.surveys = newSurveys;
        this.isLoading = false; // Actualizamos el estado de cargando a falso
      });
    } else {
      // Handle error
      print('Error: ${apiResponse.error}');
      setState(() {
        this.isLoading =
            false; // Asegurarse de establecer isLoading en false incluso si hay un error
      });
    }
  }

  double getVotePercentage(int voteCount, int totalVotes) {
    if (totalVotes == 0) {
      return 0;
    } else {
      return voteCount / totalVotes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // ListView.builder para mostrar las encuestas
          Expanded(
            child: isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(), // Mostrar el indicador de carga si isLoading es true
                  )
                : surveys.isEmpty
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "Actualmente no tienes ninguna encuesta terminada",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: surveys.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SurveyDetailsScreen(
                                      survey: surveys[index]),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.all(10),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            surveys[index].title.length > 100
                                                ? surveys[index]
                                                        .title
                                                        .substring(0, 100) +
                                                    '...'
                                                : surveys[index].title,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Creada: ${surveys[index].startDate.toLocal().toString().split(' ')[0]}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Fecha de finalización: ${surveys[index].endDate.toLocal().toString().split(' ')[0]}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios,
                                        color: Colors.blueGrey),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
