
import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/DoctorDetailsClass.dart';
import 'package:appcode3/views/MakeAppointment.dart';
import 'package:appcode3/views/MapWidget.dart';
import 'package:appcode3/views/ReviewsScreen.dart';
import 'package:appcode3/views/loginAsUser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {

  String id;

  DetailsPage(this.id);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
 
  DoctorDetailsClass? doctorDetailsClass;
  bool isLoading = true;
  bool? isLoggedIn;
  bool isErrorInLoading = false;
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDoctorDetails();
    print(widget.id);
    SharedPreferences.getInstance().then((pref){
      setState(() {
        isLoggedIn = pref.getBool("isLoggedIn") ?? false;
      });
    });
  }
  
  fetchDoctorDetails() async{
    setState(() {
      isLoading = true;
    });
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/viewdoctor?doctor_id=${widget.id}"))
    .catchError((e){
      print("ERROR ${e.toString()}");
      setState(() {
        isErrorInLoading = true;
      });
    });

    print(response.request);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        doctorDetailsClass = DoctorDetailsClass.fromJson(jsonResponse);
        print(doctorDetailsClass!.data!.avgratting);
        print(widget.id);
        setState(() {
          isLoading = false;
          //doctorDetailsClass.data.avgratting = '3';
        });
      }

  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        body: Stack(
          children: [
            isErrorInLoading ? Container(
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
            ) : !isLoading
                ? Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
              child: Column(
                      children: [
                        header(),
                        appointmentListWidget(),
                        doctorDetails(),
                        SizedBox(height: 80,),
                      ],
              ),
            ),
                    ),
                    button(),
                  ],
                )
                : Center(
              child: CircularProgressIndicator(),
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
                  Navigator.pop(context);
                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                DOCTOR_DETAILS,
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

  Widget appointmentListWidget() {
    return Container(
      //height: 110,
      margin: EdgeInsets.fromLTRB(10,10,10,10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: WHITE,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: doctorDetailsClass!.data!.image!,
              height: 80,
              width: 80,
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctorDetailsClass!.data!.name!,
                  style: GoogleFonts.poppins(
                      color: BLACK,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                ),
                SizedBox(height: 2,),
                Text(doctorDetailsClass!.data!.departmentName!,
                  style: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                  ),
                ),
                SizedBox(height: 4,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass!.data!.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass!.data!.avgratting! >= 1
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass!.data!.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass!.data!.avgratting! >= 2
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass!.data!.avgratting! == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass!.data!.avgratting! >= 3
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass!.data!.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass!.data!.avgratting! >= 4
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                    Expanded(
                                        child: Image.asset(
                                          doctorDetailsClass!.data!.avgratting == null
                                              ? "assets/detailScreenImages/star_no_fill.png"
                                              : doctorDetailsClass!.data!.avgratting! >= 5
                                              ? "assets/detailScreenImages/star_fill.png"
                                              : "assets/detailScreenImages/star_no_fill.png",
                                          height: 17,
                                          width: 17,
                                        )
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5,)
                              ],
                            ),
                          ),
                          Text(" (${doctorDetailsClass!.data!.totalReview} $REVIEWS)",
                            style: GoogleFonts.poppins(
                                color: LIGHT_GREY_TEXT,
                                fontSize: 8,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                          SizedBox(
                            width: 10,),
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsScreen(doctorDetailsClass!.data!.id.toString())));
                            },
                            child: Text("$SEE_ALL_REVIEW",
                              style: GoogleFonts.poppins(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,)
                        ],
                      ),
                    ),
                  ],
                ),
                //SizedBox(height: 5,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget doctorDetails(){
    return Container(
      //height: MediaQuery.of(context).size.height - 300,
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: WHITE,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PHONE_NUMBER,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: BLACK,
                        fontSize: 14
                    ),
                  ),
                  //SizedBox(height: 8,),
                  Text(
                    doctorDetailsClass!.data!.phoneno!,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: LIGHT_GREY_TEXT,
                        fontSize: 10
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: (){
                  launch("tel://${doctorDetailsClass!.data!.phoneno!}");
                },
                child: Image.asset(
                  "assets/detailScreenImages/phone_button.png",
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorDetailsClass!.data!.aboutus==null?" ":ABOUT_US,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              //SizedBox(height: 8,),
              Text(
                doctorDetailsClass!.data!.aboutus == null ? " " : doctorDetailsClass!.data!.aboutus.toString(),
                 style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: LIGHT_GREY_TEXT,
                    fontSize: 10
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          doctorDetailsClass!.data!.address==null?
                          Container():
                          Image.asset(
                            "assets/detailScreenImages/location_pin.png",
                            height: 15,
                            width: 15,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            doctorDetailsClass!.data!.address==null? " " :ADDRESS,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: BLACK,
                                fontSize: 15
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          doctorDetailsClass!.data!.address == null ? " " : doctorDetailsClass!.data!.address.toString(),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: LIGHT_GREY_TEXT,
                              fontSize: 10
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          doctorDetailsClass!.data!.workingTime==null?
                          Container():Image.asset(
                            "assets/detailScreenImages/time.png",
                            height: 15,
                            width: 15,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            doctorDetailsClass!.data!.workingTime==null?" " :WORKING_TIME,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: BLACK,
                                fontSize: 15
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          doctorDetailsClass!.data!.workingTime == null ? " " : doctorDetailsClass!.data!.workingTime.toString(),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: LIGHT_GREY_TEXT,
                              fontSize: 10
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 50,),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          //width: 100,
                          child: InkWell(
                            onTap: (){
                              openMap(double.parse(doctorDetailsClass!.data!.lat!), double.parse(doctorDetailsClass!.data!.lon!));
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  doctorDetailsClass!.data!.address==null?
                                      Container()
                                      : Image.asset(
                                    "assets/detailScreenImages/map_icon.png",
                                    height: 110,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctorDetailsClass!.data!.services == null ? " " : SERVICES,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                    fontSize: 15
                ),
              ),
              //SizedBox(height: 8,),
              Text(
                doctorDetailsClass!.data!.services == null ? "" : doctorDetailsClass!.data!.services.toString(),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: LIGHT_GREY_TEXT,
                    fontSize: 10
                ),
              ),
              SizedBox(height: 8,),
              Text(
                doctorDetailsClass!.data!.healthcare==null?" ":HEALTH_CARE,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                    fontSize: 15
                ),
              ),
              //SizedBox(height: 8,),
              Text(
                doctorDetailsClass!.data!.healthcare == null ?" ": doctorDetailsClass!.data!.healthcare.toString(),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: LIGHT_GREY_TEXT,
                    fontSize: 10
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget button(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 55,
        margin: EdgeInsets.fromLTRB(12, 10, 12, 10),
        //width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: (){
            processPayment();
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset("assets/moreScreenImages/header_bg.png",
                  height: 60,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                ),
              ),

              Center(
                child: isLoggedIn! ? Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),

                      ),
                      padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${CURRENCY.trim()}${doctorDetailsClass!.data!.consultationFee ?? NOT_SPECIFIED}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: WHITE,
                                fontSize: 18
                            ),
                          ),
                          Text(
                            BOOK_NOW,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: WHITE,
                                fontSize: 9
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5,),
                    Container(
                      height: 70,
                      child: VerticalDivider(
                        color: WHITE,
                        indent: 5,
                        thickness: 0.5,
                        endIndent: 5,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Text(
                      BOOK_NOW,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: WHITE,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: WHITE,
                      size: 16,
                    ),
                    SizedBox(
                      width: 12,
                    ),

                  ],
                ) : Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),

                      ),
                      padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${CURRENCY.trim()}${doctorDetailsClass!.data!.consultationFee ?? NOT_SPECIFIED}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: WHITE,
                                fontSize: 18
                            ),
                          ),
                          Text(
                            APPOINTMENT_FEE,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: WHITE,
                                fontSize: 9
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 5,),
                    Container(
                      height: 70,
                      child: VerticalDivider(
                        color: WHITE,
                        indent: 5,
                        thickness: 0.5,
                        endIndent: 5,
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Text(
                      LOGIN_TO_BOOK_APPOINTMENT,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: WHITE,
                          fontSize: 14
                      ),
                    ),

                    SizedBox(
                      width: 12,
                    ),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    print("opening map");
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      print("Could not open the map");
      throw 'Could not open the map.';
    }
  }

  _launchMaps() async {
    print('launching maps');
    String googleUrl =
        'comgooglemaps://?center=${doctorDetailsClass!.data!.lat},${doctorDetailsClass!.data!.lon}';
    String appleUrl =
        'https://maps.apple.com/?sll=${doctorDetailsClass!.data!.lat},${doctorDetailsClass!.data!.lon}';
    if (await canLaunch("comgooglemaps://")) {
      print('launching com googleUrl');
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      print('launching apple url');
      await launch(appleUrl);
    } else {
      print('launching apple url');
      throw 'Could not launch url';
    }
  }

  processPayment() {
    // if(isLoggedIn && doctorDetailsClass.data.consultationFee == null){
    //   messageDialog(CAN_NOT_MAKE_APPOINTMENT, APPOINTMENT_CAN_NOT_BE_MADE_AS_COSULTAION_FEE_IS_NOT_SPECIFIED);
    // }else{
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
      isLoggedIn!
          ? MakeAppointment(widget.id, doctorDetailsClass!.data!.name!, doctorDetailsClass!.data!.consultationFee!)
          : LoginAsUser())
      );
    //}
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(s1, style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: Theme.of(context).textTheme.bodyText1,)
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () async{
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  // color: Theme.of(context).primaryColor,
                  child: Text(OK,style: Theme.of(context).textTheme.bodyText1)
              ),
            ],
          );
        }
    );
  }


}