import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:appcode3/modals/NearbyDoctorClass.dart';
import 'package:appcode3/views/AllNearby.dart';
import 'package:appcode3/views/DetailsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_native_admob/flutter_native_admob.dart';
// import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
// import 'package:loadmore/loadmore.dart';
// import 'package:paging/paging.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

String lat = "";
String lon = "";
String nextUrl = "";

List<NearbyData> list2 = [];
NearbyDoctorsClass? nearbyDoctorsClass;

class HomeScreenNearby extends StatefulWidget {
  ScrollController scrollController;

  HomeScreenNearby(this.scrollController);

  @override
  _HomeScreenNearbyState createState() => _HomeScreenNearbyState();
}

class _HomeScreenNearbyState extends State<HomeScreenNearby> {
  bool isErrorInNearby = false;
  bool isNearbyLoading = true;

  bool isLoadingMore = false;

  int maxPosition = 0;
  bool isLoadMoreEnable = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Loadmore here 62");
    _getLocationStart();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent) {
        print("Loadmore");
        _loadMoreFunc();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return isErrorInNearby
        ? Container()
        : Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  nearByDoctors(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(NEARBY_DOCTORS,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .apply(fontWeightDelta: 3)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AllNearby()),
                        );
                      },
                      child: Text(SEE_ALL,
                          style: Theme.of(context).textTheme.bodyText1!.apply(
                                color: Theme.of(context).hintColor,
                              )),
                    )
                  ],
                ),
              ),
            ],
          );
  }

  Widget nearByDoctors() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 5),
      child: Column(
        children: [
          // isNearbyLoading ? Container(
          //   height: MediaQuery.of(context).size.height,
          //   width: MediaQuery.of(context).size.width,
          //   child: Column(
          //     children: [
          //       SizedBox(height: 150,),
          //       CircularProgressIndicator(),
          //     ],
          //   ),
          // ) :
          // list2 == null
          //     ? isErrorInNearby ? Container(
          //   child: Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         SizedBox(
          //           height: 30,
          //         ),
          //         Text(TURN_ON_LOCATION_AND_RETRY,
          //           style: GoogleFonts.poppins(
          //               color: Colors.black,
          //               fontWeight: FontWeight.w400,
          //               fontSize: 12
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ) : Center(
          //   child: CircularProgressIndicator(
          //     valueColor: AlwaysStoppedAnimation(Theme.of(context).hintColor),
          //     strokeWidth: 2,
          //   ),
          // )
          //     :
          /// Old With Ads
          // ListView.builder(
          //   shrinkWrap: true,
          //   physics: ClampingScrollPhysics(),
          //   itemCount: list.length > 4 ? (list.length/4).ceil() : 1,
          //   itemBuilder: (context, i){
          //     print((list.length/4).floor());
          //     print((list.length/4).ceil());
          //     // bool isFourMultiplay = list.length
          //     return Column(
          //       children: [
          //         GridView.builder(
          //           shrinkWrap: true,
          //           physics: ClampingScrollPhysics(),
          //           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          //               maxCrossAxisExtent: 200,
          //               childAspectRatio: 0.75,
          //               crossAxisSpacing: 10,
          //               mainAxisSpacing: 10),
          //           itemCount: 4,
          //           itemBuilder: (BuildContext ctx, index) {
          //               return index + (i*4) > list.length - 1 ? Container(color:Colors.pink) : nearByGridWidget(
          //                 list[index + (i*4)].image,
          //                 list[index + (i*4)].name,
          //                 list[index + (i*4)].departmentName,
          //                 list[index + (i*4)].id,
          //               );
          //           },
          //         ),
          //         ENABLE_ADS ? customAds.nativeAds(id: AD_TYPE) : Container(height: 10,),
          //       ],
          //     );
          //   },
          // ),

          /// New For Spacing Issue

          GridView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemCount: list2.length,
            itemBuilder: (BuildContext ctx, index) {
              var data = list2[index];
              return nearByGridWidget(
                data.image,
                data.name,
                data.departmentName,
                data.id,
              );
            },
          ),

          nextUrl == "null"
              ? Container()
              : Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: CircularProgressIndicator(),
                ),
          isLoadingMore
              ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: LinearProgressIndicator(),
                )
              : Container(
                  // height: 50,
                  height: 10,
                )
        ],
      ),
    );
  }

  Widget nearByGridWidget(img, name, dept, id) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
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
                      child: Image.asset(
                        "assets/homeScreenImages/user_unactive.png",
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, err) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Center(
                      child: Image.asset(
                        "assets/homeScreenImages/user_unactive.png",
                        height: 50,
                        width: 50,
                      ),
                    ),
                    //child: Padding(
                    //   padding: const EdgeInsets.all(20.0),
                    // )
                    //
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  color: BLACK, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              dept,
              style: GoogleFonts.poppins(
                  color: LIGHT_GREY_TEXT,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500),
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

    var status = await Permission.location.status;
    if (status.isDenied) {
      await [
        Permission.location,
      ].request();
    }
    status = await Permission.location.status;
    setState(() {

    });

    print("Here status ${status}");

    if (status.isGranted) {
      print("Here isGranted");
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      callApi(latitude: position.latitude, longitude: position.longitude);

    }  else if (status.isPermanentlyDenied) {
      print("Here isPermanentlyDenied");

      messageDialog(PERMISSION_NOT_GRANTED, "We required location permission to server you nearby doctors.");
      setState(() {
        isErrorInNearby = true;
      });
      _getLocationStart();
      return;
    } else if(status.isDenied) {
      print("Here is else part");
      messageDialog(PERMISSION_NOT_GRANTED, "We required location permission to server you nearby doctors.");
      setState(() {
        isErrorInNearby = true;
      });
    }
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

  int count = 0;

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
                  onPressed: () async {
                    var status = await Permission.location.status;
                    print("Status : ${status}");
                    if (!status.isGranted && s1 == PERMISSION_NOT_GRANTED) {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.location,
                      ].request();
                      print("statuses  --:  ${statuses[Permission.location]!.isDenied}");
                      if (statuses[Permission.location]!.isGranted) {
                        _getLocationStart();
                        // setState(() {
                        //   isErrorInNearby = false;
                        // });
                        print("call this function _getLocationStart");
                      }else if(count==0){
                        _getLocationStart();
                        count++;
                        setState(() {

                        });
                      }
          // else{
                      //   messageDialog(PERMISSION_NOT_GRANTED, "User denied permissions to access the device's location.");
                      // }
                      // We didn't ask for permission yet or the permission has been denied before but not permanently.
                    }


//
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

  _loadMoreFunc() async {
    if (nextUrl != "null") {
      print('loading : $lat');
      print("$nextUrl&lat=${lat}&lon=${lon}");
      print("object   === $nextUrl&lat=${lat}&lon=${lon}");

      final response = await get(Uri.parse("$nextUrl&lat=${lat}&lon=${lon}"));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        //print([0].name);
        setState(() {
          nearbyDoctorsClass = NearbyDoctorsClass.fromJson(jsonResponse);
          print("Finished");
          nextUrl = nearbyDoctorsClass!.data!.nextPageUrl!;
          print(nextUrl);
          list2.addAll(nearbyDoctorsClass!.data!.nearbyData!);
        });
      }
    }
  }
}
