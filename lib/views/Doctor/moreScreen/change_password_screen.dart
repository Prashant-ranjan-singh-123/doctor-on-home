import 'dart:convert';
import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  String? docId;
  final _formKey = GlobalKey<FormState>();
  String oldpwd = "";
  String newpwd = "";
  String confpwd = "";
  bool isErrorInLoading = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        docId = pref.getString("userId") ?? "";
        print("doc Id=====>>>${docId}");
      });
    });
    super.initState();
  }

  ChangePassword() async {
    isErrorInLoading = true;
    print('change password url ------------------------------> ${Uri.parse("$SERVER_ADDRESS/api/change_password_doctor")}');
    var request = http.MultipartRequest('POST', Uri.parse("$SERVER_ADDRESS/api/change_password_doctor"));
    request.fields.addAll({
      'doctor_id': docId.toString(),
      'old_password': oldpassword.text,
      'new_password': newpassword.text,
      'conf_password': confirmpassword.text
    });
    var streamResp = await request.send();
    var response = await http.Response.fromStream(streamResp);

    if (response.statusCode == 200) {
      var resp = json.decode(response.body);
      setState(() {
        isErrorInLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp['msg'],textAlign: TextAlign.center)));
      });
      Navigator.pop(context);
      print("resp is===>>>${resp['msg']}");
    }
    else {
      setState(() {
        isErrorInLoading = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.reasonPhrase.toString(),textAlign: TextAlign.center)));
      print(response.reasonPhrase);
    }

  }

  bool _passwordVisible = true;
  bool _passwordVisible1 = true;
  bool _passwordVisible2 = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: header(),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                  child: Column(
                children: [
                  TextFormField(
                    controller: oldpassword,
                    obscureText: _passwordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      // hintText: "Old Password",
                      labelText: OLD_PASSWORD,
                      labelStyle: GoogleFonts.poppins(
                          color: LIGHT_GREY_TEXT,
                          fontWeight: FontWeight.w400
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: LIGHT_GREY_TEXT,)
                      ),

                      // focusedBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                      // enabledBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                      // errorBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                    ),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500
                    ),
                    validator: (value){
                      setState(() {
                        oldpwd = value!;
                      });
                      if(oldpwd.isEmpty){
                        return 'Please Enter Old Password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: newpassword,
                    obscureText: _passwordVisible1,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      // hintText: "New Password",
                      labelText: NEW_PASSWORD,
                      labelStyle: GoogleFonts.poppins(
                          color: LIGHT_GREY_TEXT,
                          fontWeight: FontWeight.w400
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: LIGHT_GREY_TEXT,)
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible1
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible1 = !_passwordVisible1;
                          });
                        },
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                      // enabledBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                      // errorBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                    ),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500
                    ),
                    validator: (value){
                      setState(() {
                        newpwd = value!;
                      });
                      if(newpwd.isEmpty){
                        return 'Please Enter New Password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: confirmpassword,
                    obscureText: _passwordVisible2,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      // hintText: "Confirm Password",
                      labelText: CONFIRM_PASSWORD,
                      labelStyle: GoogleFonts.poppins(
                          color: LIGHT_GREY_TEXT,
                          fontWeight: FontWeight.w400
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: LIGHT_GREY_TEXT,)
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          _passwordVisible2
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            _passwordVisible2 = !_passwordVisible2;
                          });
                        },
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                      // enabledBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                      // errorBorder: OutlineInputBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //     borderSide: BorderSide(color: Colors.grey)),
                    ),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500
                    ),
                    validator: (value){
                      setState(() {
                        confpwd = value!;
                      });
                      if(newpwd != confpwd){
                        return 'Password Not Matched!';
                      }
                      return null;
                    },
                  ),
                ],
              )),
              SizedBox(height: 70,),
              // Expanded(child: Container()),
              Container(
                height: 50,
                //width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: (){
                   if(_formKey.currentState!.validate()){
                     ChangePassword();
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
                        child: isErrorInLoading == true ? CircularProgressIndicator(color: Colors.white): Text(
                          "Change Password",
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
            ],
          ),
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
              SizedBox(width: 55,),
              Text(
                  CHANGE_PASSWORD,
                  style: Theme.of(context).textTheme.headline5!.apply(color: Theme.of(context).backgroundColor,
                      fontWeightDelta: 5
                  )
              )
            ],
          ),
        ),
      ],
    );
  }
}
