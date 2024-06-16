import 'dart:async';
import 'dart:convert';

import 'package:appcode3/main.dart';
import 'package:appcode3/views/Doctor/DoctorTabScreen.dart';
import 'package:appcode3/views/HomeScreen.dart';
import 'package:appcode3/views/loginAsUser.dart';
import 'package:connectycube_sdk/connectycube_calls.dart';
import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../VideoCall/utils/pref_util.dart';
import 'Doctor/DoctorAppointmentDetails.dart';
import 'UserAppointmentDetails.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isTokenAvailable = false;
  String? token;
  // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  getToken() async{
    SharedPreferences.getInstance().then((pref){
      getCC();
      if(pref.getBool("isTokenExist") ?? false){
        Timer(Duration(seconds: 2), (){

          if(pref.getBool("isLoggedInAsDoctor") ?? false) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DoctorTabsScreen())
            );
          }
          else if(pref.getBool("isLoggedIn") ?? false) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TabsScreen())
            );
          }
          else{
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TabsScreen())
            );
          }

        });
      }else{
        print("value is null");
        Timer(Duration(seconds: 2),(){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TabsScreen())
          );
        });
      }
    });

  }


  getCC(){
    SharedPrefs.getUser().then((value){
      print('${value!.fullName}');
      print('${value.login}');
      print('${value.password}');
      print('${value.id}');
      if(value.id !=null){
        _loginToCC(context,value);
      }
    });
  }

  _loginToCC(BuildContext context, CubeUser user) async {

    if (CubeSessionManager.instance.isActiveSessionValid() &&
        CubeSessionManager.instance.activeSession!.user != null) {
      if (CubeChatConnection.instance.isAuthenticated()) {
        print('---------> go to opponents screen');
      } else {
        print('---------> something wrong open login cube cc');
        _loginToCubeChat(context, user);
      }
    } else {
      createSession(user).then((cubeSession) {
        print('---------> create session create suceessfully');
        _loginToCubeChat(context, user);
      }).catchError((exception) {
        print(exception);
        // _processLoginError(exception);
      });
    }
  }

  void _loginToCubeChat(BuildContext context, CubeUser user) {
    CubeChatConnection.instance.login(user).then((cubeUser) async {
      SharedPrefs.saveNewUser(user);
      print('----------> go to opponents screen');
    }).catchError((exception) {
      print(exception);
      // _processLoginError(exception);
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
  }

  storeToken() async{
    final response = await post(
        Uri.parse("$SERVER_ADDRESS/api/savetoken"),
        body: {
          "token":token,
          "type": "1",
        }
    ).catchError((e){
      Timer(Duration(seconds: 2),(){
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => TabsScreen())
        );
      });
    });
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'] == "1"){
        Timer(Duration(seconds: 2), (){
          SharedPreferences.getInstance().then((pref){
            pref.setBool("isTokenExist", true);
            print("token stored");
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TabsScreen())
            );
          });
        });
      }
    }
    else{
      print("token not stored");
      Timer(Duration(seconds: 2),(){
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => TabsScreen())
        );
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor('#f0f9ff'),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: HexColor('#f0f9ff'),
          child: Image.asset('assets/slab_screen.jpeg', fit: BoxFit.contain,),
        )
    );
  }

}


// FirebaseMessaging().getToken().then((value){
//   //Toast.show(value, context, duration: 2);
//   print(value);
//   setState(() {
//     token = value;
//   });
//
// }).catchError((e){
//   print("token not generated "+ e.toString());
//   Timer(Duration(seconds: 2),(){
//     Navigator.pushReplacement(context,
//         MaterialPageRoute(builder: (context) => TabsScreen())
//     );
//   });
// });
