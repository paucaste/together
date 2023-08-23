import 'package:flutter/material.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/user.dart';
import 'package:togethertest/screens/login.dart';
import 'package:togethertest/services/user_service.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetail();
  }

  _fetchUserDetail() async {
    try {
      ApiResponse apiResponse = await getUserDetail();
      if (apiResponse.error == null && apiResponse.data is User) {
        setState(() {
          user = apiResponse.data as User;
        });
      } else {
        // Handle the error if needed...
        print('Error: ${apiResponse.error}');
      }
    } catch (e) {
      print('Exception caught: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Image.asset(
          'assets/images/logo_sol.png',
          fit: BoxFit.contain,
          height: 32,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // Tuerca de configuración
            onPressed: () {
              // Acciones al clicar el icono...
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRow('Nombre:', user?.name ?? 'Desconocido'),
                          _divider(),
                          _buildRow('Email:', user?.email ?? 'Desconocido'),
                          _divider(),
                          _buildRow('Teléfono:', user?.phone ?? 'Desconocido'),
                          _divider(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Espacio entre el Card y el botón
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.red), // Botón de color rojo
                    child: Text("Cerrar sesión"),
                    onPressed: () async {
                      bool success = await logout();
                      if (success) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => Login()),
                            (route) => false);
                      } else {
                        // Manejar el error de cierre de sesión si es necesario.
                        print("Error al cerrar sesión.");
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18)),
          Text(value, style: TextStyle(fontSize: 18, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.grey,
      thickness: 1.0,
    );
  }
}
