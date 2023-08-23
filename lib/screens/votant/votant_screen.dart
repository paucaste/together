import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/survey.dart';
import 'package:togethertest/screens/organitzacio/survey_form.dart';
import 'package:togethertest/services/survey_service.dart';
import 'package:togethertest/utils/formulari_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class VotantScreen extends StatefulWidget {
  const VotantScreen({Key? key}) : super(key: key);

  @override
  State<VotantScreen> createState() => _VotantScreenState();
}

class _VotantScreenState extends State<VotantScreen> {
  Map<String, int?> selectedResponses = {};
  List<Survey> surveys = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSurveys();
  }

  fetchSurveys() async {
    ApiResponse apiResponse = await getVotantSurvey();
    if (apiResponse.error == null) {
      List<Survey> newSurveys = apiResponse.data as List<Survey>;
      for (var survey in newSurveys) {
        int? userVote = await getUserVoteForSurvey(survey.id);
        if (userVote != null) {
          selectedResponses[survey.id.toString()] = userVote;
        }
      }
      print('la resposta del serv');

      print(apiResponse.data);

      setState(() {
        this.surveys = newSurveys;
        isLoading = false; // Aquí se establece isLoading a false
      });
    } else {
      // Handle error
      print('Error: ${apiResponse.error}');
      setState(() {
        isLoading =
            false; // Asegúrate de establecer isLoading a false incluso en caso de error
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

  Future<void> _handleRefresh() async {
    await fetchSurveys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Si está cargando, muestra el indicador
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: Column(
                children: [
                  // Añadido: Recuadro con el título y el botón
                  Card(
                    elevation:
                        5.0, // Esto le dará una sombra alrededor de la tarjeta.
                    margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10), // Margen en todos los lados.
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "2 encuestas disponibles para votar",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  // ListView.builder para mostrar las encuestas
                  Expanded(
                    child: ListView.builder(
                      itemCount: surveys.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5.0,
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        surveys[index].title,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),
                                Text(surveys[index].description,
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(height: 10),
                                (surveys[index].files.isNotEmpty)
                                    ? Padding(
                                        padding:
                                            EdgeInsets.only(top: 10, bottom: 2),
                                        child: Text(
                                          "Más información:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                // Si no hay archivos, simplemente no mostramos nada

                                ...surveys[index]
                                    .files
                                    .map((file) => GestureDetector(
                                          onTap: () {
                                            //_launchUrl(file.url);
                                            _launchUrl(file.url);
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                  color: Colors.blue, width: 2),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              // Para ajustar el Row al contenido
                                              children: [
                                                Icon(Icons.attach_file),
                                                SizedBox(width: 10),
                                                // Espacio entre el ícono y el texto
                                                Expanded(
                                                  child: Text(
                                                    file.name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                ...surveys[index].responses.map((response) =>
                                    Column(
                                      children: <Widget>[
                                        ListTile(
                                          title: Text(response.response),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: LinearPercentIndicator(
                                                animation: true,
                                                animationDuration: 1000,
                                                lineHeight: 24.0,
                                                percent:
                                                    response.percentage / 100,
                                                center: Text(
                                                    '${(response.percentage).toStringAsFixed(2)}%'),
                                                barRadius: Radius.circular(100),
                                                backgroundColor:
                                                    Colors.deepPurple.shade100,
                                                progressColor:
                                                    Colors.deepPurple,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                ApiResponse apiResponse =
                                                    await vote(
                                                  surveys[index].id,
                                                  response.id,
                                                );
                                                if (apiResponse.error == null) {
                                                  // The vote was successful
                                                  int? userVote =
                                                      await getUserVoteForSurvey(
                                                          surveys[index].id);
                                                  setState(() {
                                                    selectedResponses[
                                                            surveys[index]
                                                                .id
                                                                .toString()] =
                                                        response.id;
                                                  });
                                                  fetchSurveys();

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Vote registered successfully!')),
                                                  );
                                                } else {
                                                  // Handle error...
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(apiResponse
                                                                .error ??
                                                            'Unknown error')),
                                                  );
                                                }
                                              },
                                              child: Icon(
                                                selectedResponses[surveys[index]
                                                            .id
                                                            .toString()] ==
                                                        response.id
                                                    ? Icons.circle
                                                    : Icons.radio_button_off,
                                                color: selectedResponses[
                                                            surveys[index]
                                                                .id
                                                                .toString()] ==
                                                        response.id
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                SizedBox(height: 15),
                                Text(
                                  'Creada: ${surveys[index].startDate.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Fecha de finalización: ${surveys[index].endDate.toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _launchUrl(String filePath) async {
    String prova = 'http://192.168.1.100:8000/storage/';
    String finalUrl = prova + filePath;
    final Uri url = Uri.parse(finalUrl);
    print(url);

    try {
      if (!await launch(url.toString())) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
