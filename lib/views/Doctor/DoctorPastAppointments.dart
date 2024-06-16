import 'dart:convert';

import 'package:appcode3/main.dart';
import 'package:appcode3/modals/DoctorPastAppointmentsClass.dart';
import 'package:appcode3/views/Doctor/DoctorAppointmentDetails.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../en.dart';

class DoctorPastAppointments extends StatefulWidget {
  @override
  _DoctorPastAppointmentsState createState() => _DoctorPastAppointmentsState();
}

class _DoctorPastAppointmentsState extends State<DoctorPastAppointments> {

  DoctorPastAppointmentsClass? doctorPastAppointmentsClass;
  Future? future;
  String? userId;
  bool isAppointmentAvailable = false;
  String nextUrl = "";
  bool isLoadingMore = false;
  List<DoctorAppointmentData> list = [];
  List<DoctorAppointmentData> list2 = [];
  int page = 0;
  ScrollController _scrollController = ScrollController();

  fetchPastAppointments() async{
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/doctorpastappointment?doctor_id=$userId"));
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'] == 1){
        setState(() {
          isAppointmentAvailable = true;
          doctorPastAppointmentsClass = DoctorPastAppointmentsClass.fromJson(jsonResponse);
          nextUrl = doctorPastAppointmentsClass!.data!.nextPageUrl!;
          print(nextUrl);
          list.addAll(doctorPastAppointmentsClass!.data!.doctorAppointmentData!);
        });
      }else{
        setState(() {
          isAppointmentAvailable = false;
        });
      }
    }
  }

  loadmore() async{
    if(nextUrl != "null") {
      final response = await get(Uri.parse("$nextUrl&doctor_id=$userId"));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == "1") {
          setState(() {
            isLoadingMore = false;
            doctorPastAppointmentsClass =
                DoctorPastAppointmentsClass.fromJson(jsonResponse);
            nextUrl = doctorPastAppointmentsClass!.data!.nextPageUrl!;
            print(nextUrl);
            list2.clear();
            //list.addAll(doctorPastAppointmentsClass.data.doctorAppointmentData);
            list2.addAll(doctorPastAppointmentsClass!.data!.doctorAppointmentData!);
          });
        } else {
          setState(() {});
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((pref){
      setState(() {
        userId = pref.getString("userId");
        future = fetchPastAppointments();
      });
    });
    _scrollController.addListener(() async{
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        //print("Loadmore");
        //await fetchPastAppointments();
        await loadmore();
        print(list.length);
        print(list2.length);
        list.addAll(list2);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: header(),
          leading: Container(),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: upCommingAppointments(),
        ),
      ),
    );
  }

  Widget upCommingAppointments(){
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          FutureBuilder(
            future: future,
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting || userId == null){
                return Container(
                  height: MediaQuery.of(context).size.height - 100,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
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
                  itemCount: nextUrl != "null" ? list.length + 1 : list.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index){
                    if(list.length == index){
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                            height: 80,
                            child: Center(child: CircularProgressIndicator())),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        appointmentListWidget(index, list),
                        ENABLE_ADS ? (index+1)%4 == 0 && index != 0 ? customAds.nativeAds(id: AD_TYPE) : Container() : Container()
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
          isLoadingMore ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: LinearProgressIndicator(),
          ) : Container(
            height: 50,
          )
        ],
      ),
    );
  }

  Widget appointmentListWidget(int index, List<dynamic> list) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => DoctorAppointmentDetails(list[index].id.toString()),
          ),
        );
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
                  ALL_APPOINTMENTS,
                  style: Theme.of(context).textTheme.headline5!.apply(color: Theme.of(context).backgroundColor, fontWeightDelta: 5)
              )
            ],
          ),
        ),
      ],
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
