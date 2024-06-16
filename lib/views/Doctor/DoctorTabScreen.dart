import 'dart:io';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/notificationHelper.dart';
import 'package:appcode3/views/Doctor/DoctorChatListScreen.dart';
import 'package:appcode3/views/Doctor/DoctorDashboard.dart';
import 'package:appcode3/views/Doctor/DoctorPastAppointments.dart';
import 'package:appcode3/views/Doctor/DoctorProfile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../UserAppointmentDetails.dart';
import 'DoctorAppointmentDetails.dart';
import 'moreScreen/more_info_screen.dart';

class DoctorTabsScreen extends StatefulWidget {
  @override
  _DoctorTabsScreenState createState() => _DoctorTabsScreenState();
}

class _DoctorTabsScreenState extends State<DoctorTabsScreen> {
  List<Widget> screens = [
    DoctorDashboard(),
    DoctorPastAppointments(),
    DoctorProfile(),
    ChatListScreen(),
    MoreInfoScreen(),
    // LogOutScreen(),
  ];

  int index = 0;
  NotificationHelper notificationHelper = NotificationHelper();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> willPopScope() async {
    exit(0);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationHelper.initialize();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Here is notification is call ");
      print("Here is notification is call ");
      print("onMessage: $message");
      print("\n\n" + message.toString());
      notificationHelper.showNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          payload: "${message.data['type']}:${message.data['order_id']}",
          id: "124",
          context2: context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("onResume: $message");
      print("\n\n" + message.data.toString());
      if (message.data['type'] == "user_id") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UserAppointmentDetails(message.data['order_id'].toString())),
        );
      } else if (message.data['type'] == "doctor_id") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoctorAppointmentDetails(
                  message.data['order_id'].toString())),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopScope,
      child: Scaffold(
        body: screens[index],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: LIGHT_GREY_SCREEN_BACKGROUND,
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
                  label: "Home",
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
                  label: "Appointment",
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    index == 2
                        ? "assets/homeScreenImages/user_active.png"
                        : "assets/homeScreenImages/user_unactive.png",
                    height: 25,
                    width: 25,
                    fit: BoxFit.cover,
                  ),
                  label: "Edit profile",
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    index == 3
                        ? "assets/homeScreenImages/chat fill.png"
                        : "assets/homeScreenImages/chat unfill.png",
                    height: 25,
                    width: 35,
                    // fit: BoxFit.cover,
                  ),
                  label: RECENT_CHATS,
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    index == 4
                        ? "assets/homeScreenImages/more_active.png"
                        : "assets/homeScreenImages/more_unactive.png",
                    // ? "assets/loginScreenImages/logout-(1).png"
                    // : "assets/loginScreenImages/logout.png",
                    height: 25,
                    width: 25,
                    fit: BoxFit.cover,
                  ),
                  label: "More",
                ),
              ],
              selectedLabelStyle: GoogleFonts.poppins(
                color: BLACK,
                fontSize: 8,
              ),
              type: BottomNavigationBarType.fixed,
              unselectedLabelStyle: GoogleFonts.poppins(
                color: BLACK,
                fontSize: 7,
              ),
              unselectedItemColor: LIGHT_GREY_TEXT,
              selectedItemColor: BLACK,
              onTap: (i) {
                setState(() {
                  index = i;
                });
              },
              currentIndex: index,
            ),
          ),
        ),
      ),
    );
  }

  messageDialog(String s1, String s2) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              s1,
              style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await SharedPreferences.getInstance().then((pref) {
                    pref.setBool("isLoggedInAsDoctor", false);
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                // color: Theme.of(context).primaryColor,
                child: Text(
                  YES,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                  ),
                ),
              ),
            ],
          );
        });
  }
}
