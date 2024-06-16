import 'dart:convert';
import 'dart:io';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/userlogin.dart';
import 'package:appcode3/views/RegisterAsUser.dart';
import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../VideoCall/utils/pref_util.dart';
import 'ForgetPassword.dart';

class LoginAsUser extends StatefulWidget {
  @override
  _LoginAsUserState createState() => _LoginAsUserState();
}

class _LoginAsUserState extends State<LoginAsUser> {
  String phoneNumber = "";
  String pass = "";
  bool isPhoneNumberError = false;
  bool isPasswordError = false;
  String passErrorText = "";
  String token = "";
  FacebookLogin facebookSignIn = new FacebookLogin();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? name, email, image = "";
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String _message = "";

  storeToken(type) async {
    dialog();
    await FirebaseMessaging.instance.getToken().then((value) async {
      //Toast.show(value, context, duration: 2);
      print(value);
      setState(() {
        token = value!;
      });
      log('data: $value');
      final response =
          await post(Uri.parse("$SERVER_ADDRESS/api/savetoken"), body: {
        "token": token,
        "type": "1",
      }).catchError((e) {
        messageDialog(ERROR, UNABLE_TO_SAVE_TOKEN_TO_SERVER);
      });

      if (response.statusCode == 200) {
        Navigator.pop(context);
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'].toString() == "1") {
          SharedPreferences.getInstance().then((pref) {
            pref.setBool("isTokenExist", true);
            print("token stored");
          });
          //Navigator.pop(context);
          loginInto(type);
        }
      } else {
        Navigator.pop(context);
        print("token not stored");
        messageDialog(ERROR, response.body.toString());
        // Navigator.pushReplacement(context,
        //     MaterialPageRoute(builder: (context) => TabsScreen())
        // );
      }
    }).catchError((e) {
      Navigator.pop(context);
      print("token not accessed");
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
    });
    setState(() {
      token = "";
    });
  }

  getToken() async {
    await SharedPreferences.getInstance().then((pref) async {
      if (pref.getBool("isTokenExist") ?? false) {
        String? tokenLocal =
            await FirebaseMessaging.instance.getToken().catchError((e) {
          messageDialog(ERROR, UNABLE_TO_SAVE_TOKEN_TO_SERVER);
        });
        setState(() {
          print("1-> token retrieved");
          token = tokenLocal!;
        });
      }
    });
  }

  loginInto(int type) async {
    if (EmailValidator.validate(phoneNumber) == false && type == 1) {
      setState(() {
        isPhoneNumberError = true;
      });
    } else if (token == null || token.isEmpty && Platform.isAndroid) {
      storeToken(type);
    } else {
      dialog();

      String url = type == 1
          ? "$SERVER_ADDRESS/api/login?email=$phoneNumber&password=$pass&login_type=$type&token=$token"
          : "$SERVER_ADDRESS/api/login?email=$email&login_type=$type&token=$token&name=$name&phone=${MobileNumber.text}";
      print("Heree  id type :-   ${type}");
      print("Heree  id url for call api :-   ${url}");

      var response = await post(Uri.parse(url)).catchError((e) {
        print("Error ${e.toString()}");
        Navigator.pop(context);
        messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      });

      print(response.body);

      if(response.statusCode == 200){

        if(jsonDecode(response.body)['success'] == 0){
          setState(() {
            Navigator.pop(context);
            // print(jsonResponse);
            if (type != 1) {
              errorDialog(jsonDecode(response.body)['register']);
            } else {
              isPasswordError = true;
              passErrorText = EITHER_EMAIL_OR_PASSWORD_IS_INCORRECT;
            }
          });
        }else{
          UserLoginResponse _response = UserLoginResponse.fromJson(jsonDecode(response.body));
          String? token = await firebaseMessaging.getToken();
          FirebaseDatabase.instance
              .reference()
              .child("117" + _response.register!.userId.toString())
              .update({
            "name": _response.register!.name,
            "image": _response.register!.profilePic,
          }).then((value) async {
            FirebaseDatabase.instance
                .reference()
                .child("117" + _response.register!.userId.toString())
                .child("TokenList")
                .set({
              "device": token.toString(),
            }).then((value) async {
              await SharedPreferences.getInstance().then((pref) {
                pref.setBool("isLoggedIn", true);
                pref.setString(
                    "userId", _response.register!.userId.toString());
                pref.setString("name", _response.register!.name!);
                pref.setString(
                    "phone",
                    _response.register!.phone == null
                        ? ""
                        : _response.register!.phone.toString());
                pref.setString("email", _response.register!.email!);
                pref.setString("userIdWithAscii",
                    '117' + _response.register!.userId.toString());
                pref.setString("password", pass);
                pref.setString("token", token.toString());
                pref.setString(
                    "profile_image", _response.register!.profilePic!);
                pref.setString(
                    'myCCID',
                    _response.register!.connectycubeUserId.toString());
              });
              CubeUser user = CubeUser(
                id: _response.register!.connectycubeUserId,
                login: _response.register!.loginId,
                fullName: _response.register!.name
                    .toString()
                    .replaceAll(" ", ""),
                password: type == 2
                    ? _response.register!.connectycubePassword.toString()
                    : pass,
              );
              _loginToCC(context, user);
            });
          });
        }
      }
      /// old code without create modal class
      /*
      // try {
        print("response.statusCode : ${response.statusCode}");
        print("response.body : ${response.body}");
        var jsonResponse = await jsonDecode(response.body);
        print("jsonResponse['success'] : ${jsonResponse['success']}");
        print(
            "jsonResponse['register']['user_id'] : ${jsonResponse['register']['user_id']}");

        if (jsonResponse['success'].toString() == "1") {
          String? token = await firebaseMessaging.getToken();
          FirebaseDatabase.instance
              .reference()
              .child("117" + jsonResponse['register']['user_id'].toString())
              .update({
            "name": jsonResponse['register']['name'],
            "image": jsonResponse['register']['profile_pic'],
          }).then((value) async {
            FirebaseDatabase.instance
                .reference()
                .child("117" + jsonResponse['register']['user_id'].toString())
                .child("TokenList")
                .set({
              "device": token.toString(),
            }).then((value) async {
              await SharedPreferences.getInstance().then((pref) {
                pref.setBool("isLoggedIn", true);
                pref.setString(
                    "userId", jsonResponse['register']['user_id'].toString());
                pref.setString("name", jsonResponse['register']['name']);
                pref.setString(
                    "phone",
                    jsonResponse['register']['phone'] == null
                        ? ""
                        : jsonResponse['register']['phone'].toString());
                pref.setString("email", jsonResponse['register']['email']);
                pref.setString("userIdWithAscii",
                    '117' + jsonResponse['register']['user_id'].toString());
                pref.setString("password", pass);
                pref.setString("token", token.toString());
                pref.setString(
                    "profile_image", jsonResponse['register']['profile_pic']);
                pref.setString(
                    'myCCID',
                    jsonResponse['register']['connectycube_user_id']
                        .toString());
              });
              CubeUser user = CubeUser(
                id: jsonResponse['register']['connectycube_user_id'],
                login: jsonResponse['register']['login_id'],
                fullName: jsonResponse['register']['name']
                    .toString()
                    .replaceAll(" ", ""),
                password: type == 2
                    ? jsonResponse['register']['connectycube_password']
                    : pass,
              );
              _loginToCC(context, user);
            });
          });
        } else {
          setState(() {
            Navigator.pop(context);
            print(jsonResponse);
            if (type != 1) {
              errorDialog(jsonResponse['register']);
            } else {
              isPasswordError = true;
              passErrorText = EITHER_EMAIL_OR_PASSWORD_IS_INCORRECT;
            }
          });
        }
      // } catch (e) {
      //   Navigator.pop(context);
      //   messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      // }*/
    }
  }

  _loginToCC(BuildContext context, CubeUser user) {
    if (CubeSessionManager.instance.isActiveSessionValid() &&
        CubeSessionManager.instance.activeSession!.user != null) {
      print('_loginToCC if part');
      if (CubeChatConnection.instance.isAuthenticated()) {
        print('_loginToCC if-if part');
        print('---------> go to opponents screen 1st');
        SharedPrefs.getUser().then((value) async {
          try {
            if (value!.id != null) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => TabsScreen()));
            }
          } catch (e) {
            await deleteSession();
            Navigator.pop(context);
            messageDialog(ERROR, PLEASE_TRY_AGAIN);
          }
        });
      } else {
        print('_loginToCC if-else part');
        _loginToCubeChat(context, user);
      }
    } else {
      print('_loginToCC else part');
      createSession(user).then((cubeSession) {
        print('then part');
        _loginToCubeChat(context, user);
      }).catchError((exception) {
        print('catcherror part');
        // Navigator.pop(context);
        // messageDialog(ERROR, PLEASE_TRY_AGAIN);
        print(exception);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TabsScreen(),
            ));
        // _processLoginError(exception);
      });
    }
  }

  void _loginToCubeChat(BuildContext context, CubeUser user) {
    print('_loginToCubeChat');
    CubeChatConnection.instance.login(user).then((cubeUser) {
      SharedPrefs.saveNewUser(user);
      SharedPrefs.getUser().then((value) {
        print('${value!.fullName}');
        print('${value.login}');
        print('${value.password}');
        print('${value.id.toString()}');
        if (value.id != null) {
          // _loginToCC(context,value);
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => TabsScreen()));
        }
      });
    }).catchError((exception) {
      print(exception);
      // _processLoginError(exception);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("here init call");
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            //bottom(),
            SingleChildScrollView(
              child: Column(
                children: [header(), loginForm()],
              ),
            ),
            header(),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Stack(
      children: [
        Image.asset(
          "assets/moreScreenImages/header_bg.png",
          height: 60,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          height: 60,
          child: Row(
            children: [
              SizedBox(
                width: 15,
              ),
              InkWell(
                onTap: () {
                  SharedPreferences.getInstance().then((value) {
                    print("isBack value${value.getString("isBack")}");
                    if (value.getString("isBack") == "1") {
                      value.setString("isBack", "0");
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TabsScreen(),
                          ));
                    } else {
                      Navigator.pop(context);
                    }
                  });
                },
                child: Image.asset(
                  "assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(LOGIN,
                  style: Theme.of(context).textTheme.headline5!.apply(
                      color: Theme.of(context).backgroundColor,
                      fontWeightDelta: 2))
            ],
          ),
        ),
      ],
    );
  }

  Widget bottom() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DO_NOT_HAVE_AN_ACCOUNT,
                style: Theme.of(context).textTheme.bodyText2),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterAsUser()));
              },
              child: Text(" $REGISTER_NOW",
                  style: Theme.of(context).textTheme.bodyText1!.apply(
                        color: AMBER,
                      )),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget loginForm() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              // Image.asset(
              //   "assets/loginScreenImages/login_icon.png",
              //   height: 180,
              //   width: 180,
              // ),
              Lottie.asset('assets/lottie/Login.json', width: 180, height: 180, reverse: true),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: ENTER_YOUR_EMAIL,
                    labelStyle: Theme.of(context).textTheme.bodyText2!.apply(
                        fontSizeDelta: 2,
                        color: Theme.of(context).primaryColorDark),
                    errorText:
                        isPhoneNumberError ? ENTER_VALID_EMAIL_ADDRESS : null,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Theme.of(context).primaryColorDark,
                    ))),
                style: Theme.of(context).textTheme.bodyText2!.apply(
                      fontWeightDelta: 3,
                      fontSizeDelta: 2,
                    ),
                onChanged: (val) {
                  setState(() {
                    phoneNumber = val;
                    isPhoneNumberError = false;
                    isPasswordError = false;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: Theme.of(context).textTheme.bodyText2!.apply(
                      fontSizeDelta: 2,
                      color: Theme.of(context).primaryColorDark),
                  errorText: isPasswordError ? passErrorText : null,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: Theme.of(context).primaryColorDark,
                  )),
                ),
                style: Theme.of(context).textTheme.bodyText2!.apply(
                      fontWeightDelta: 3,
                      fontSizeDelta: 2,
                    ),
                onChanged: (val) {
                  setState(() {
                    pass = val;
                    isPasswordError = false;
                  });
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgetPassword("1")));
                    },
                    child: Text(
                      FORGET_PASSWORD,
                      style: TextStyle(
                          color: BLACK,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 50,
                //width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: () {
                    loginInto(1);
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          "assets/moreScreenImages/header_bg.png",
                          height: 50,
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Center(
                        child: Text(LOGIN,
                            style: Theme.of(context).textTheme.bodyText1!.apply(
                                fontSizeDelta: 5,
                                color: Theme.of(context).backgroundColor)),
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DO_NOT_HAVE_AN_ACCOUNT,
                      style: Theme.of(context).textTheme.bodyText2),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterAsUser()));
                    },
                    child: Text(" $REGISTER_NOW",
                        style: Theme.of(context).textTheme.bodyText1!.apply(
                              color: AMBER,
                            )),
                  ),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: InkWell(
              //         borderRadius: BorderRadius.circular(50),
              //         onTap: (){
              //           facebookLogin();
              //         },
              //         child: Container(
              //           margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
              //           height: 50,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(25),
              //             color: Colors.blue.shade600,
              //           ),
              //           child: Center(
              //             child: Text(
              //               CONTINUE_WITH_FACEBOOK,
              //               style: TextStyle(
              //                   color: WHITE,
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //     )
              //   ],
              // ),

              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        MobileNumber.text = "";
                        setState(() {});
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, setState1) {
                                return AlertDialog(
                                  actions: [
                                    Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, top: 8.0),
                                          child: Text(
                                            PROVIDE_YOUR_MOBILE_NUMBER,
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: TextField(
                                        keyboardType: TextInputType.phone,
                                        controller: MobileNumber,
                                        decoration: InputDecoration(
                                            labelText: ENTER_MOBILE_NUMBER,
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .apply(
                                                    fontSizeDelta: 2,
                                                    color: Theme.of(context)
                                                        .primaryColorDark),
                                            errorText: isMobileNumberError
                                                ? ENTER_VALID_MOBILE_NUMBER
                                                : null,
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ))),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .apply(
                                              fontWeightDelta: 3,
                                              fontSizeDelta: 2,
                                            ),
                                        onChanged: (val) {
                                          setState1(() {
                                            phoneNumber = val;
                                            isMobileNumberError = false;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                ),
                                                // color: Theme.of(context).primaryColor,
                                                child: Text(CANCEL,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1)),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            child: TextButton(
                                                onPressed: () {
                                                  // googleLogin();
                                                  if (MobileNumber
                                                      .text.isEmpty) {
                                                    isMobileNumberError = true;
                                                    setState1(() {});
                                                  } else if (phoneNumber
                                                          .length <
                                                      PHONE_NUMBER_LENGTH) {
                                                    isMobileNumberError = true;
                                                    setState1(() {});
                                                  } else {
                                                    Navigator.pop(context);
                                                    googleLogin();
                                                  }
                                                },
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                ),
                                                // color: Theme.of(context).primaryColor,
                                                child: Text(OK,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1)),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              });
                            });
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.red,
                        ),
                        child: Center(
                          child: Text(
                            CONTINUE_WITH_GOOGLE,
                            style: TextStyle(
                                color: WHITE,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),

              SizedBox(
                height: 20,
              ),
              // Platform.isIOS ? Row(
              //   children: [
              //     Expanded(
              //       child: Container(
              //         margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
              //         height: 50,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(25),
              //           color: Theme.of(context).hintColor,
              //         ),
              //         child: Stack(
              //           children: [
              //             Row(
              //               children: [
              //                 Expanded(
              //                   child: Image.asset(
              //                     "assets/loginregister/appleid.png",
              //                   ),
              //                 ),
              //               ],
              //             ),
              //             Center(
              //               child: Text(
              //                 CONTINUE_WITH_APPLE_ID,
              //                 style: TextStyle(
              //                     color: WHITE,
              //                     fontSize: 16,
              //                     fontWeight: FontWeight.bold
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     )
              //   ],
              // ) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  dialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              LOGGING_IN,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Text(
                      PLEASE_WAIT_LOGGING_IN,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  messageDialog(String s1, String s2) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(s1, style: Theme.of(context).textTheme.bodyText1),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  // color: Theme.of(context).primaryColor,
                  child:
                      Text(OK, style: Theme.of(context).textTheme.bodyText1)),
            ],
          );
        });
  }

  errorDialog(message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Icon(
                  Icons.error,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  message.toString(),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        });
  }

  processingDialog(message) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(LOADING),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 14),
                  ),
                )
              ],
            ),
          );
        });
  }

  // loginIntoAccount(int type) async{
  //
  //   processingDialog(PLEASE_WAIT_WHILE_LOGGING_INTO_ACCOUNT);
  //   Response response;
  //   Dio dio = new Dio();
  //
  //   FormData formData = type == 1 ? FormData.fromMap({
  //     "name" : name,
  //     "email" : email,
  //     "password" : pass,
  //     "device_token" : await firebaseMessaging.getToken(),
  //     "device_type" : "$type",
  //   })
  //       : FormData.fromMap({
  //     "name" : name,
  //     "email" : email,
  //     "device_token" : await firebaseMessaging.getToken(),
  //     "device_type" : "$type",
  //   })
  //   ;
  //   response = await dio.post(SERVER_ADDRESS+"/api/userlogin?login_type=$type&device_token=${await firebaseMessaging.getToken()}&device_type=1&email=$email&name=$name", data: formData)
  //       .catchError((e){
  //     if(type == 2){
  //       googleLogin();
  //     }
  //   });
  //   if(response.statusCode == 200 && response.data['status'] == 1){
  //     print(response.toString());
  //
  //
  //   }else{
  //     Navigator.pop(context);
  //     print("Error" + response.toString());
  //     errorDialog(response.data['msg']);
  //   }
  //
  // }

  facebookLogin() async {
    final FacebookLoginResult result = await facebookSignIn.logIn();
    print(result.status);
    if (result.status == FacebookLoginStatus.success) {
      final token = result.accessToken!.token;
      final graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}'));
      final profile = jsonDecode(graphResponse.body);

      print(profile.toString());
      print(profile['email']);

      switch (result.status) {
        case FacebookLoginStatus.success:
          final FacebookAccessToken accessToken = result.accessToken!;
          _showMessage('''
         Logged in!
         result ${result.accessToken!.userId}
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
          setState(() {
            name = profile['name'];
            email = profile['name'] + "@gmail.com";
            //image = profile['profile'];
          });

          loginInto(3);
          break;
        case FacebookLoginStatus.cancel:
          _showMessage('Login cancelled by the user.');
          errorDialog('Login cancelled by the user.');

          break;
        case FacebookLoginStatus.error:
          _showMessage('Something went wrong with the login process.\n'
              'Here\'s the error Facebook gave us: ${result.error}');
          errorDialog('Something went wrong with the login process.\n'
              'Here\'s the error Facebook gave us: ${result.error}');
          break;
      }
    } else {
      print(result.error);
      errorDialog(result.error);
    }
  }

  //
  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  //
  googleLogin() async {
    await _googleSignIn.signIn().then((value) {
      print("01-> ${value!.displayName}");
      print("01-> ${value.email}");
      print("01-> ${value.photoUrl}");
      setState(() {
        name = value.displayName;
        email = value.email;
        image = value.photoUrl;
      });
      loginInto(2);
    }).catchError((e) {
      print(e.toString());
      errorDialog(e.toString());
    });
  }

  TextEditingController MobileNumber = TextEditingController();
  bool isMobileNumberError = false;
}
