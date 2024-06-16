import 'dart:convert';

import 'package:appcode3/VideoCall/utils/consts.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/Call_All_In_One.dart';
import 'package:appcode3/modals/NearbyDoctorClass.dart';
import 'package:appcode3/modals/SearchDoctorClass.dart';
import 'package:appcode3/views/AllAppointments.dart';
import 'package:appcode3/views/DetailsPage.dart';
import 'package:appcode3/views/Doctor/DoctorAppointmentDetails.dart';
import 'package:appcode3/views/HomeScreenNearby.dart';
import 'package:appcode3/views/SearchedScreen.dart';
import 'package:appcode3/views/SpecialityDoctorsScreen.dart';
import 'package:appcode3/views/SpecialityScreen.dart';
import 'package:appcode3/views/UserAppointmentDetails.dart';
import 'package:appcode3/views/incoming_call_image_name.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../VideoCall/managers/call_manager.dart';
import '../en.dart';
import '../notificationHelper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _textController = TextEditingController();
  SearchDoctorClass? searchDoctorClass;
  bool isLoading = false;
  bool isSearching = false;
  bool isErrorInNearby = false;
  bool isNearbyLoading = false;
  NearbyDoctorsClass? nearbyDoctorClass;
  String userName = " ";
  TextField? textField;
  bool isAppointmentExist = false;

  Future? loadAppointments;
  String userId = "";
  bool isLoadingMore = false;
  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  String nextUrl = "";
  String searchKeyword = "";
  NotificationHelper notificationHelper = NotificationHelper();
  var _newData = [];
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  Position? position;

  bool isLoggedIn = false;

  final CarouselController sliderController = CarouselController();
  int current = 0;
  bool isErrorInLoading = false;

  List<Speciality> list = [];
  List<BannerList> bannerList = [];
  List<Appointment> AppointmentList = [];
  bool isSpecialityLoading = false;
  bool isBannerLoading = false;

  bool isLoad = false;

  final incomingCallManager = Get.put(IncomingManageController());

  call_3in1_api() async {
    String Uri1 = isLoggedIn
        ? "$SERVER_ADDRESS/api/data_list?user_id=$userId"
        : "$SERVER_ADDRESS/api/data_list";

    final response = await get(Uri.parse(Uri1));
    print("API : ${response.request!.url}");
    print("respons4 : ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      call_all_api = Call_All_Api.fromJson(responseData);
      bannerList.addAll(call_all_api.data!.banner!);
      list.addAll(call_all_api.data!.speciality!);

      AppointmentList.addAll(call_all_api.data!.appointment!);
      print("AppointmentList.length : ${AppointmentList.length}");

      isLoad = true;
      setState(() {});
    }
  }

  Call_All_Api call_all_api = Call_All_Api();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getLocationStart();
    notificationHelper.initialize();

    SharedPreferences.getInstance().then((pref) {
      isLoggedIn = pref.getBool("isLoggedIn") ?? false;
      userId = pref.getString("userId") ?? "";

      setState(() {});
      call_3in1_api();
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    FirebaseMessaging.onMessage.listen((message) {
      print("onMessage: $message");
      print("\n\n" + message.toString());
      // notificationHelper.showNotification(title: message.notification!.title,body: message.notification!.body ,payload: "${message.data['type']}:${message.data['order_id']}", id: "124", context2: context);

      var payloadData =
          '${message.data['notificationType']}:${message.data['ccId']}';

      print(payloadData);

      if (message.data['order_id'] != null) {
        notificationHelper.showNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            payload: "${message.data['type']}:${message.data['order_id']}",
            id: "124",
            context2: context);
      } else if (payloadData.split(":")[0].toString() == '3') {
        notificationHelper.showNotification(
          title: 'Call Rejected',
          body: message.notification!.body,
          payload: payloadData,
          id: "124",
        );
        try {
          print('success on reject call ');
          Get.to(() => Container());
          CallManager.instance.reject(message.data['sessionId']);
        } catch (e) {
          print('error on reject call $e');
        }
      } else if (payloadData.split(":")[0].toString() == '1') {
        print('call coming');

        incomingCallManager.setValue(
            message.data['$PARAM_CALLER_NAME'], message.data['image'] ?? "");
      } else {
        notificationHelper.showNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          payload: payloadData,
          id: "124",
          // context2: context
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("onMessageAppOpened: $message");
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

    SharedPreferences.getInstance().then((pref) {
      setState(() {
        userName = pref.getString("name") ?? USER;
        if (pref.getString('callSessionCS') != null) {
          dialog();
        }
        isLoggedIn = pref.getBool("isLoggedIn") ?? false;
      });
    });
    _scrollController.addListener(() {
      print(_scrollController.position.pixels);
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //print("Loadmore");
        _loadMoreFunc();
      }
    });
  }

  callApi({double? latitude, double? longitude}) async {
    final response = await get(Uri.parse(
            "$SERVER_ADDRESS/api/nearbydoctor?lat=${latitude}&lon=${longitude}"))
        .catchError((e) {
      setState(() {
        isErrorInNearby = true;
      });
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
    });

    print("API : " + response.request!.url.toString());

    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse.toString());
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      //print([0].name);
      if (mounted) {
        setState(() {
          lat = latitude.toString();
          lon = longitude.toString();
          nearbyDoctorsClass = NearbyDoctorsClass.fromJson(jsonResponse);
          print("Finished");
          list2.addAll(nearbyDoctorsClass!.data!.nearbyData!);
          nextUrl = nearbyDoctorsClass!.data!.nextPageUrl!;
          print(nextUrl);
          isNearbyLoading = false;
        });
      }
    } else {
      setState(() {
        isErrorInNearby = true;
      });
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
    }
  }

  Future<bool> dialogPop() async {
    print('dialog cancle');
    SharedPreferences.getInstance().then((pref) {
      pref.remove('callSessionCS');
    });
    return true;
  }

  dialog() {
    return Get.defaultDialog(
      onWillPop: dialogPop,
      barrierDismissible: true,
      title: CALL_ACCEPT,
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
                PLEASE_WAIT_CALL_ACCEPT,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //_scrollController.dispose();
  }

  int x = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
      body: Stack(
        children: [
          isSearching
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10, 130, 10, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _newData.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailsPage(
                                              _newData[index].id.toString())));
                                },
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _newData[index].name,
                                            style: GoogleFonts.poppins(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontSize: 14),
                                          ),
                                          Icon(
                                            Icons.search,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                        endIndent: 7, indent: 7, thickness: 1),
                                  ],
                                ),
                              );
                              // return ListTile(
                              //   title: Text(
                              //     _newData[index].name,
                              //     style: GoogleFonts.poppins(
                              //         color: Theme.of(context).primaryColorDark,
                              //         fontSize: 14
                              //     ),
                              //   ),
                              //   trailing: Icon(
                              //     Icons.search,
                              //     size: 18,
                              //   ),
                              //   onTap: (){
                              //     Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(_newData[index].id.toString())));
                              //   },
                              // );
                            }),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  controller: _scrollController2,
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.21,
                      ),
                      isLoad
                          ? slider()
                          : Container(
                              height: Get.height * 0.35,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator()),
                      isLoad ? isLoggedIn ? upCommingAppointments() : Container() : Container(),
                      isLoad ? specialist() : Container(),
                      HomeScreenNearby(_scrollController2),
                    ],
                  ),
                ),
          header(),
        ],
      ),
    );
  }

  slider() {
    return isBannerLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: CarouselSlider.builder(
                carouselController: sliderController,
                itemCount: bannerList.length,
                itemBuilder: (context, index, realIndex) {
                  return buildImage(index);
                },
                options: CarouselOptions(
                  viewportFraction: 1,
                  height: 220,
                  initialPage: 0,
                  reverse: false,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    changeIndex(index);
                  },
                ),
              ),
            ),
          );
  }

  buildImage(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: IMAGE + bannerList[index].image!,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    )),
              );
            },
            placeholder: (context, url) => Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage("assets/placeholder image.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            errorWidget: (context, url, err) => Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage("assets/home/1.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: buildIndicator(),
          )
        ],
      ),
    );
  }

  buildIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerList.asMap().entries.map((entry) {
            return GestureDetector(
                child: Container(
              width: 12.0,
              height: 12.0,
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    current == entry.key ? Colors.black : Colors.grey.shade300,
              ),
            ));
          }).toList()),
    );
  }

  void changeIndex(int index) {
    setState(() {
      current = index;
    });
  }

  specialist() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            SPECIALITY,
            style: Theme.of(context).textTheme.bodyText2!.apply(
                  fontWeightDelta: 3,
                ),
          ),
          SizedBox(
            height: 10,
          ),
          isErrorInLoading
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
              : isSpecialityLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.separated(
                          itemCount: list.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SpecialityDoctorsScreen(
                                              list[index].id.toString(),
                                              list[index].name),
                                    ));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 25,
                                        width: 25,
                                        child: Image.network(
                                          "$SERVER_ADDRESS/public/upload/services/${list[index].icon!}",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        list[index].name!,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: BLACK,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              width: 10,
                            );
                          },
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  //--------------widgets--------------------------

  Widget noAppointment() {
    return Container(
      height: 250,
      margin: EdgeInsets.all(10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/homeScreenImages/no_appo_img.png"),
            Text(
              YOU_DONOT_HAVE_ANY_UPCOMING_APPOINTMENT,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Stack(
      children: [
        Image.asset(
          "assets/homeScreenImages/header_bg.png",
          height: MediaQuery.of(context).size.height * 0.23,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fill,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              children: [
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text("$WELCOME, ",
                        style: Theme.of(context).textTheme.caption!.apply(
                              color: Theme.of(context).backgroundColor,
                              fontSizeDelta: 4,
                            )),
                    Text(userName,
                        style: Theme.of(context).textTheme.headline5!.apply(
                            color: Theme.of(context).backgroundColor,
                            fontWeightDelta: 2)),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        //margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).backgroundColor,
                        ),
                        child: textField = TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).backgroundColor),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: SEARCH_DOCTOR_BY_NAME,
                              hintStyle:
                                  Theme.of(context).textTheme.bodyText2!.apply(
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withOpacity(0.4),
                                      ),
                              suffixIcon: Container(
                                height: 20,
                                width: 20,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(13),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: isLoading
                                          ? AlwaysStoppedAnimation(
                                              Theme.of(context).hintColor)
                                          : AlwaysStoppedAnimation(
                                              Colors.transparent),
                                    ),
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).backgroundColor),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).backgroundColor),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).backgroundColor),
                                borderRadius: BorderRadius.circular(15),
                              )),
                          onChanged: (val) {
                            setState(() {
                              searchKeyword = val;
                              _onChanged(val);
                            });
                          },
                          onSubmitted: (val) {
                            setState(() {
                              searchKeyword = val;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SearchedScreen(_textController.text)));
                        setState(() {
                          _newData.clear();
                          _textController.clear();
                          _textController.text = "";
                          _onChanged(_textController.text);
                          //_textController = new TextEditingController();
                          //textField.controller.clearComposing();
                          //_textController.selection.end;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/homeScreenImages/search_icon.png",
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget upCommingAppointments() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(UPCOMING_APPOINTMENTS,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .apply(fontWeightDelta: 3)),
              AppointmentList.length != 0
                  ? TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AllAppointments(AppointmentList)),
                        );
                      },
                      child: Text(SEE_ALL,
                          style: Theme.of(context).textTheme.bodyText1!.apply(
                                color: Theme.of(context).hintColor,
                              )),
                    )
                  : Container(
                      height: 40,
                    )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          AppointmentList.length == 0 ? Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Image.asset("assets/homeScreenImages/no_appo_img.png"),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    YOU_DONOT_HAVE_ANY_UPCOMING_APPOINTMENT,
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        FIND_BEST_DOCTORS_NEAR_YOU_BY_SPECIALITY,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 10),
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpecialityScreen(),
                              ));
                        },
                        child: Text(
                          CLICK_HERE,
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              color: AMBER),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ) :ListView.builder(
            itemCount: AppointmentList.length > 2 ? 2 : AppointmentList.length,
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              print("$SERVER_ADDRESS/public/upload/doctors/${AppointmentList[index].doctorls!.image}");
              return appointmentListWidget(index, AppointmentList);
            },
          )
        ],
      ),
    );
  }

  Widget appointmentListWidget(int index, List<Appointment> data) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UserAppointmentDetails(data[index].id.toString())),
        );
      },
      child: Container(
        height: 90,
        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: WHITE,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: "$SERVER_ADDRESS/public/upload/doctors/${data[index].doctorls!.image}",
                height: 70,
                width: 70,
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
                          data[index].doctorls!.name!,
                          style: GoogleFonts.poppins(
                              color: BLACK,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          data[index].departmentName!,
                          style: GoogleFonts.poppins(
                              color: BLACK,
                              fontSize: 11,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 9,),
                  Container(
                    child: Text(
                      data[index].doctorls!.address!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: LIGHT_GREY_TEXT,
                          fontSize: 10,
                          fontWeight: FontWeight.w400),
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
                  data[index].date.toString().substring(8) +
                      "-" +
                      data[index].date.toString().substring(5, 7) +
                      "-" +
                      data[index].date.toString().substring(0, 4),
                  style: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  data[index].slot!,
                  style: GoogleFonts.poppins(
                      color: BLACK, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onChanged(String value) async {
    if (value.length == 0) {
      setState(() {
        _newData.clear();

        isSearching = false;
        print("length 0");
        print(_newData);
      });
    } else {
      setState(() {
        isLoading = true;
        isSearching = true;
      });
      print(Uri.parse("$SERVER_ADDRESS/api/searchdoctor?term=$value"));
      final response =
          await get(Uri.parse("$SERVER_ADDRESS/api/searchdoctor?term=$value"))
              .catchError((e) {
        setState(() {
          isLoading = false;
        });
      });
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
        //print([0].name);
        if (mounted) {
          setState(() {
            _newData.clear();
            //print(searchDoctorClass.data.doctorData);
            _newData.addAll(searchDoctorClass!.data!.doctorData!);
            nextUrl = searchDoctorClass!.data!.links!.last.url!;
            print(nextUrl);
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  _loadMoreFunc() async {
    if (nextUrl == null) {
      return;
    }
    setState(() {
      isLoadingMore = true;
    });
    print(searchKeyword);
    final response = await get(Uri.parse("$nextUrl&term=$searchKeyword"));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
      //print([0].name);
      setState(() {
        //print(searchDoctorClass.data.doctorData);
        _newData.addAll(searchDoctorClass!.data!.doctorData!);
        isLoadingMore = false;
        nextUrl = searchDoctorClass!.data!.links!.last.url!;
        print(nextUrl);
      });
    }
  }

  void _getLocationStart() async {
    print('Started 1 ');

    setState(() {
      isErrorInNearby = false;
      isNearbyLoading = true;
    });

    //Toast.show("loading", context);
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      setState(() {
        position = value;
      });
    }).catchError((e) {
      //Toast.show(e.toString(), context,duration: 3);
      print(e);
      messageDialog(PERMISSION_NOT_GRANTED, e.toString());
      if (mounted) {
        setState(() {
          isErrorInNearby = true;
          isNearbyLoading = false;
        });
      }
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
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    var status = await Permission.location.status;
                    if (status.isPermanentlyDenied) {
                      await pop(animated: true);
                    } else if (!status.isGranted &&
                        s1 == PERMISSION_NOT_GRANTED) {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.location,
                        Permission.storage,
                      ].request();
                      _getLocationStart();
                      // We didn't ask for permission yet or the permission has been denied before but not permanently.
                    }

                    Navigator.pop(context);
                  },
                  child:
                      Text(OK, style: Theme.of(context).textTheme.bodyText1)),
            ],
          );
        });
  }

  static Future<void> pop({bool? animated}) async {
    print("calling pop");
    await SystemChannels.platform
        .invokeMethod<void>('SystemNavigator.pop', animated);
  }
}
