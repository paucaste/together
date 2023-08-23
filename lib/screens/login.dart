import 'package:flutter/material.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/user.dart';
import 'package:togethertest/screens/organitzacio/home_organitzacio.dart';
import 'package:togethertest/screens/register.dart';
import 'package:togethertest/screens/votant/home_votant.dart';
import 'package:togethertest/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:togethertest/utils/color_utils.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      // ScaffoldMessenger.of(context)
      //  .showSnackBar(SnackBar(content: Text('${response.error}')));
      print('${response.error}');
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    await saveRole(user.role ?? 'votant');

    if (user.role == "organitzacio") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Home()), (route) => false);
    } else if (user.role == "votant") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeVotant()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.05, 20, 0),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  logoWidget(
                      "assets/images/logo_nom.png"), // Add this if you have the logo
                  const SizedBox(
                    height: 10,
                  ),
                  reusableTextFormField(
                    "Enter Email",
                    Icons.email_outlined,
                    false,
                    txtEmail,
                    (val) => val!.isEmpty ? 'Invalid email adress' : null,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextFormField(
                    "Enter Password",
                    Icons.lock_outline,
                    true,
                    txtPassword,
                    (val) =>
                        val!.length < 6 ? 'Required at least 6 chars' : null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  loading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : SigninButton(context, 'Login', () {
                          if (formkey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            _loginUser();
                          }
                        }),
                  const SizedBox(
                    height: 10,
                  ),
                  signUpOption()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Using the same signupOption widget from the SignInScreen
  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Register()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
