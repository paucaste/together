class SurveyResponse {
  int id;
  int surveyId;
  String response;
  int votesCount;
  double percentage; // Nuevo campo para almacenar el porcentaje de votos

  SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.response,
    required this.votesCount,
    required this.percentage, // Agrega el nuevo campo al constructor
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'],
      surveyId: json['survey_id'],
      response: json['response'],
      votesCount: json['votesCount'] ?? 0,
      percentage: (json['percentage'] ?? 0.0)
          .toDouble(), // Extrae el porcentaje del JSON y conviértelo a double, usa 0.0 si no está presente
    );
  }
}
