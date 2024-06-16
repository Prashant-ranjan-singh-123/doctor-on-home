import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserEditProfile extends StatefulWidget {

  String imageUrl;
  UserEditProfile(this.imageUrl);

  @override
  _UserEditProfileState createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {

  String name = "";
  String phoneNumber = "";
  String email = "";
  String password = "";
  String confirmPassword = "";
  String phnNumberError = "";
  bool isPhoneNumberError = false;
  bool isNameError = false;
  bool isEmailError = false;
  bool isPassError = false;
  String token = "";
  String error = "";
  final picker = ImagePicker();
  String? base64image;
  File? _image;
  String? userId = "";
  String profileImage = "";
  bool isLoading = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  Future getImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      imageQuality: 25
    );

    setState(() {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          base64image = base64Encode(_image!.readAsBytesSync());
          print(base64image);
        });
      } else {
        print('No image selected.');
      }
    });
  }




  registerUser() async {
    if (name.isEmpty) {
      setState(() {
        isNameError = true;
      });
    }
    else if (phoneNumber == null || phoneNumber.length < PHONE_NUMBER_LENGTH) {
      setState(() {
        isPhoneNumberError = true;
        phnNumberError = ENTER_VALID_MOBILE_NUMBER;
      });
    }
    else if (EmailValidator.validate(email) == false) {
      setState(() {
        isEmailError = true;
      });
    }
    else if (password != confirmPassword || password.length == 0) {
      setState(() {
        isPassError = true;
      });
    }
    else {
      dialog();
      //Toast.show("Creating account please wait", context);
      String url = "$SERVER_ADDRESS/api/usereditprofile";

      if(_image == null){
        var response = await post(Uri.parse(url), body: {
          'id' : userId,
          'name': name,
          'email': email,
          'phone': phoneNumber,
          'password': password,
          'token': token,
        });
        print(response.statusCode);
        print(response.body);
        var jsonResponse = await jsonDecode(response.body);
        if (jsonResponse['success'] == "0") {
          setState(() {
            Navigator.pop(context);
            error = jsonResponse['register'];
            messageDialog("Error!", error);
            //isPhoneNumberError = true;
          });
        }
        else{
          SharedPreferences.getInstance().then((pref){
            pref.setBool("isLoggedIn", true);
            pref.setString("userId", userId!);
            pref.setString("name", name);
            pref.setString("phone", phoneNumber);
            pref.setString("email", email);
            pref.setString("password", password);
            pref.setString("token", token.toString());
            //pref.setString("profile_image", jsonResponse['data']['profile_pic']);
          });
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TabsScreen()
              )
          );
        }
      }

      else{

        //Response response;
        var d = dio.Dio();

        var formData = dio.FormData.fromMap({
          'id' : userId,
          'name': name,
          'email': email,
          'phone': phoneNumber,
          'password': password,
          'token': token,
          'image' : await dio.MultipartFile.fromFile(_image!.path, filename: 'image.jpg'),
        });
        var response = await d.post(url, data: formData);

        // print(response.data['data']);
        var jsonResponse = await jsonDecode(response.data);
        // print(jsonResponse['success']);

        // var response = await post(url, body: {
        //   'id' : userId,
        //   'name': name,
        //   'email': email,
        //   'phone': phoneNumber,
        //   'password': password,
        //   'token': token,
        //   'image' : base64image,
        // });
        // print("USER ID : $userId");
        // print(response.statusCode);
        // print(response.body);
        //var jsonResponse = await jsonDecode(response.body);
        if (jsonResponse['success'] == 0) {
          setState(() {
            Navigator.pop(context);
            error = jsonResponse['register'];
            messageDialog("Error!", error);
            //isPhoneNumberError = true;
          });
        }
        else{
          SharedPreferences.getInstance().then((pref){
            pref.setBool("isLoggedIn", true);
            pref.setString("userId", userId!);
            pref.setString("name", name);
            pref.setString("phone", phoneNumber);
            pref.setString("email", email);
            pref.setString("password", password);
            pref.setString("token", token.toString());
            pref.setString("profile_image", SERVER_ADDRESS + "/public/upload/profile/" + jsonResponse['data']['profile_pic']);
          });
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TabsScreen()
              )
          );
        }

      }

    }
  }

  getToken() async{

    FirebaseMessaging.instance.getToken().then((value){
      //Toast.show(value, context, duration: 2);
      print(value);
      setState(() {
        token = value!;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
    SharedPreferences.getInstance().then((pref){
      setState(() {
        userId = pref.getString("userId");
        nameController.text = name = pref.getString("name")!;
        phoneController.text = phoneNumber = pref.getString("phone")!;
        emailController.text = email = pref.getString("email")!;
        passController.text = confirmController.text = password = confirmPassword = pref.getString("password").toString();
        print(userId);
        profileImage = pref.getString("profile_image").toString();
      });
    }).then((x){
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? LinearProgressIndicator()
            : Stack(
          children: [
            bottom(),
            SingleChildScrollView(
              child: Column(
                children: [
                  header(),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(70),
                              border: Border.all(
                                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(65),
                                child: _image != null
                                    ? Image.file(
                                  _image!,
                                  height: 130,
                                  width: 130,
                                  fit: BoxFit.fill,
                                )
                                    : CachedNetworkImage(
                                  imageUrl: profileImage == null ? " " : profileImage,
                                  height: 130,
                                  width: 130,
                                  placeholder: (context, url) => Icon(Icons.image, color: Theme.of(context).primaryColorDark.withOpacity(0.5),),
                                  errorWidget: (context, url, error) => Icon(Icons.image, color: Theme.of(context).primaryColorDark.withOpacity(0.5),),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 135,
                            width: 135,
                            child: Align(
                                alignment: Alignment.bottomRight,
                                child: InkWell(
                                  onTap: (){
                                    getImage();
                                  },
                                  child: Image.asset(
                                    "assets/homeScreenImages/edit.png",
                                    height: 35,
                                    width: 35,
                                  ),
                                )
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  registerForm(),
                ],
              ),
            ),
            header(),
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

                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                REGISTER,
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

  Widget bottom(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ALREADY_HAVE_AN_ACCOUNT,
              style: GoogleFonts.poppins(
                color: BLACK,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Text(" $LOGIN_NOW",
                style: GoogleFonts.poppins(
                  color: AMBER,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget registerForm(){
    return Container(
      height: MediaQuery.of(context).size.height - 150,
      decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20))
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: ENTER_NAME,
                labelStyle: GoogleFonts.poppins(
                    color: LIGHT_GREY_TEXT,
                    fontWeight: FontWeight.w400
                ),
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: LIGHT_GREY_TEXT)
                ),
                errorText: isNameError ? ENTER_NAME : null,
              ),
              style: GoogleFonts.poppins(
                  color: BLACK,
                  fontWeight: FontWeight.w500
              ),
              onChanged: (val){
                setState(() {
                  name = val;
                  isNameError = false;
                });
              },
            ),
            SizedBox(height: 3,),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: ENTER_MOBILE_NUMBER,
                  labelStyle: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontWeight: FontWeight.w400
                  ),
                  errorText: isPhoneNumberError ? phnNumberError : null,
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: LIGHT_GREY_TEXT)
                  )
              ),
              style: GoogleFonts.poppins(
                  color: BLACK,
                  fontWeight: FontWeight.w500
              ),
              onChanged: (val){
                setState(() {
                  phoneNumber = val;
                  isPhoneNumberError = false;
                });
              },
            ),
            SizedBox(height: 3,),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: ENTER_YOUR_EMAIL,
                  labelStyle: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontWeight: FontWeight.w400
                  ),
                  errorText: isEmailError ? ENTER_VALID_EMAIL_ADDRESS : null,
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: LIGHT_GREY_TEXT)
                  )
              ),
              style: GoogleFonts.poppins(
                  color: BLACK,
                  fontWeight: FontWeight.w500
              ),
              onChanged: (val){
                setState(() {
                  email = val;
                  isEmailError = false;
                });
              },
            ),
            SizedBox(height: 3,),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: PASSWORD,
                  labelStyle: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontWeight: FontWeight.w400
                  ),
                  errorText: isPassError ? PASSWORD_DOES_NOT_MATCH : null,
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: LIGHT_GREY_TEXT)
                  )
              ),
              style: GoogleFonts.poppins(
                  color: BLACK,
                  fontWeight: FontWeight.w500
              ),
              onChanged: (val){
                setState(() {
                  password = val;
                  isPassError = false;
                });
              },
            ),
            SizedBox(height: 3,),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: CONFIRM_PASSWORD,
                  labelStyle: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontWeight: FontWeight.w400
                  ),
                  errorText: isPassError ? PASSWORD_DOES_NOT_MATCH : null,
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: LIGHT_GREY_TEXT)
                  )
              ),
              style: GoogleFonts.poppins(
                  color: BLACK,
                  fontWeight: FontWeight.w500
              ),
              onChanged: (val){
                setState(() {
                  confirmPassword = val;
                  isPassError = false;
                });
              },
            ),
            SizedBox(height: 3,),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              //width: MediaQuery.of(context).size.width,
              child: InkWell(
                onTap: (){
                  registerUser();
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
                        UPDATE,
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
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  dialog(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Updating details",
              style: GoogleFonts.poppins(),
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text("Please wait while updating details",
                      style: GoogleFonts.poppins(
                          fontSize: 12
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
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
                onPressed: (){
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).hintColor,
                ),
                // color: Theme.of(context).hintColor,
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
