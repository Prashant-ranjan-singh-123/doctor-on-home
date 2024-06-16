import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:appcode3/VideoCall/managers/call_manager.dart';
import 'package:appcode3/VideoCall/utils/consts.dart';
import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/DoctorAppointmentDetailsClass.dart';
import 'package:appcode3/views/ChatScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectycube_sdk/connectycube_calls.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'my_photo_viewer.dart';

class UserAppointmentDetails extends StatefulWidget {
  String id;

  UserAppointmentDetails(this.id);

  @override
  _UserAppointmentDetailsState createState() => _UserAppointmentDetailsState();
}

class _UserAppointmentDetailsState extends State<UserAppointmentDetails> {
  DoctorAppointmentDetailsClass? doctorAppointmentDetailsClass;
  Future? getAppointmentDetails;
  bool isErrorInLoading = false;

  String? doctorId;
  String? userId;
  Timer? countdownTimer;
  Duration myDuration = Duration(hours: 01, seconds: 60);
  Timer? timer;
  bool isSecondNagitive = false;

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    int second;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    second = int.parse(parts[parts.length - 1]);
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, seconds: second);
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        isSecondNagitive = true;
        timer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  fetchAppointmentDetails() async {
    print('inside fetchAppointmentDetails method');
    print('$SERVER_ADDRESS/api/appointmentdetail?id=${widget.id}&type=1');
    final response = await http
        .get(Uri.parse(
            "$SERVER_ADDRESS/api/appointmentdetail?id=${widget.id}&type=1"))
        .catchError((e) {
      setState(() {
        isErrorInLoading = true;
      });
    });
    print(response.statusCode);
    print(response.request!.url);
    if (response.statusCode == 200) {
      print(response.request);
      print(response.request);
      // print('UserAppointmentDetails response.body -- ${response.body}');
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse["success"].toString() == "1") {
        setState(() {
          doctorAppointmentDetailsClass =
              DoctorAppointmentDetailsClass.fromJson(jsonResponse);
        });
        doctorId = jsonResponse['data']['doctor_id'].toString();
        userId = jsonResponse['data']['user_id'].toString();
      } else {
        // setState(() {
        //   isErrorInLoading = true;
        // });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    timer = Timer.periodic(Duration(seconds: 1), (timer) => setCountDown());
    super.initState();
    print('call UserAppointmentDetails');
    getAppointmentDetails = fetchAppointmentDetails();
    print('widget id for appointment detail ${widget.id}');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final days = strDigits(myDuration.inDays);
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        appBar: AppBar(
          flexibleSpace: header(),
          leading: Container(),
        ),
        body: isErrorInLoading
            ? Container(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 100,
                        color: LIGHT_GREY_TEXT,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        UNABLE_TO_LOAD_DATA_FORM_SERVER,
                      )
                    ],
                  ),
                ),
              )
            : FutureBuilder(
                future: getAppointmentDetails,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(child: CircularProgressIndicator()));
                  } else if (snapshot.connectionState == ConnectionState.none) {
                    return Container();
                  } else {
                    return Stack(
                      children: [
                        appointmentListWidget(
                            doctorAppointmentDetailsClass!.data!),
                      ],
                    );
                  }
                },
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
                  Navigator.pop(context);
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
              Text(
                APPOINTMENT,
                style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                //style: Theme.of(context).textTheme.headline5.apply(color: Theme.of(context).backgroundColor)
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget appointmentListWidget(Data list) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: list.doctorImage.toString(),
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        "assets/homeScreenImages/user_unactive.png",
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, err) => Container(
                      color: Theme.of(context).primaryColorLight,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          "assets/homeScreenImages/user_unactive.png",
                          height: 20,
                          width: 20,
                        ),
                      )),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.doctorName!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .apply(fontWeightDelta: 5, fontSizeDelta: 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).primaryColorLight),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/detailScreenImages/time.png",
                            height: 13,
                            width: 13,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            // statusToString(list.status!)!,
                            list.status! == 0
                                ? ABSENT
                                : list.status! == 1
                                ? RECEIVED
                                : list.status! == 2
                                ? APPROVED
                                : list.status! == 3
                                ? IN_PROCESS
                                : list.status! == 4
                                ? COMPLETED
                                : REJECTED,
                            style: Theme.of(context).textTheme.caption!.apply(
                                  fontSizeDelta: 0.5,
                                  fontWeightDelta: 2,
                                ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    "assets/homeScreenImages/calender.png",
                    height: 17,
                    width: 17,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      list.date.toString().substring(8) +
                          "-" +
                          list.date.toString().substring(5, 7) +
                          "-" +
                          list.date.toString().substring(0, 4),
                      style: Theme.of(context).textTheme.caption),
                  Text(list.slot!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .apply(fontWeightDelta: 2)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          padding: EdgeInsets.all(8),
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PHONE_NUMBER,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .apply(fontWeightDelta: 1, fontSizeDelta: 1.5),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        list.phone!.toString(),
                        style: Theme.of(context).textTheme.caption!.apply(
                              fontWeightDelta: 2,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      launch("tel:" + list.phone!.toString());
                    },
                    child: Image.asset(
                      "assets/detailScreenImages/phone_button.png",
                      height: 45,
                      width: 45,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EMAIL_ADDRESS,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .apply(fontWeightDelta: 1, fontSizeDelta: 1.5),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        list.email!,
                        style: Theme.of(context).textTheme.caption!.apply(
                              fontWeightDelta: 2,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      print("pressed");
                      launch(Uri(
                        scheme: 'mailto',
                        path: list.email,
                        // queryParameters: {
                        //   'subject': 'Example Subject & Symbols are allowed!'
                        // }
                      ).toString());
                    },
                    child: Image.asset(
                      "assets/detailScreenImages/email_btn.png",
                      height: 45,
                      width: 45,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DESCRIPTION,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .apply(fontWeightDelta: 1, fontSizeDelta: 1.5),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        list.description!,
                        style: Theme.of(context).textTheme.caption!.apply(
                              fontWeightDelta: 2,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                  Spacer(),
                  InkWell(
                      onTap: () {
                        print(list.connectycubeUserId!);
                        _showMyDialog(list.connectycubeUserId!.toInt(), list);
                      },
                      // child: Image.asset(
                      //   "assets/video-call.png",
                      //   height: 45,
                      //   width: 45,
                      // ),
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xff01d8c9),
                              borderRadius: BorderRadius.circular(15)),
                          height: 40,
                          width: 45,
                          child: Icon(
                            Icons.video_call,
                            color: Colors.white,
                          ))),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                      onTap: () {
                        print("pressed");
                        print("live chat pressed");

                        /// old chat screen navigation
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => ChatScreen(
                        //             list.doctorName,
                        //             '100' + doctorId.toString(),
                        //             list.connectycubeUserId,
                        //             false,list.deviceToken)));

                        /// new chat screen navigation
                                      // 10,
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      list.doctorName,
                                      '100' + doctorId.toString(),
                                      list.connectycubeUserId,
                                      false,
                                      list.deviceToken,
                                      list.userImage,
                                      list.doctorImage,
                                    )));
                      },
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xff01d8c9),
                              borderRadius: BorderRadius.circular(15)),
                          height: 40,
                          width: 45,
                          child: Icon(
                            Icons.chat,
                            color: Colors.white,
                          ))),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Visibility(
                visible: list.prescription != null,
                child: list.prescription != null &&
                        list.prescription!.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PRESCRIPTION,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .apply(fontWeightDelta: 1, fontSizeDelta: 1.5),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: list.prescription!,
                                  errorWidget: (context, rsn, err) {
                                    return Center(
                                      child: Text(
                                        rsn.toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  },
                                  height: 200,
                                  width: double.maxFinite,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            print(
                                                "list.pres  ------>${list.prescription}");
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyPhotoView(
                                                            imagePath: list
                                                                .prescription!)));
                                          },
                                          icon: Icon(
                                            Icons.open_in_full,
                                            color: Colors.white,
                                          ),
                                          iconSize: 20,
                                          constraints: BoxConstraints(
                                              maxHeight: 40, maxWidth: 40),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ],
                      )
                    : SizedBox(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            padding: EdgeInsets.all(8),
            color: WHITE,
          ),
        ),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }

  Future<void> _showMyDialog(int callId, data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose call type'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 4,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          CallManager.instance.startNewCall(
                              context, CallType.AUDIO_CALL, {callId});
                          for (int i = 0; i < data.deviceToken!.length; i++) {
                            sendCallNotification(data.deviceToken![i].token!,
                                CallType.AUDIO_CALL, data);
                          }
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                "assets/moreScreenImages/header_bg.png",
                                height: 50,
                                width: MediaQuery.of(context).size.width / 4,
                                fit: BoxFit.fill,
                                // width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            Center(
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width / 4,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          CallManager.instance.startNewCall(
                              context, CallType.VIDEO_CALL, {callId});
                          for (int i = 0; i < data.deviceToken!.length; i++) {
                            sendCallNotification(data.deviceToken![i].token!,
                                CallType.VIDEO_CALL, data);
                          }
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                "assets/moreScreenImages/header_bg.png",
                                width: MediaQuery.of(context).size.width / 4,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Center(
                              child: Icon(
                                Icons.video_call,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )
                // Text('This is a demo alert dialog.'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          // actions: <Widget>[
          //   TextButton(
          //     child: const Text('Approve'),
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //   ),
          // ],
        );
      },
    );
  }

  // Future<Map<String, dynamic>> sendCallNotification(
  //     String token, int type, Data data) async {
  //   print('send notification call');
  //
  //   String sessionId =
  //       "${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999999)}";
  //
  //   String? mytoken;
  //   String? myconnectCubId;
  //   String? myName;
  //   SharedPreferences.getInstance().then((value) {
  //     value.setString("currentCallToken", token);
  //     value.setString("currentCallSessionId", sessionId);
  //     mytoken = value.getString('token');
  //     int? tmp = value.getInt('pref_user_id');
  //     myconnectCubId = tmp.toString();
  //     myName = value.getString('name');
  //   });
  //
  //   await FirebaseMessaging.instance.requestPermission(
  //       sound: true, badge: true, alert: true, provisional: false);
  //
  //   await http
  //       .post(
  //     Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'key=$serverToken',
  //     },
  //     body: jsonEncode(
  //       <String, dynamic>{
  //         'priority': 'high',
  //         'notification': <String, dynamic>{
  //           'android': <String, String>{},
  //           // 'title' : "Call Notification",
  //           // 'body' : '',
  //           // 'title' : "$userName calling you",
  //           // 'body' : 'click here to answer',
  //         },
  //         'data': <String, String>{
  //           'callNotification': 1.toString(),
  //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //           'body': "data body",
  //           'title': "data title",
  //           'type': "calling",
  //           '$PARAM_SIGNAL_TYPE': "$SIGNAL_TYPE_START_CALL",
  //           '$PARAM_SESSION_ID': sessionId,
  //           // '$PARAM_CALL_OPPONENTS': connectyCubeUserId,
  //           '$PARAM_CALL_OPPONENTS': data.connectycubeUserId.toString(),
  //           '$PARAM_CALL_TYPE': type.toString(),
  //           '$PARAM_CALLER_ID': myconnectCubId!,
  //           '$PARAM_CALLER_NAME': "$myName",
  //           'notificationType': 1.toString(),
  //           'mytoken': mytoken!,
  //         },
  //         'to': token,
  //       },
  //     ),
  //   )
  //       .then((value) {
  //     print("\n\nMessage sent : ${value.body}");
  //     print('send token $token');
  //   }).catchError((onError) {
  //     print('\n\n Catch Error on notification $onError');
  //   });
  //
  //   final Completer<Map<String, dynamic>> completer =
  //       Completer<Map<String, dynamic>>();
  //
  //   return completer.future;
  // }

  Future<Map<String, dynamic>> sendCallNotification(String token,int type,Data data) async {

    print('send notification call');

    String sessionId = "${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999999)}";

    String? mytoken;
    String? myconnectCubId;
    String? myName;
    SharedPreferences.getInstance().then((value){
      value.setString("currentCallToken", token);
      value.setString("currentCallSessionId", sessionId);
      mytoken = value.getString('token');
      int? tmp = value.getInt('pref_user_id');
      myconnectCubId = tmp.toString();
      myName = value.getString('name');
    });

    await FirebaseMessaging.instance.requestPermission(
        sound: true, badge: true, alert: true, provisional: false);


    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'notification' : <String, dynamic>{
            'android' : <String,String>{
            },
            // 'title' : "Call Notification",
            // 'body' : '',
            // 'title' : "$userName calling you",
            // 'body' : 'click here to answer',
          },
          'data': <String, String>{
            'callNotification': 1.toString(),
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'body': "data body",
            'title': "data title",
            'type': "calling",
            '$PARAM_SIGNAL_TYPE': "$SIGNAL_TYPE_START_CALL",
            '$PARAM_SESSION_ID': sessionId,
            // '$PARAM_CALL_OPPONENTS': connectyCubeUserId,
            '$PARAM_CALL_OPPONENTS': data.connectycubeUserId.toString(),
            '$PARAM_CALL_TYPE': type.toString(),
            '$PARAM_CALLER_ID': myconnectCubId!,
            '$PARAM_CALLER_NAME': "$myName",
            'image': "",
            'notificationType': 1.toString(),
            'mytoken': mytoken!,
          },
          'to': token,
        },
      ),
    ).then((value){
      print("\n\nMessage sent : ${value.body}");
      print('send token $token');
    }).catchError((onError){
      print('\n\n Catch Error on notification $onError');
    });

    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();

    return completer.future;
  }


  String? statusToString(int status) {
    switch (status) {
      case 0:
        return ABSENT;
      case 1:
        return RECEIVED;
      case 2:
        return APPROVED;
      case 3:
        return IN_PROCESS;
      case 4:
        return COMPLETED;
      case 5:
        return REJECTED;
    }
  }
  // 9bvcyGyzj7Y

