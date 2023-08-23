import 'package:flutter/material.dart';
import 'package:togethertest/models/post.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:togethertest/services/posts_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetails extends StatefulWidget {
  final int postId;

  const PostDetails({required this.postId, Key? key}) : super(key: key);

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final String baseURL = "http://192.168.1.100:8000";
  bool isLoading = true;
  bool isImageLoading = true;
  Post? post;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      final apiResponse =
          await getPostById(widget.postId).timeout(Duration(seconds: 10));

      // Primero, verificamos que la respuesta contenga datos.
      if (apiResponse.data != null) {
        setState(() {
          post = apiResponse.data as Post;
          isLoading = false;
        });

        // Si hay una imagen asociada al post, intentamos precargarla.
        if (post!.imageUrl != null && post!.imageUrl!.isNotEmpty) {
          await precacheImage(
            NetworkImage('$baseURL/storage/${post!.imageUrl}'),
            context,
          ).then((_) {
            setState(() {
              isImageLoading = false;
            });
          }).catchError((error) {
            print("Error precargando la imagen: $error");
            setState(() {
              isImageLoading =
                  false; // Aun si hay un error, ya no estamos cargando.
            });
          });
        } else {
          setState(() {
            isImageLoading =
                false; // Si no hay imagen, establecemos isImageLoading a false directamente.
          });
        }
      } else {
        print("Error obteniendo el post: ${apiResponse.error}");
      }
    } on TimeoutException catch (e) {
      print("Tiempo de espera excedido: $e");
    } catch (e) {
      print("Error general al cargar el post: $e");
    }
  }

  Future<void> _launchUrl(String filePath) async {
    String urlBase = 'http://192.168.1.100:8000/storage/';
    String finalUrl = urlBase + filePath;
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

  @override
  Widget build(BuildContext context) {
    if (isLoading || isImageLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Detalles del Post'),
      ),
      body: Card(
        margin: EdgeInsets.only(top: 16.0, bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ListView(
          children: [
            if (post!.imageUrl != null && post!.imageUrl!.isNotEmpty)
              Image.network('$baseURL/storage/${post!.imageUrl}'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(post!.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(post!.body, style: TextStyle(fontSize: 18)),
            ),
            ...post!.files?.map((file) {
                  return ListTile(
                    title: Text(file.name),
                    leading: Icon(Icons.attach_file),
                    onTap: () {
                      _launchUrl(file.url);
                    },
                  );
                })?.toList() ??
                [],
          ],
        ),
      ),
    );
  }
}
