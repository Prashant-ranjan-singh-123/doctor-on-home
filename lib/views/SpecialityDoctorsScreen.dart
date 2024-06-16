import 'dart:convert';
import 'dart:io';

import 'package:appcode3/en.dart';
import 'package:appcode3/modals/NearbyDoctorClass.dart';
import 'package:appcode3/modals/SpecialityDoctorClass.dart';
import 'package:appcode3/views/DetailsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart';
// import 'package:loadmore/loadmore.dart';
// import 'package:paging/paging.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';


class SpecialityDoctorsScreen extends StatefulWidget {

  String id;
  String? name;
  SpecialityDoctorsScreen(this.id, this.name);

  @override
  _SpecialityDoctorsScreenState createState() => _SpecialityDoctorsScreenState();
}

class _SpecialityDoctorsScreenState extends State<SpecialityDoctorsScreen> {

  bool isErrorInNearby = false;
  bool isNearbyLoading = true;
  List<DoctorData> list = [];
  bool isLoadingMore = false;
  String nextUrl = "";
  double? lat;
  double? long;
  bool isErrorInLoading = false;
  SpecialityDoctorsClass? specialityDoctorsClass;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocationStart();

    _scrollController.addListener(() {
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoadingMore) {
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
        ) :SingleChildScrollView(
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
              Flexible(
                child: Text(
                  widget.name.toString() + " " + NEARBY_DOCTORS,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: WHITE,
                      fontSize: 22,
                  ),
                  overflow: TextOverflow.ellipsis,
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
            height: MediaQuery.of(context).size.height - 80,
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
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).hintColor
              ),
              strokeWidth: 2,
            ),
          )
              : GridView.builder(
            shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: list.length,
              itemBuilder: (BuildContext ctx, index) {
                return nearByGridWidget(
                  list[index].image,
                  list[index].name,
                  list[index].departmentName,
                  list[index].id,
                );
              }),
          isLoadingMore ? Padding(
            padding: const EdgeInsets.all(30.0),
            child: CircularProgressIndicator(),
          ) : Container()
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
      isNearbyLoading = true;
      isErrorInLoading = false;
    });
   if(Platform.isAndroid){
     Position? position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) async {
       final response = await get(
           Uri.parse("$SERVER_ADDRESS/api/getlistofdoctorbyspecialty?department_id=${widget.id}&lat=${value.latitude}&lon=${value.longitude}"));
       if (response.statusCode == 200) {
         final jsonResponse = jsonDecode(response.body);
         //print([0].name);
         setState(() {
           lat = value.latitude;
           long = value.longitude;
           specialityDoctorsClass =
               SpecialityDoctorsClass.fromJson(jsonResponse);
           print("Finished");
           if(specialityDoctorsClass!.data != null) {
             nextUrl = specialityDoctorsClass!.data!.nextPageUrl!;
             print(nextUrl);
             list.addAll(specialityDoctorsClass!.data!.doctorData!);
           }
           isNearbyLoading = false;
         });
       }
     }).catchError((e){
       //Toast.show(e.toString(), context,duration: 3);
       print(e);
       messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
       if(mounted){
         setState(() {
           isErrorInLoading = true;
           isErrorInNearby = true;
         });
       }

     });
   } else {
     final response = await get(
         Uri.parse("$SERVER_ADDRESS/api/getlistofdoctorbyspecialty?department_id=${widget.id}&lat=${0.0}&lon=${0.0}"));
     if (response.statusCode == 200) {
       final jsonResponse = jsonDecode(response.body);
       //print([0].name);
       setState(() {
         lat = 0.0;
         long = 0.0;
         specialityDoctorsClass =
             SpecialityDoctorsClass.fromJson(jsonResponse);
         print("Finished");
         if(specialityDoctorsClass!.data != null) {
           nextUrl = specialityDoctorsClass!.data!.nextPageUrl!;
           print(nextUrl);
           list.addAll(specialityDoctorsClass!.data!.doctorData!);
         }
         isNearbyLoading = false;
       });
     }
   }

  }


  Future<bool?> _loadMoreFunc() async {
    if (nextUrl != "null") {
      print('loading');
      setState(() {
        isLoadingMore = true;
      });
      final response = await get(
          Uri.parse("$nextUrl&department_id=${widget.id}&lat=$lat&lon=$long"));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        //print([0].name);
        setState(() {
          specialityDoctorsClass = SpecialityDoctorsClass.fromJson(jsonResponse);
          print("Finished");
          nextUrl = specialityDoctorsClass!.data!.nextPageUrl!;
          print(nextUrl);
          list.addAll(specialityDoctorsClass!.data!.doctorData!);
          isLoadingMore = false;
        });
      }
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
                    if (!status.isGranted) {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.location,
                        Permission.storage,
                      ].request();
                      print("status.isPermanentlyDenied ${status.isPermanentlyDenied}");
                      if(status.isPermanentlyDenied == false){
                        _getLocationStart();
                      }
                      // We didn't ask for permission yet or the permission has been denied before but not permanently.
                    }
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
