import 'dart:convert';
import 'package:appcode3/main.dart';
import 'package:appcode3/views/loginAsUser.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import '../en.dart';

class ForgetPassword extends StatefulWidget {

  String id;
  ForgetPassword(this.id);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  String email = "";
  final formKey = GlobalKey<FormState>();
  String? animationName;
  String? error;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          flexibleSpace: header(),
          leading: Container(),
          elevation: 0,
        ),
        body: body(),
      ),
    );
  }

  body(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            Image.asset(
                "assets/loginScreenImages/forgetIcon.png",
              height: 170,
              width: 170,
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  child: Text(ENTER_THE_EMAIL_ADDRESS_ASSOCIATED_WITH_YOUR_ACCOUNT,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            SizedBox(height: 40,),
            Row(
              children: [
                Expanded(
                  child: Text(WE_WILL_EMAIL_YOU_A_LINK_TO_RESET_YOUR_PASSWORD,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            SizedBox(height: 20,),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  validator: (val){
                    if(val!.isEmpty){
                      return EMAIL_ADDRESS;
                    }else if(!EmailValidator.validate(val)){
                      return THIS_FIELD_IS_REQUIRED;
                    }
                    return null;
                  },
                  onSaved: (val) => email = val!,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.all(5),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5
                      )
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5
                      )
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5
                      )
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 0.5
                      )
                    ),
                  ),
                  onChanged: (val){
                    setState(() {
                      email = val;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 40,),
            button()
          ],
        ),
      ),
    );
  }

  Widget header(){
    return Stack(
      children: [
        Image.asset("assets/moreScreenImages/header_bg.png",
          height: 60,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          height: 60,
          child: Row(
            children: [
              SizedBox(width: 15,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                FORGET_PASSWORD,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: WHITE,
                    fontSize: 22
                ),
              )
            ],
          ),
        ),
      ],
    );
  }


  Widget button(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 50,
        margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
        //width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: (){
            //print(date);
            if(formKey.currentState!.validate()){
              formKey.currentState!.save();
              sendEmail();
            }
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset("assets/moreScreenImages/header_bg.png",
                  height: 50,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Center(
                child: Text(
                  SUBMIT,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: WHITE,
                      fontSize: 18
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  sendEmail() async{
    processingDialog(PLEASE_WAIT_WHILE_PROCESSING);
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/forgotpassword?type=${widget.id}&email=$email"))
    .catchError((e){
      Navigator.pop(context);
      messageDialog(ERROR, e.toString(),0);
      print("e $e");
    });
    print(response.request);
    print(response.body);
    final jsonResponse = jsonDecode(response.body);
    if(response.statusCode == 200 && jsonResponse['success'] == 1){
      print("if");
      Navigator.pop(context);
      messageDialog(SUCCESSFUL, jsonResponse['msg'],1);
    }else{
      print("else");
      Navigator.pop(context);
      messageDialog(SUCCESSFUL, jsonResponse['msg'],0);
    }
  }

  processingDialog(message){
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(LOADING),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Text(message,style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 14),),
                )
              ],
            ),
          );
        }
    );
  }

  messageDialog(String s1, String s2, int i){
    return showDialog(
        context: context,
        barrierDismissible: false,
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
              TextButton(
                onPressed: () async{
                  // Navigator.pop(context);
                  if(i==1 && widget.id == "1"){
                    // Navigator.pushReplacement(context,
                    //     MaterialPageRoute(builder: (context) => LoginAsUser()
                    //     )
                    // );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                  else if(i==1 && widget.id == "2"){
                    // Navigator.pushReplacement(context,
                    //     MaterialPageRoute(builder: (context) => LoginAsUser()
                    //     )
                    // );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                  else{
                    Navigator.pop(context);

                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                // color: Theme.of(context).primaryColor,
                child: Text(OK,style: GoogleFonts.poppins(
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
