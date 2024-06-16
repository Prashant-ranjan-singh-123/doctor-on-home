import 'dart:convert';

import 'package:appcode3/VideoCall/utils/consts.dart';
import 'package:appcode3/en.dart';
import 'package:appcode3/views/incoming_call_image_name.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/DoctorAppointmentClass.dart';
import 'package:appcode3/modals/DoctorPastAppointmentsClass.dart';
import 'package:appcode3/views/Doctor/DoctorAllAppointments.dart';
import 'package:appcode3/views/Doctor/DoctorAppointmentDetails.dart';
import 'package:appcode3/views/Doctor/DoctorProfileWithRating.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../VideoCall/managers/call_manager.dart';
import '../../notificationHelper.dart';
import '../AllAppointments.dart';
import '../UserAppointmentDetails.dart';
import 'DoctorChooseYourPlan.dart';

class DoctorDashboard extends StatefulWidget {
  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {

  DoctorPastAppointmentsClass? doctorAppointmentsClass;
  DoctorProfileWithRating? doctorProfileWithRating;
  Future? future;
  Future? future2;
  bool isAppointmentAvailable = false;
  String? doctorId;
  bool isErrorInLoading = false;

  NotificationHelper notificationHelper = NotificationHelper();
  final incomingCallManager = Get.put(IncomingManageController());

  fetchDoctorAppointment() async{
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/doctoruappointment?doctor_id=$doctorId"));
    print(Uri.parse("$SERVER_ADDRESS/api/doctoruappointment?doctor_id=$doctorId"));
    print('dashboard api -> ${response.request}');
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'].toString() == "1") {
        setState(() {
          isAppointmentAvailable = true;
          doctorAppointmentsClass =
              DoctorPastAppointmentsClass.fromJson(jsonResponse);
        });
      }else{
        setState(() {
          isAppointmentAvailable = false;
        });
      }
    }
  }

  fetchDoctorDetails() async{
    print('doctor detail url ->${'$SERVER_ADDRESS/api/doctordetail?doctor_id=$doctorId'}');
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/doctordetail?doctor_id=$doctorId"));
    // .catchError((e){
    //   setState(() {
    //     isErrorInLoading = true;
    //   });
    // });
    // try {
      if (response.statusCode == 200) {
        print('status================${response.body}');
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          try {
            doctorProfileWithRating = DoctorProfileWithRating.fromJson(jsonResponse);
            // SharedPreferences sp = await SharedPreferences.getInstance();
            // sp.setString('profilePic', doctorProfileWithRating!.data!.image??'');
            print('subscription================${doctorProfileWithRating!.data!.isSubscription}');
            print('subscription================${doctorProfileWithRating!.data}');
            // if(doctorProfileWithRating!.data!.isSubscription == "0"){
            if(doctorProfileWithRating!.data!.isSubscription == 1){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => DoctorChooseYourPlan(doctorUrl: doctorProfileWithRating!.data!.image.toString())),
              );
              print('subscription==============2======${doctorProfileWithRating!.data!.isSubscription}');
            }
            // ;
            print('doctor image is ${doctorProfileWithRating!.data!.image}');
          }catch(E){
            print('Dashboard error is : ${E}');
          }
          });
      } else {
        setState(() {

        });
      }
    // }catch(e){
    //
    //   setState(() {
    //     isErrorInLoading = true;
    //   });
    // }
  }

  getToken() async{
    print("TOKEN" + firebaseMessaging.getToken().toString());
    var token = await firebaseMessaging.getToken();
    print('tokkkken : $token');
  }

  Future<bool> dialogPop() async{
    print('dialog cancle');
    SharedPreferences.getInstance().then((pref){
      pref.remove('callSessionCS');
    });
    return true;
  }

  @override
  void initState() {
    // nativeAdController.setNonPersonalizedAds(true);
    // nativeAdController.setTestDeviceIds(["0B43A6DF92B4C06E3D9DBF00BA6DA410"]);
    // nativeAdController.stateChanged.listen((event) {
    //   print(event);
    // });
    // TODO: implement initState
    super.initState();
    //getMessages();

    notificationHelper.initialize();
    getToken();
    if (mounted) {
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
      FirebaseMessaging.onMessage.listen((message) {
        print("onDoctor dashboard onMessage: $message");
        print("\n\n" + message.toString());
        var payloadData =
            '${message.data['notificationType']}:${message.data['ccId']}';
        if (message.data['order_id'] != null) {
          notificationHelper.showNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            payload: "${message.data['type']}:${message.data['order_id']}",
            id: "124",
            // context2: context
          );
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
          // incomingCallManager.setValue(message.data['$PARAM_CALLER_NAME'], message.data['Default']);
          print('call image is : ${message.data['image']}');
          incomingCallManager.setValue(
              message.data['$PARAM_CALLER_NAME'], message.data['image']);
        } else {
          notificationHelper.showNotification(
              title: message.notification!.title,
              body: message.notification!.body,
              payload: payloadData,
              id: "124",
              context2: context);
        }
      });

      // FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //   print("onMessageAppOpened: $message");
      //   if (message.data['type'] == "user_id") {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => UserAppointmentDetails(
      //               message.data['order_id'].toString())),
      //     );
      //   } else if (message.data['type'] == "doctor_id") {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => DoctorAppointmentDetails(
      //               message.data['order_id'].toString())),
      //     );
      //   }
      // });
    }

    SharedPreferences.getInstance().then((pref){
      setState(() {
        doctorId = pref.getString("userId");
        future = fetchDoctorAppointment();
        future2 = fetchDoctorDetails();
        if(pref.getString('callSessionCS')!=null){
          dialog();
        }
      });
    });
  }

  dialog() {
    return Get.defaultDialog(
      onWillPop: dialogPop,
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
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyText2,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(

          backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: header(),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                doctorProfile(),
                upCommingAppointments(),
              ],
            ),
          ),
        )
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
              Text(
                DOCTOR_DASHBOARD,
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

  Widget doctorProfile() {
    return isErrorInLoading ? Container(
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
            SizedBox(height: 20,),
            Text(
              UNABLE_TO_LOAD_DATA_FORM_SERVER,
            )
          ],
        ),
      ),
    ) :FutureBuilder(
      future: future2,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting || doctorId == null){
          return Container(
              height: 100,
              child: Center(child: CircularProgressIndicator(
                strokeWidth: 2,
              )));
        }
        return Container(
          //margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).backgroundColor,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: doctorProfileWithRating!.data!.image == "https://demo.freaktemplate.com/bookappointment/public/upload/doctors/user.png" ? "" : doctorProfileWithRating!.data!.image!,
                  height: 85,
                  width: 85,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 20, width: 20,),
                  ),),
                  errorWidget: (context,url,err) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 20, width: 20,),
                  )),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctorProfileWithRating!.data!.name!,
                            style: Theme.of(context).textTheme.subtitle1!.apply(fontWeightDelta: 2),
                          ),
                          Row(
                            children: [
                              Text(doctorProfileWithRating!.data!.departmentName!.isEmpty ? SPECIALITY : doctorProfileWithRating!.data!.departmentName!,
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: Theme.of(context).primaryColorDark),
                              ),
                              SizedBox(width: 10,),
                              Image.asset(
                                "assets/detailScreenImages/star_fill.png",
                                height: 15,
                                width: 15,
                              ),
                              SizedBox(width: 5,),
                              Text(double.parse(doctorProfileWithRating!.data!.avgratting.toString()).toString(),
                                style: Theme.of(context).textTheme.bodyText1!.apply(color: Theme.of(context).primaryColorDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                     SizedBox(height: 10,),
                    Container(
                      child: Text(doctorProfileWithRating!.data!.address ?? ADDRESS_GOES_HERE,
                        style: Theme.of(context).textTheme.caption!.apply(
                          color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                          fontSizeDelta: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10,),

            ],
          ),
        );
      }
    );
  }

  Widget upCommingAppointments(){
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(APPOINTMENTS,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              TextButton(onPressed: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DoctorAllAppointments()),
                );
              }, child: Text(SEE_ALL,
                style: Theme.of(context).textTheme.bodyText2!.apply(
                  color: Theme.of(context).hintColor,
                  fontWeightDelta: 5,
                )
              ),)
            ],
          ),

          SizedBox(height: 5,),

          FutureBuilder(
            future: future,
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting || doctorId == null){
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              }else if(snapshot.hasError){
                return Container(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Image.asset(
                        "assets/homeScreenImages/no_appo_img.png"
                    ),
                  ),
                );
              }else if(snapshot.connectionState == ConnectionState.done && isAppointmentAvailable){
                return ListView.builder(
                  itemCount: doctorAppointmentsClass!.data!.doctorAppointmentData!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        appointmentListWidget(index, doctorAppointmentsClass!.data!.doctorAppointmentData!),
                        ENABLE_ADS ? (index+1)%4 == 0 ? customAds.nativeAds(id: AD_TYPE) : Container() : Container()
                      ],
                    );
                  },
                );
              }else{
                return Container(
                  decoration: BoxDecoration(
                      color: WHITE,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                          "assets/homeScreenImages/no_appo_img.png"
                      ),
                      SizedBox(height: 15,),
                      Text(
                        YOU_DONOT_HAVE_ANY_UPCOMING_APPOINTMENT,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

        ],
      ),
    );
  }

  Widget appointmentListWidget(int index, List<dynamic> list) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () async{
        bool x = false;
        x = await Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => DoctorAppointmentDetails(list[index].id.toString()),
          ),
        );
        if(x){
          setState(() {
            future = fetchDoctorAppointment();
          });
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0,5,0,5),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).backgroundColor,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: list[index].image ?? " ",
                height: 75,
                width: 75,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).primaryColorLight,
                  child: Center(
                    child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 40, width: 40,),
                  ),

                ),
                errorWidget: (context,url,err) => Container(
                  color: Theme.of(context).primaryColorLight,
                  child: Center(
                    child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 40, width: 40,),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(list[index].name,
                          style: Theme.of(context).textTheme.bodyText2!.apply(
                            fontWeightDelta: 5
                          ),
                        ),
                        Text(list[index].phone,
                          style: Theme.of(context).textTheme.caption!.apply(
                            fontWeightDelta: 2,
                            color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context).primaryColorLight
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                            "assets/detailScreenImages/time.png",
                          height: 13,
                          width: 13,
                        ),
                        SizedBox(width: 5,),
                        Text(list[index].status, style: Theme.of(context).textTheme.caption!.apply(
                          fontSizeDelta: 0.5,
                          fontWeightDelta: 2,
                        ),),
                        SizedBox(width: 5,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/homeScreenImages/calender.png",
                  height: 17,
                  width: 17,
                ),
                SizedBox(height: 5,),
                Text(
                    list[index].date.toString().substring(8)+"-"+list[index].date.toString().substring(5,7)+"-"+list[index].date.toString().substring(0,4),
                    style: Theme.of(context).textTheme.caption
                  ),
                Text(list[index].slot,
                  style: Theme.of(context).textTheme.bodyText1!.apply(
                    fontWeightDelta: 2
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAdContainer() {
    return Container(
      // height: 60,
      // margin: EdgeInsets.all(10),
      // child: NativeAdmob(
      //   // Your ad unit id
      //   adUnitID: ADMOB_ID,
      //   controller: nativeAdController,
      //   type: NativeAdmobType.banner,
      // ),
    );
  }


}
