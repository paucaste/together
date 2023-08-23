// aqui posarem totes les api calls (login, register....)
import 'dart:convert';
import 'dart:io';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:togethertest/models/municipio.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

// creem funcio per fer login
Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(loginURL),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password});
    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)[0]];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Error: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

// creem funcio per registrar-nos
Future<ApiResponse> register(String name, String email, String phone,
    String password, int municipioId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(registerURL), headers: {
      'Accept': 'application/json'
    }, body: {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'municipio_id': municipioId.toString()
    });
    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)[0]];
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

//Funcio per agafar els detalls de l'usuari
Future<ApiResponse> getUserDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(userURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print('HTTP status: ${response.statusCode}');
    print('Server response: ${response.body}');
    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
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
    print('Exception: $e');
  }
  return apiResponse;
}

// agafar el token
Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

// agafar la id de l'usuari
Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId') ?? 0;
}

// agafar el rol de l'usuari
Future<String?> getRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userRole');
}

// Guardar el rol en SharedPreferences
Future<void> saveRole(String role) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userRole', role);
}

// logout
Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool tokenRemoved = await pref.remove('token');
  bool userIdRemoved = await pref.remove('userId');
  bool roleRemoved = await pref.remove('role');

  return tokenRemoved && userIdRemoved && roleRemoved;
}

// funcio per convertir l'arxiu de l'imatge a base64 encoded string

String? getStringImage(File? file) {
  if (file == null) return null;
  return base64Encode(file.readAsBytesSync());
}

// buscar municipis al registrar-se
Future<List<Municipio>> searchMunicipio(String query) async {
  List<Municipio> municipios = [];

  if (query.length > 1) {
    final response = await http.get(
      Uri.parse('http://192.168.1.100:8000/api/search?query=$query'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      municipios = data
          .map((item) => Municipio(
                id: item['id'] as int,
                nombre: item['nombre'] as String,
              ))
          .toList();
      print(municipios.map((m) => m.nombre).toList());
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  }

  return municipios;
}