// Widget button(){
//   return Align(
//     alignment: Alignment.bottomCenter,
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Container(
//           height: 50,
//           margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
//           child: InkWell(
//             onTap: (){
//
//             },
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(25),
//                   child: Image.asset("assets/moreScreenImages/header_bg.png",
//                     height: 50,
//                     fit: BoxFit.fill,
//                     width: MediaQuery.of(context).size.width,
//                   ),
//                 ),
//                 Center(
//                   child: Text(
//                     ACCEPT,
//                     style: Theme.of(context).textTheme.bodyText1.apply(
//                       color: Theme.of(context).backgroundColor,
//                       fontSizeDelta: 2
//                     )
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//         SizedBox(height: 10,),
//         Container(
//           height: 50,
//           margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
//           child: InkWell(
//             onTap: (){
//
//             },
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(25),
//                   child: Image.asset("assets/moreScreenImages/header_bg.png",
//                     height: 50,
//                     fit: BoxFit.fill,
//                     width: MediaQuery.of(context).size.width,
//                   ),
//                 ),
//                 Center(
//                   child: Text(
//                       CANCEL,
//                       style: Theme.of(context).textTheme.bodyText1.apply(
//                         color: Theme.of(context).backgroundColor,
//                         fontSizeDelta: 2
//                       )
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
}
