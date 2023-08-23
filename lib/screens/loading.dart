import 'package:flutter/material.dart';
import 'package:togethertest/constant.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/user.dart';
import 'package:togethertest/screens/organitzacio/home_organitzacio.dart';
import 'package:togethertest/screens/login.dart';
import 'package:togethertest/services/user_service.dart';

class _LoadingState extends State<Loading> {
  User? _user; // Variable para almacenar los detalles del usuario.
  // primer mirem si el token existeix al shared pref, llavors provem de cridar al getuser amb aquest token, si hi ha exit navegem al home, si no navegem al login
  void _loadUserInfo() async {
    String token = await getToken();
    //print('Token: $token');
    if (token == '') {
      //pushAndRemoveUntil: esborra la screen existent mentres la codicio retorni false (router) => false
      // tenim que esborrar la existing screen pq no volem que l'usuari torni enrere des del login
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Login()), (route) => false);
    } else {
      ApiResponse response = await getUserDetail();
      if (response.error == null) {
        setState(() {
          _user = response.data
              as User; // Asigna los detalles del usuario a la variable _user.
        });
        //print('User details: ${_user!.name}, ${_user!.email}, ${_user!.phone}');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Home()), (route) => false);
      } else if (response.error == unauthorized) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Login()), (route) => false);
      } else {
        //ScaffoldMessenger.of(context)
        // .showSnackBar(SnackBar(content: Text('${response.error}')));
        print('error al archi loading');
        print('${response.error}');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}
