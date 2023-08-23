import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/survey.dart';
//import 'package:togethertest/models/survey_response.dart';
import 'package:togethertest/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

/// agafar totes les enquestes creades a la bd
Future<ApiResponse> getSurveys() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(surveysURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    switch (response.statusCode) {
      case 200:
        var surveys = jsonDecode(response.body)['surveys'];
        if (surveys == null) {
          print('surveys are null');
        } else {
          apiResponse.data =
              (surveys as List).map((p) => Survey.fromJson(p)).toList();
        }
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print(e);
    apiResponse.error = serverError;
  }
  return apiResponse;
}

/// agafar totes les enquestas que he creat
Future<ApiResponse> getMySurveys() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(mySurveysURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print(response.statusCode);
    switch (response.statusCode) {
      case 200:
        var surveys = jsonDecode(response.body)['surveys'];
        if (surveys == null) {
          print('surveys are null');
        } else {
          apiResponse.data =
              (surveys as List).map((p) => Survey.fromJson(p)).toList();
        }
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print(e);
    apiResponse.error = serverError;
  }
  return apiResponse;
}

/// agafar les enquestas que pot votar el votant (x municipi)
Future<ApiResponse> getVotantSurvey() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(VotantSurveysURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    // print("Response Body::: ${response.body}");
    // print("Response Body::: ${response.statusCode}");
    switch (response.statusCode) {
      case 200:
        var surveys = jsonDecode(response.body)['surveys'];
        if (surveys == null) {
          print('surveys are null');
        } else {
          apiResponse.data =
              (surveys as List).map((p) => Survey.fromJson(p)).toList();
        }
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print(e);
    apiResponse.error = serverError;
  }
  return apiResponse;
}

/// agafar totes les enquestas inactives que he creat
Future<ApiResponse> getInactiveSurveys() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(myInactiveSurveysURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print(response.statusCode);
    switch (response.statusCode) {
      case 200:
        var surveys = jsonDecode(response.body)['surveys'];
        if (surveys == null) {
          print('surveys are null');
        } else {
          apiResponse.data =
              (surveys as List).map((p) => Survey.fromJson(p)).toList();
        }
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print(e);
    apiResponse.error = serverError;
  }
  return apiResponse;
}

Future<ApiResponse> getActiveSurveys() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(myActiveSurveysURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print(response.statusCode);
    for (int i = 0; i < response.body.length; i += 500) {
      int end =
          (i + 500 < response.body.length) ? i + 500 : response.body.length;
      print(response.body.substring(i, end));
    }

    switch (response.statusCode) {
      case 200:
        var surveys = jsonDecode(response.body)['surveys'];
        if (surveys == null) {
          print('surveys are null');
        } else {
          apiResponse.data =
              (surveys as List).map((p) => Survey.fromJson(p)).toList();
        }
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print(e);
    apiResponse.error = serverError;
  }
  return apiResponse;
}

/// create survey
Future<ApiResponse> createSurvey(String title, String description,
    List<String> responses, DateTime startDate, DateTime endDate) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(Uri.parse(surveysURL),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'responses': responses,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        }));
    //print('API response: ${response.body}'); // Imprime la respuesta de la API
    // here we send the title, description, and responses in the body
    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body);
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)[0]];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        print('Unexpected status code: ${response.statusCode}');
        print('Server response: ${response.body}');
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Exception occurred: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

/// edit survey
Future<ApiResponse> editSurvey(
    int surveyId, String title, String description) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response =
        await http.put(Uri.parse('$surveysURL/$surveyId'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'title': title,
      'description': description,
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

/// delete survey
Future<ApiResponse> deleteSurvey(int surveyId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.delete(Uri.parse('$surveysURL/$surveyId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

/// subir archivo

Future<void> uploadFile(File file, int surveyId, String newName) async {
  try {
    String token = await getToken();
    var uri = Uri.parse(UploadFileUrl);

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      })
      ..files.add(await http.MultipartFile.fromPath('file', file.path))
      ..fields['survey_id'] = surveyId.toString()
      ..fields['new_file_name'] = newName;

    var response = await request.send();
    String responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      print("Upload successful!");
    } else {
      print("Upload failed with status code: ${response.statusCode}");
      print("Server response: $responseBody");
      print("Upload failed!");
      throw Exception("Failed to upload file");
    }
  } catch (e) {
    print("An error occurred: $e");
  }
}

/// create vote
Future<ApiResponse> vote(int surveyId, int responseId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(
      Uri.parse('http://192.168.1.100:8000/api/surveys/$surveyId/votes'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'response_id': responseId,
      }),
    );
    print('API response: ${response.body}'); // Imprime la respuesta de la API

    switch (response.statusCode) {
      case 201:
        apiResponse.data = jsonDecode(response.body);
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)[0]];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      case 403:
        final errorMessage = jsonDecode(response.body)['error'];
        apiResponse.error = errorMessage;
        break;
      case 409:
        final errorMessage = jsonDecode(response.body)['error'];
        apiResponse.error = errorMessage;
        break;

      default:
        print('Unexpected status code: ${response.statusCode}');
        print('Server response: ${response.body}');
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Exception occurred: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

/// Get the vote for a survey
Future<int?> getUserVoteForSurvey(int surveyId) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String token = await getToken();
  int? userId = pref.getInt('userId');

  // Obtain the ID of the currently authenticated user
  if (userId != null) {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.100:8000/api/surveys/$surveyId/votes/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    ;
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['response_id'];
    } else if (response.statusCode == 404) {
      // The user has not voted yet
      return null;
    }
  } else {
    throw Exception('User ID is null');
  }
}
