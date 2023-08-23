import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/screens/login.dart';
import 'package:togethertest/services/posts_service.dart';
import 'package:togethertest/services/user_service.dart';
import 'package:togethertest/utils/formulari_utils.dart';

class EditPostScreen extends StatefulWidget {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;

  EditPostScreen({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  List<File> _selectedFiles = [];
  List<TextEditingController> _fileNameControllers = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.title;
    _descriptionController.text = widget.description;
  }

  Future<void> _updatePost() async {
    print('Enviando título: ${_titleController.text}');
    print('Enviando descripción: ${_descriptionController.text}');

    ApiResponse postResponse = await updatePost(
      widget.id, // Pasar la ID del post
      _titleController.text,
      _descriptionController.text,
      _image,
    );

    if (postResponse.error == null) {
      print("Datos del post después de la actualización:");
      print(postResponse.data);

      // Obtener el post nuevamente
      ApiResponse newPostResponse = await getPostById(widget
          .id); // Asume que tienes un método así. Si no es el caso, deberías crearlo.
      print("Datos obtenidos después de pedir nuevamente el post:");
      print(newPostResponse.data);
      var postId;

      if (postResponse.data is Map<String, dynamic> &&
          postResponse.data != null) {
        var dataMap = postResponse.data as Map<String, dynamic>;
        // Verificamos que contenga la llave 'post' y que sea un mapa
        if (dataMap.containsKey('post') &&
            dataMap['post'] is Map<String, dynamic>) {
          var postData = dataMap['post'] as Map<String, dynamic>;
          // Ahora, verificamos si contiene la llave 'id'
          if (postData.containsKey('id')) {
            postId = postData['id'];
          }
        }
      }

      if (postId != null) {
        for (File? file in _selectedFiles) {
          if (file != null) {
            int index = _selectedFiles.indexOf(file);
            String newName = _fileNameControllers[index].text;
            await uploadPostFile(file, postId, newName);
          }
        }
      } else {
        print('Error: No se pudo obtener la ID del post.');
      }

      Navigator.pop(context, true);
    } else if (postResponse.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      print('error al archi survey_form');
      setState(() {
        _loading = !_loading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue =
        16.0; // Este es el valor que usaste en el Padding alrededor de tus widgets.
    double buttonWidth = screenWidth -
        (2 *
            paddingValue); // Ancho del botón basado en el ancho de la pantalla menos el padding.

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Editar Post'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            children: [
              if (_image != null) Image.file(_image!),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Elegir Imagen'),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Título',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Descripción...',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Seleccionar Archivos para el Post'),
                onPressed: _pickFiles,
              ),
              SizedBox(height: 16),
              ListView.builder(
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_fileNameControllers[index]
                      .text), // Mostrar el nombre del archivo.
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                  ),
                ),
                shrinkWrap:
                    true, // Para que no ocupe todo el espacio disponible.
                physics:
                    NeverScrollableScrollPhysics(), // Desactiva el desplazamiento ya que está dentro de un SingleChildScrollView.
              ),
              SizedBox(height: 16),
              Container(
                width: buttonWidth,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.deepPurple), // Cambia el color de fondo aquí
                  ),
                  onPressed: _updatePost,
                  child: Text('Actualizar post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFiles() async {
    if (_selectedFiles.length < 3) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        String? newName = await _showRenameDialog(file.path
            .split('/')
            .last); // Mostrar el cuadro de diálogo para renombrar.

        if (newName != null && newName.isNotEmpty) {
          setState(() {
            _selectedFiles.add(file);
            _fileNameControllers.add(TextEditingController(text: newName));
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ya has seleccionado 3 archivos!')));
    }
  }

  Future<String?> _showRenameDialog(String oldName) async {
    TextEditingController renameController =
        TextEditingController(text: oldName);
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Renombrar archivo'),
          content: TextField(
            autofocus: true,
            controller: renameController,
            decoration: InputDecoration(hintText: "Nuevo nombre del archivo"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context)
                    .pop(null); // Devuelve null cuando se cancela.
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                String newName = renameController.text.trim();

                // Verifica si el nuevo nombre tiene la extensión .pdf al final.
                // Si no, añádela.
                if (!newName.toLowerCase().endsWith('.pdf')) {
                  newName += '.pdf';
                }

                Navigator.of(context)
                    .pop(newName); // Devuelve el nuevo nombre del archivo.
              },
            ),
          ],
        );
      },
    );
  }
}
