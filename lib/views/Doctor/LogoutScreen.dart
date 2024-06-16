import 'dart:async';

import 'package:appcode3/main.dart';
import 'package:appcode3/views/HomeScreen.dart';
import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../en.dart';

class LogOutScreen extends StatefulWidget {
  @override
  _LogOutScreenState createState() => _LogOutScreenState();
}

class _LogOutScreenState extends State<LogOutScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 1), (){
      messageDialog(LOGOUT, ARE_YOU_SURE_TO_LOGOUT);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold());
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context){
          return AlertDialog(
            title: Text(s1,style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.bold,
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: GoogleFonts.poppins(
                  fontSize: 14,
                ),)
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () async{
                  try{
                    CubeChatConnection.instance.logout();
                  }catch(e){
                    ("CubeChatConnection.instance ${e.toString()}");
                  }
                  SharedPreferences.getInstance().then((pref){
                    pref.clear();
                    pref.setBool("isLoggedInAsDoctor", false);
                    pref.setBool("isLoggedIn", false);
                    // pref.setString("userId", null);
                    // pref.setString("name", null);
                    // pref.setString("phone", null);
                    // pref.setString("email", null);
                    // pref.setString("token", null);
                  });
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => TabsScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).hintColor,
                ),
                child: Text(YES,style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: BLACK,
                ),),
              ),
            ],
          );
        }
    );
  }

}
