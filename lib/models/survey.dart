import 'package:flutter/material.dart';
import 'survey_response.dart';

class Survey {
  int id;
  int userId;
  String title;
  String description;
  List<SurveyResponse> responses;
  int votesCount;
  DateTime startDate;
  DateTime endDate;
  List<FileDetail> files;

  Survey({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.responses,
    required this.votesCount,
    required this.startDate,
    required this.endDate,
    required this.files,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    List<dynamic> responsesJson = json['responses'] ?? [];
    List<SurveyResponse> responsesList = responsesJson
        .map((responseJson) => SurveyResponse.fromJson(responseJson))
        .toList();
    DateTime startDate = DateTime.parse(json['start_date']);
    DateTime endDate = DateTime.parse(json['end_date']);
    List<dynamic> filesJson = json['files'] ?? [];
    List<FileDetail> filesList =
        filesJson.map((fileJson) => FileDetail.fromJson(fileJson)).toList();

    return Survey(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      responses: responsesList,
      votesCount: json['votes_count'] ??
          0, // Asegúrate de proporcionar un valor por defecto en caso de que 'votes_count' no esté presente
      startDate: startDate,
      endDate: endDate,
      files: filesList,
    );
  }

  @override
  String toString() {
    return 'Survey(title: $title, description: $description, files: $files)';
  }
}

class FileDetail {
  final String name;
  final String url;
  final String? type; // Puede ser nulo, así que usamos String?
  final int? size; // Puede ser nulo, así que usamos int?

  FileDetail({
    required this.name,
    required this.url,
    this.type, // No es necesario usar "required" porque puede ser nulo
    this.size,
  });

  factory FileDetail.fromJson(Map<String, dynamic> json) {
    return FileDetail(
      name: json['name'],
      url: json['path'],
      type: json['type'],
      size: json['size'] != null
          ? int.parse(json['size'].toString())
          : null, // Convertimos a int solo si no es nulo
    );
  }
}
