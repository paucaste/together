import 'package:flutter/material.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/user.dart';
import 'package:togethertest/providers/municipio_search.dart';
import 'package:togethertest/screens/organitzacio/home_organitzacio.dart';
import 'package:togethertest/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:togethertest/utils/color_utils.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool loading = false;
  int? selectedMunicipioId;
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      phoneController = TextEditingController(),
      passwordController = TextEditingController(),
      passwordConfirmController = TextEditingController(),
      municipioController = TextEditingController();
  List<String> municipios = [];

  void _registerUser() async {
    if (selectedMunicipioId == null) {
      // Mostrar un mensaje de error o una alerta indicando que el municipio es obligatorio
      return;
    }
    ApiResponse response = await register(
        nameController.text,
        emailController.text,
        phoneController.text,
        passwordController.text,
        selectedMunicipioId!);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = !loading;
      });
      //ScaffoldMessenger.of(context)
      //   .showSnackBar(SnackBar(content: Text('${response.error}')));
      print('error al archi register');
    }
  }

  // Save and redirect to home
  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Home()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formkey,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  centerTitle: true,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 32),
                    children: [
                      reusableTextFormField(
                        "Name",
                        Icons.person,
                        false,
                        nameController,
                        (val) => val!.isEmpty ? 'Invalid name' : null,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      reusableTextFormField(
                        'Email',
                        Icons.email,
                        false,
                        emailController,
                        (val) => val!.isEmpty ? 'Invalid email adress' : null,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final municipio = await showSearch(
                            context: context,
                            delegate: MunicipioSearch(
                                controller: municipioController),
                          );
                          if (municipio != null) {
                            selectedMunicipioId = municipio.id;
                            municipioController.text = municipio.nombre;
                          }
                        },
                        child: AbsorbPointer(
                          child: reusableTextFormField(
                            'Selecciona un municipio',
                            Icons.search,
                            false,
                            municipioController,
                            (val) =>
                                val!.isEmpty ? 'Municipio inválido.' : null,
                          ),
/*                    TextField(
                            controller: municipioController,
                            decoration: InputDecoration(
                              hintText: 'Selecciona un municipio',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),*/
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      reusableTextFormField(
                        'Phone',
                        Icons.phone,
                        false,
                        phoneController,
                        (val) {
                          if (val!.isEmpty) {
                            return 'Invalid phone';
                          }
                          if (val.length != 9) {
                            return 'Phone number should have exactly 9 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      reusableTextFormField(
                        'Password',
                        Icons.lock,
                        true,
                        passwordController,
                        (val) => val!.length < 6
                            ? 'Required at least 6 chars'
                            : null,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      reusableTextFormField(
                        'Password',
                        Icons.lock,
                        true,
                        passwordController,
                        (val) => val != passwordController.text
                            ? 'Confirm password does not match'
                            : null,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      loading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : SigninButton(context, 'Register', () {
                              if (formkey.currentState!.validate()) {
                                setState(() {
                                  loading = !loading;
                                  _registerUser();
                                });
                              }
                            }),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
