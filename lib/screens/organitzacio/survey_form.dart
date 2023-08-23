import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/screens/login.dart';
import 'package:togethertest/services/survey_service.dart';
import 'package:togethertest/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SurveyForm extends StatefulWidget {
  const SurveyForm({Key? key}) : super(key: key);

  @override
  State<SurveyForm> createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _txtControllerTitle = TextEditingController();
  final TextEditingController _txtControllerDescription =
      TextEditingController();
  List<TextEditingController> _responseControllers =
      List.generate(2, (index) => TextEditingController());
  List<File?> _selectedFiles = [];
  List<TextEditingController> _fileNameControllers = [];

  int responseCount = 2; // Inicialmente muestra 2 campos de respuesta.
  bool _loading = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate =
      DateTime.now().add(Duration(days: 7)); // Añadiendo 7 días como ejemplo.

  void _addResponseField() {
    if (responseCount < 20) {
      setState(() {
        responseCount++;
        _responseControllers.add(TextEditingController());
      });
    }
  }

  void _removeResponseField(int index) {
    if (_responseControllers.isNotEmpty &&
        index >= 0 &&
        index < _responseControllers.length) {
      setState(() {
        _responseControllers.removeAt(index);
        responseCount--;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate! : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null &&
        pickedDate != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _createSurvey() async {
    List<String> responses = _responseControllers
        .where((controller) => controller.text.isNotEmpty)
        .map((controller) => controller.text)
        .toList();

    ApiResponse response = await createSurvey(
      _txtControllerTitle.text,
      _txtControllerDescription.text,
      responses,
      _startDate,
      _endDate,
    );

    // Validación de fechas
    if (_endDate != null && _startDate!.isAfter(_endDate!)) {
      // Puedes usar un simple showDialog o SnackBar para mostrar el error.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('End date should be after start date!')));
      return; // Detener la función aquí si las fechas no son válidas.
    }

    if (response.error == null) {
      // Usar el ID de la encuesta para subir archivos
      var surveyId;
      if (response.data is Map<String, dynamic>) {
        surveyId = (response.data as Map<String, dynamic>)['survey_id'];
      }
      for (File? file in _selectedFiles) {
        if (file != null) {
          int index = _selectedFiles.indexOf(file);
          String newName = _fileNameControllers[index].text;
          await uploadFile(file, surveyId, newName);
        }
      }
      Navigator.pop(context, true);
    } else if (response.error == unauthorized) {
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('Crear nueva encuesta'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Form(
                  key: _formkey,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      children: [
                        // Card para Pregunta
                        Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: TextFormField(
                              controller: _txtControllerTitle,
                              validator: (val) =>
                                  val!.isEmpty ? 'Requiere pregunta.' : null,
                              decoration: InputDecoration(
                                hintText: "Pregunta...",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // SizedBox(height: 0),
                        // Card para Descripción
                        Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: TextFormField(
                              controller: _txtControllerDescription,
                              maxLines: 3,
                              validator: (val) =>
                                  val!.isEmpty ? 'Requiere descripción' : null,
                              decoration: InputDecoration(
                                hintText: "Descripción...",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Botón para agregar archivos
                        ElevatedButton(
                          onPressed: _pickFiles,
                          child: Text('Agregar archivo'),
                        ),
                        //SizedBox(height: 16),
                        ..._selectedFiles.asMap().entries.map((entry) {
                          int index = entry.key;
                          File? file = entry.value;
                          return Card(
                            color: Colors.green[100],
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _fileNameControllers[index],
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: file!.path.split('/').last,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedFiles.removeAt(index);
                                        _fileNameControllers.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        // Card para las fechas
                        Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                /*ListTile(
                                  title: Text(
                                      'Creada: ${_startDate.toLocal().toString().split(' ')[0]}'),
                                  trailing: Icon(Icons.calendar_today),
                                  onTap: () => _selectDate(context, true),
                                ),*/
                                ListTile(
                                  title: Text(_endDate == null
                                      ? 'End Date: Not set'
                                      : 'Finalización de encuesta: ${_endDate.toLocal().toString().split(' ')[0]}'),
                                  trailing: Icon(Icons.calendar_today),
                                  onTap: () => _selectDate(context, false),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Card para Respuestas
                        Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                for (int i = 0; i < responseCount; i++)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 12.0),
                                          child: TextFormField(
                                            controller: _responseControllers[i],
                                            validator: (val) => val!.isEmpty
                                                ? 'Response is required'
                                                : null,
                                            decoration: InputDecoration(
                                              hintText: "Respuesta ${i + 1}...",
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.black38,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (responseCount > 2) {
                                            _removeResponseField(i);
                                          }
                                        },
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Botón para agregar más respuestas
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6), // adjust as needed
                    child: ElevatedButton(
                      onPressed: _addResponseField,
                      child: Text('+ Agregar respuesta'),
                      style: ElevatedButton.styleFrom(
                        onPrimary: Colors.white,
                        onSurface: Colors.grey,
                        primary: Colors.blue,
                        minimumSize: Size(
                            0, 36), // Setting minimum size to 0 to adjust width
                        padding: EdgeInsets.symmetric(
                            horizontal: 16), // adjust padding as needed
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: purpleButton('Publicar encuesta', () {
                    setState(() {
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          _loading = !_loading;
                        });
                        _createSurvey();
                      }
                    });
                  }),
                )
              ],
            ),
    );
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
                Navigator.of(context).pop(renameController.text
                    .trim()); // Devuelve el nuevo nombre del archivo.
              },
            ),
          ],
        );
      },
    );
  }
}
