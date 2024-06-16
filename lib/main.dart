// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:appcode3/VideoCall/managers/call_manager.dart';
import 'package:appcode3/VideoCall/managers/push_notifications_manager.dart';
import 'package:appcode3/VideoCall/utils/platform_utils.dart';
import 'package:appcode3/VideoCall/utils/pref_util.dart';
import 'package:appcode3/views/ChatListScreen.dart';
import 'package:appcode3/views/Doctor/loginAsDoctor.dart';
import 'package:appcode3/views/HomeScreen.dart';
import 'package:appcode3/views/MoreScreen.dart';
import 'package:appcode3/views/SplashScreen.dart';
import 'package:appcode3/views/UserPastAppointments.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:connectycube_sdk/connectycube_calls.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
//import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appcode3/CustomAds.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'VideoCall/utils/consts.dart';
import 'VideoCall/utils/configs.dart' as config;
import 'notificationHelper.dart';
import 'package:http/http.dart' as http;
import 'en.dart';

/// old url
const String SERVER_ADDRESS = "https://doctoronhome.com";
const String IMAGE = "https://demo.freaktemplate.com/bookappointment/public/upload/banner/";

/// new url
// const String SERVER_ADDRESS = "https://hairitgestione.eu";
// const String IMAGE = "https://hairitgestione.eu/public/upload/banner/";
//
const String serverToken =
    'AAAAPwd2Odk:APA91bHOAgCVVag8SlmMQLA_xX1mONxeNKcEK0TYOAxHfAp3CvbJ_tewOoIh7MSPK0bMy9H8A9cCJqQYZH71W_SC0nZlfR57i2lDuIGKPtS3HcUB17GpbS1QDrz-08XAXkzjqyClSgtM';
    // 'AAAAdqUYLrU:APA91bGWUUQSVAUdLy15fhb8qQYVnX1ag7BKLzd0bQgGNI3kNBL7IUzFwa67e1ZwXgqe6K23SmvZyhnTdRmAx_QlJyn7MCpPD8awskrRjxeBLm7EAONDQwk2Pf1pfNXYrhP7xwagFuNa';

const LANGUAGE = "en";
int PHONE_NUMBER_LENGTH = 10;
const String ADMOB_ID = "ca-app-pub-7803172892594923/5172476997";
const String FACEBOOK_AD_ID = "727786934549239_727793487881917";

const defaultUserImage = 'assets/default-user.png';

const bool ENABLE_ADS = false;
//true -> enable
//false -> disable

const int AD_TYPE = 1;
//0 -> facebook // not working in ios that's why we removed it
//1 -> admob

int LANGUAGE_TYPE = 0;
//0 ---> English
//1 ---> Arabic

///CURRENCY AND CURRENCY CODE
String CURRENCY = "\$";
String CURRENCY_CODE = "USD";

Color WHITE = Colors.white;
Color BLACK = Colors.black;
Color LIGHT_GREY_SCREEN_BACKGROUND = Colors.grey.shade200;
Color LIGHT_GREY_TEXT = Colors.grey.shade500;
Color AMBER = Colors.amber.shade700;
String STRIPE_KEY = "pk_test_yFUNiYsEESF7QBY0jcZoYK9j00yHumvXho";
String TOKENIZATION_KEY = "sandbox_bn2rby52_8x2htw9jqj88wsyf";
String RAZORPAY_KEY = "rzp_test_NNbwJ9tmM0fbxj";
//final nativeAdController = NativeAdmobController();
String LANGUAGE_FILE = "en";
CustomAds customAds = CustomAds();

const bool IS_CHAT = true;
const bool IS_VIDEO_CALL = true;

Color PRIMARY = Color(0xff01d8c9);

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  notificationHelper.initialize();
  PushNotificationsManager.instance.init();
  ConnectycubeFlutterCallKit.instance.init();
  ConnectycubeFlutterCallKit.onCallAcceptedWhenTerminated =
      onCallAcceptedWhenTerminated;
  ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated =
      onCallRejectedWhenTerminated;
  initForegroundService();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    initConnectycube();
  }

  initConnectycube() {
    init(
      config.APP_ID,
      config.AUTH_KEY,
      config.AUTH_SECRET,
      onSessionRestore: () {
        return SharedPrefs.getUser().then((savedUser) {
          return createSession(savedUser);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff01d8c9),
    ));
    return GetMaterialApp(
      home: Builder(builder: (context) {
        CallManager.instance.init(context);
        return SplashScreen();
      }),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        timePickerTheme: TimePickerThemeData(
          dayPeriodTextColor: Colors.cyanAccent.shade700,
          //hourMinuteColor: Colors.cyanAccent.shade700,
          helpTextStyle: GoogleFonts.poppins(),
        ),
        hintColor: Colors.cyanAccent.shade700,
        primaryColor: Colors.cyanAccent,
        backgroundColor: Colors.white,
        primaryColorDark: Colors.grey.shade700,
        primaryColorLight: Colors.grey.shade200,
        //highlightColor: Colors.amber.shade700,
        textTheme: TextTheme(
          headline1: GoogleFonts.poppins(),
          headline2: GoogleFonts.poppins(),
          headline3: GoogleFonts.poppins(),
          headline4: GoogleFonts.poppins(),
          headline5: GoogleFonts.poppins(),
          headline6: GoogleFonts.poppins(),
          subtitle1: GoogleFonts.poppins(),
          subtitle2: GoogleFonts.poppins(),
          caption: GoogleFonts.poppins(
            fontSize: 10,
          ),
          bodyText1:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          bodyText2:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w300),
          button: GoogleFonts.poppins(),
        ),
      ),
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        // GlobalMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        // English, no country code
        const Locale('he', ''),
        // Hebrew, no country code
        const Locale('ar', ''),
        // Hebrew, no country code
        const Locale.fromSubtags(languageCode: 'zh'),
        // Chinese *See Advanced Locales below*
        // ... other locales the app supports
      ],
    );
  }
}

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Widget> screens = [
    HomeScreen(),
    UserPastAppointments(),
    LoginAsDoctor(),
    ChatListScreen(),
    MoreScreen()
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          //borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15), topLeft: Radius.circular(15)),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  index == 0
                      ? "assets/homeScreenImages/home_active.png"
                      : "assets/homeScreenImages/home_unactive.png",
                  height: 25,
                  width: 25,
                ),
                label: HOME,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index == 1
                      ? "assets/homeScreenImages/appointment_active.png"
                      : "assets/homeScreenImages/appointment_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: APPOINTMENT,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index == 2
                      ? "assets/homeScreenImages/d_l_active.png"
                      : "assets/homeScreenImages/d_l_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: DOCTOR_LOGIN,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index == 3
                      ? "assets/homeScreenImages/chat fill.png"
                      : "assets/homeScreenImages/chat unfill.png",
                  height: 25,
                  width: 25,
                  // fit: BoxFit.cover,
                ),
                label: RECENT_CHATS,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index == 4
                      ? "assets/homeScreenImages/more_active.png"
                      : "assets/homeScreenImages/more_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: MORE,
              ),
            ],
            selectedLabelStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 8,
            ),
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 7,
            ),
            unselectedItemColor: Colors.grey.shade500,
            selectedItemColor: Colors.black,
            onTap: (i) {
              setState(() {
                index = i;
              });
            },
            currentIndex: index,
          ),
        ),
      ),
    );
  }
}

