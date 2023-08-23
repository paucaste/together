import 'package:dio/dio.dart';
import 'dart:io';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/post.dart';
import 'package:togethertest/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

final Dio _dio = Dio();

Future<ApiResponse> createPost(
    String title, String body, File? imageFile) async {
  ApiResponse apiResponse = ApiResponse();
  Dio dio = Dio();

  try {
    String token = await getToken();

    FormData formData = FormData.fromMap({
      'title': title,
      'body': body,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(imageFile.path),
    });

    dio.options.headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final response = await dio.post(createPostUrl, data: formData);

    switch (response.statusCode) {
      case 200:
        apiResponse.data = response.data;
        break;
      case 201:
        apiResponse.data = response.data;
        break;
      case 422:
        final errors = response.data['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)[0]];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        print('Unexpected status code: ${response.statusCode}');
        print('Server response: ${response.data}');
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Exception occurred: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}

Future<ApiResponse> updatePost(
    int id, String title, String description, File? newImageFile) async {
  ApiResponse apiResponse = ApiResponse();

  try {
    String token = await getToken();

    var request =
        http.MultipartRequest("PUT", Uri.parse('$updatePostsURL/$id'));

    request.headers.addAll(
        {'Accept': 'application/json', 'Authorization': 'Bearer $token'});

    request.fields['title'] = title;
    request.fields['body'] = description;

    if (newImageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', newImageFile.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var responseBody = jsonDecode(responseData);

      apiResponse.data = responseBody['message'];
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      var responseData = await response.stream.bytesToString();
      var responseBody = jsonDecode(responseData);

      apiResponse.error = responseBody['message'];
    } else {
      apiResponse.error = somethingWentWrong;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }

  return apiResponse;
}

/*Future<ApiResponse> updatePost(
    int id, String newtitle, String newbody, File? newimageFile) async {
  ApiResponse apiResponse = ApiResponse();
  Dio dio = Dio();
  print('Enviando posts_service título: $newtitle');
  print('Enviando posts_service descripción: $newbody');

  try {
    String token = await getToken();

    FormData formData = FormData.fromMap({
      'title': newtitle,
      'body': newbody,
      if (newimageFile != null)
        'image': await MultipartFile.fromFile(newimageFile.path),
    });
    dio.options.headers = {
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    // Asumiendo que tu endpoint para actualizar sigue una estructura similar a: /posts/{id}
    final response = await dio.put('$updatePostsURL/$id', data: formData);
    print('Server response: ${response.data}');
    print('Server response: ${response.statusCode}');

    switch (response.statusCode) {
      case 200:
        apiResponse.data = response.data;
        break;
      case 201:
        apiResponse.data = response.data;
        break;
      case 422:
        final errors = response.data['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)[0]];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        print('Unexpected status code: ${response.statusCode}');
        print('Server response: ${response.data}');
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    print('Exception occurred: $e');
    apiResponse.error = serverError;
  }
  return apiResponse;
}*/

/// agafar tots els posts que he creat
Future<ApiResponse> getMyPosts() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(myPostsURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print(response.body);

    print(response.statusCode);
    switch (response.statusCode) {
      case 200:
        var surveys = jsonDecode(response.body);

        //var surveys = jsonDecode(response.body)['posts'];
        if (surveys == null) {
          print('posts are null');
        } else {
          apiResponse.data =
              (surveys as List).map((p) => Post.fromJson(p)).toList();
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

/// mostra un post en concret
Future<ApiResponse> getPostById(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse('$postsURL/$id'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    print(response.body);

    print(response.statusCode);
    switch (response.statusCode) {
      case 200:
        var postJson = jsonDecode(response.body);
        if (postJson == null) {
          print('post is null');
        } else {
          apiResponse.data = Post.fromJson(postJson);
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

/// delete post
Future<ApiResponse> deletePost(int postId) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.delete(Uri.parse('$postsURL/$postId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });
/*    print(postId);
    print('Unexpected status code: ${response.statusCode}');
    print('Server response: ${apiResponse.data}');*/

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

/// pujar fitxer

Future<void> uploadPostFile(File file, int postId, String newName) async {
  try {
    String token = await getToken();
    var uri = Uri.parse(uploadPostFileUrl);

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll(
          {'Accept': 'application/json', 'Authorization': 'Bearer $token'})
      ..files.add(await http.MultipartFile.fromPath('file', file.path))
      ..fields['post_id'] = postId.toString()
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

MediaType getMediaType(File file) {
  String extension = file.path.split('.').last.toLowerCase();

  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'png':
      return MediaType('image', 'png');
    case 'gif':
      return MediaType('image', 'gif');
    case 'pdf':
      return MediaType('application', 'pdf');
    // Agrega más tipos según sea necesario
    default:
      return MediaType(
          'application', 'octet-stream'); // tipo genérico para datos binarios
  }
}
