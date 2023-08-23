import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:togethertest/constant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

Future<void> downloadAndOpenFile(String fileUrl, String fileName) async {
  String fullUrl = baseFileURL + fileUrl;
  print(fullUrl);
  try {
    final response = await http.get(Uri.parse(fullUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Abre el archivo descargado
      await OpenFile.open(filePath, type: "application/pdf");
    } else {
      throw 'Error al descargar el archivo';
    }
  } catch (e) {
    print(e);
  }
}

Future<String?> showRenameDialog(
    BuildContext context, String originalName) async {
  TextEditingController _renameController =
      TextEditingController(text: originalName);
  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Renombrar archivo'),
        content: TextField(
          controller: _renameController,
          decoration: InputDecoration(labelText: 'Nuevo nombre'),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          ElevatedButton(
            child: Text('Aceptar'),
            onPressed: () {
              Navigator.of(context).pop(_renameController.text);
            },
          ),
        ],
      );
    },
  );
}
