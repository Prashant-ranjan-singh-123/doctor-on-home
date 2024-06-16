import 'package:appcode3/views/Doctor/loginAsDoctor.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startScreen();
  }

  startScreen() async{
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) => LoginAsDoctor(),
    ));
    //Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Profile"),
      ),
    );
  }
}