NotificationHelper notificationHelper = NotificationHelper();

FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

Future myBackgroundMessageHandler(RemoteMessage event) async {
  print("\n\nbackground: " + event.data.toString());
  var payloadData =
      '${event.data['notificationType']}:${event.data['ccId']}:${event.data['myid']}:${event.data['myUserName']}';

  if (event.data['signal_type'] == 'endCall') {
    // Eraser.clearAllAppNotifications();
    ConnectycubeFlutterCallKit.reportCallEnded(
        sessionId: event.data['session_id']);
    ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: false);
  }

  if (payloadData.split(":")[0].toString() == '1') {
    var tmpOppId = int.parse(event.data['$PARAM_CALL_OPPONENTS']);
    CallEvent callEvent = CallEvent(
        sessionId: event.data['$PARAM_SESSION_ID'],
        callType: int.parse(event.data['$PARAM_CALL_TYPE']),
        callerId: int.parse(event.data['$PARAM_CALLER_ID']),
        callerName: event.data['$PARAM_CALLER_NAME'],
        opponentsIds: {tmpOppId},
        userInfo: {'token': '${event.data['mytoken']}'});
    ConnectycubeFlutterCallKit.showCallNotification(callEvent);
  } else if (payloadData.split(":")[0].toString() == '3') {
    notificationHelper.showNotification(
      title: 'Call Rejected',
      body: event.notification!.body,
      // payload: "${message.data['ccId']}:${message.data['myid']}:${message.data['myUserName']}:",
      payload: payloadData,
      id: "124",
      // context2: context
    );
    try {
      print('success on reject call ');
      CallManager.instance.reject(event.data['sessionId']);
    } catch (e) {
      print('error on reject call $e');
    }
  }
  // else {
  //   notificationHelper.showNotification(
  //     title: event.notification!.title,
  //     body: event.notification!.body,
  //     // payload: "${message.data['ccId']}:${message.sdata['myid']}:${message.data['myUserName']}:",
  //     payload: payloadData,
  //     id: "124",
  //     // context2: context
  //   );
  // }
}

Future<void> onCallRejectedWhenTerminated(CallEvent callEvent) async {
  try {
    print('token in call event ${callEvent.userInfo!['token']}');
    await http
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'notification': <String, dynamic>{
            'android': <String, String>{},
            'title': "Call Reject",
          },
          'data': <String, String>{
            'notificationType': 3.toString(),
            'sessionId': callEvent.sessionId,
          },
          'to': callEvent.userInfo!['token'],
        },
      ),
    )
        .then((value) async {
      print('send to ${callEvent.userInfo!['token']}');
      print("\n\nMessage sent thround on reject: ${value.body}");
    }).catchError((onError) {
      print("\n\nMessage sent thround on reject catch error: ${onError}");
    });
  } catch (e) {
    print('error on reject call $e');
  }
  print(
      '[PushNotificationsManager][onCallRejectedWhenTerminated] callEvent: $callEvent');
  return sendPushAboutRejectFromKilledState({
    PARAM_CALL_TYPE: callEvent.callType,
    PARAM_SESSION_ID: callEvent.sessionId,
    PARAM_CALLER_ID: callEvent.callerId,
    PARAM_CALLER_NAME: callEvent.callerName,
    PARAM_CALL_OPPONENTS: callEvent.opponentsIds.join(','),
  }, callEvent.callerId);
}

Future<void> onCallAcceptedWhenTerminated(CallEvent callEvent) async {
  try {
    await SharedPreferences.getInstance().then((value) {
      value.setString("callSessionCS", callEvent.sessionId);
    });
  } catch (e) {
    print('error Shared preg $e');
  }

  print(
      '[PushNotificationsManager][onCallRejectedWhenTerminated] callEvent: $callEvent');
  return Future.value();
}
