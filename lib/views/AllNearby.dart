import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:appcode3/en.dart';
import 'package:appcode3/modals/NearbyDoctorClass.dart';
import 'package:appcode3/views/DetailsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart';
// import 'package:loadmore/loadmore.dart';
// import 'package:paging/paging.dart';

import '../main.dart';


class AllNearby extends StatefulWidget {
  @override
  _AllNearbyState createState() => _AllNearbyState();
}

class _AllNearbyState extends State<AllNearby> {

  bool isErrorInNearby = false;
  bool isNearbyLoading = true;
  List<NearbyData> list = [];
  bool isLoadingMore = false;
  String nextUrl = "";
  bool isErrorInLoading = false;
  String lat = "";
  String lon = "";
  NearbyDoctorsClass? nearbyDoctorsClass;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocationStart();

    _scrollController.addListener(() {
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("Loadmore");
        _loadMoreFunc();
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
          leading: Container(),
          flexibleSpace: header(),
        ),
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        body: isErrorInLoading ? Container(
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
        ) : SingleChildScrollView(
            controller: _scrollController,
            child: nearByDoctors()),
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
                NEARBY_DOCTORS,
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


  Widget nearByDoctors(){
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 5),
      child: Column(
        children: [
          SizedBox(height: 10,),
          isNearbyLoading ? Container(
            height: MediaQuery.of(context).size.height-50,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ) :
          list == null
              ? isErrorInNearby ? Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(TURN_ON_LOCATION_AND_RETRY,
                    style: GoogleFonts.poppins(
                        color: BLACK,
                        fontWeight: FontWeight.w400,
                        fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
          ) : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Theme.of(context).hintColor),
              strokeWidth: 2,
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: list.length > 4 ? (list.length/4).floor() : 1,
            itemBuilder: (context, i){
              print((list.length/4).floor());
              print((list.length/4).ceil());
              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemCount: 4,
                    itemBuilder: (BuildContext ctx, index) {
                      return index + (i*4) > list.length - 1 ? Container() : nearByGridWidget(
                        list[index + (i*4)].image,
                        list[index + (i*4)].name,
                        list[index + (i*4)].departmentName,
                        list[index + (i*4)].id,
                      );
                    },
                  ),
                  ENABLE_ADS ? customAds.nativeAds(id: AD_TYPE) : Container(height: 10,)

                ],
              );
            },
          ),
          nextUrl== "null" ? Container() : Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
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



  Widget nearByGridWidget(img, name, dept, id) {
    return InkWell(
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => DetailsPage(id.toString())),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: img,
                  fit: BoxFit.cover,
                  width: 250,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Center(
                      child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 50, width: 50,),
                    ),

                  ),
                  errorWidget: (context,url,err) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Center(
                      child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 50, width: 50,),
                    ),
                    //child: Padding(
                    //   padding: const EdgeInsets.all(20.0),
                    // )
                    //
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text(name,
              style: GoogleFonts.poppins(
                  color: BLACK,
                  fontSize: 13,
                  fontWeight: FontWeight.w500
              ),
            ),
            Text(dept,
              style: GoogleFonts.poppins(
                  color: LIGHT_GREY_TEXT,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getLocationStart() async {

    setState(() {
      isErrorInNearby = false;
      isNearbyLoading = true;
    });
    print('Started');
    //Toast.show("loading", context);
    Platform.isIOS  ? callApi(latitude: 0.0, longitude: 0.0): null;
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .catchError((e){
      //Toast.show(e.toString(), context,duration: 3);
      print("e :$e");
    });

      if(position == null){
        print("position : $position");
        callApi(latitude: 0.0, longitude: 0.0);
      }else{
        callApi(latitude: position.latitude, longitude: position.longitude);
      }

  }

  callApi({double? latitude, double? longitude}) async{
    final response = await get(Uri.parse(Platform.isIOS ? "$SERVER_ADDRESS/api/nearbydoctor?lat=${0.0}&lon=${0.0}" :"$SERVER_ADDRESS/api/nearbydoctor?lat=${latitude}&lon=${longitude}"))
        .catchError((e) {
      setState(() {
        isErrorInNearby = true;
      });
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
    });
    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse.toString());
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      //print([0].name);
      setState(() {
        lat = latitude.toString();
        lon = longitude.toString();
        nearbyDoctorsClass = NearbyDoctorsClass.fromJson(jsonResponse);
        print("Finished");
        list.addAll(nearbyDoctorsClass!.data!.nearbyData!);
        nextUrl = nearbyDoctorsClass!.data!.nextPageUrl!;
        print(nextUrl);
        isNearbyLoading = false;
      });
    } else {
      setState(() {
        isErrorInNearby = true;
      });
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
    }
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(s1,style: Theme.of(context).textTheme.bodyText1),
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
                    var status = await Permission.location.status;
                    if (!status.isGranted && s1 == PERMISSION_NOT_GRANTED) {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.location,
                        Permission.storage,
                      ].request();
                      _getLocationStart();
                      // We didn't ask for permission yet or the permission has been denied before but not permanently.
                    }

//
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

  Future<bool?> _loadMoreFunc() async {
    if (nextUrl != "null") {
      print('loading');
      final response = await get(
          Uri.parse("$nextUrl&lat=${lat}&lon=${lon}"));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        //print([0].name);
        setState(() {
          nearbyDoctorsClass = NearbyDoctorsClass.fromJson(jsonResponse);
          print("Finished");
          nextUrl = nearbyDoctorsClass!.data!.nextPageUrl!;
          print(nextUrl);
          list.addAll(nearbyDoctorsClass!.data!.nearbyData!);
        });
      }
    }
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
