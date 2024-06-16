import 'dart:convert';
import 'dart:math';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/SpecialityClass.dart';
import 'package:appcode3/views/SpecialityDoctorsScreen.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class SpecialityScreen extends StatefulWidget {
  @override
  _SpecialityScreenState createState() => _SpecialityScreenState();
}

class _SpecialityScreenState extends State<SpecialityScreen> {

  SpecialityClass? specialityClass;
  bool isLoading = true;
  bool isErrorInLoading = false;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();
  List<Speciality> list = [];
  String? nextUrl = "";

  getSpeciality() async{
    setState(() {
      isLoading = true;
    });
    print(Uri.parse("$SERVER_ADDRESS/api/getspeciality"));
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/getspeciality")).catchError((e){
      setState(() {
        isErrorInLoading = true;
      });
    });

    print(response.request);

    try {
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        specialityClass = SpecialityClass.fromJson(jsonResponse);
        print(specialityClass!.data!.length);
        setState(() {
          list.addAll(specialityClass!.data!);
          nextUrl = null; //specialityClass.data.links.last.url;
          isLoading = false;
        });
      }
    }catch(e){
      setState(() {
        isErrorInLoading = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSpeciality();
    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        print("Loadmore");
        //_loadMoreFunc();
        if(nextUrl != null && !isLoadingMore) {
          loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    scrollController.dispose();
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        appBar: AppBar(
          flexibleSpace: header(),
          leading: Container(),
        ),
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
            ) : isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
          : specialityList(),
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
                SPECIALITY,
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

  Widget specialityList(){
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [

          ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: list.length > 4 ? (list.length/4).ceil() : 1,
            itemBuilder: (context, i){
              print((list.length/4).ceil());
              print((list.length/4).floor());
              return Column(
                children: [
                  GridView.count(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    physics: ClampingScrollPhysics(),
                    children: List.generate(4, (index){
                      //Color x = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
                      return InkWell(
                        onTap: (){
                          if(index + (i*4) <= list.length - 1) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>
                                SpecialityDoctorsScreen(
                                  list[index + (i * 4)].id.toString(),
                                  ""
                                ),
                            ));
                          }
                        },
                        child: index + (i*4) > list.length - 1 ? Container() : Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    "assets/specialityScreenImages/speciality_bg.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      //color: x.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.all(13),
                                    child: Image.network(
                                      list[index + (i*4)].icon!,
                                      height: 50,
                                      width: 50,
                                      //color: x,
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Text(
                                    list[index + (i*4)].name!,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: BLACK,
                                        fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    list[index + (i*4)].totalDoctors.toString() + " specialist",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: LIGHT_GREY_TEXT,
                                        fontSize: 13
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  ENABLE_ADS ? customAds.nativeAds(id: AD_TYPE) : Container(height: 0,),
                ],
              );
            },
          ),

          isLoadingMore
              ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
              )
              : Container(),
        ],
      ),
    );
  }

  loadMore() async {
    if (nextUrl != null) {
      print(isLoadingMore);
      setState(() {
        isLoadingMore = true;
      });

      print(nextUrl);

      final response = await get(Uri.parse(nextUrl!));
       if (response.statusCode == 200) {
         final jsonResponse = jsonDecode(response.body);
         specialityClass = SpecialityClass.fromJson(jsonResponse);
         print(specialityClass!.data!.length);
        setState(() {
          nextUrl = jsonResponse["next_page_url"];
          list.addAll(specialityClass!.data!);
          print("-> Added to list");
          isLoadingMore = false;
        });
       }
    }
  }


}
