import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/SearchDoctorClass.dart';
import 'package:appcode3/modals/SpecialityClass.dart';
import 'package:appcode3/views/DetailsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class SearchedScreen extends StatefulWidget {

  String keyword;

  SearchedScreen(this.keyword);

  @override
  _SearchedScreenState createState() => _SearchedScreenState();
}

class _SearchedScreenState extends State<SearchedScreen> {

  bool isSearching = false;
  bool isLoading = false;
  bool isErrorInLoading = false;
  SearchDoctorClass? searchDoctorClass;
  List<DoctorData> _newData = [];
  String nextUrl = "";
  bool isLoadingMore = false;
  String searchKeyword = "";
  ScrollController _scrollController = ScrollController();
  TextEditingController _textController = TextEditingController();
  SpecialityClass? specialityClass;
  List<String> departmentList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _onChanged(widget.keyword);
    _textController.text = widget.keyword;
    searchKeyword = widget.keyword;
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        //print("Loadmore");
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
    return Scaffold(
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
          ) : SingleChildScrollView(
            controller: _scrollController,
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).hintColor
                ),
              ),
            )
                : Column(
              children: [
                header(),
                upCommingAppointments(),
                isLoadingMore
                    ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                      SizedBox(width: 5,),
                      Text("Loading..."),
                    ],
                  ),
                )
                    : Container()
              ],
            ),
          ),
          header(),
        ],
      ),
    );
  }

  Widget upCommingAppointments(){
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 5),
      child: ListView.builder(
        itemCount: _newData.length,
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appointmentListWidget(
                _newData[index].image,
                _newData[index].name,
                _newData[index].departmentName.toString(),
                _newData[index].address,
                _newData[index].id,
              ),
              ENABLE_ADS ? (index+1)%4 == 0 && index != 0 ? customAds.nativeAds(id: AD_TYPE) : Container() : Container()
            ],
          );
        },
      ),
    );
  }

  Widget appointmentListWidget(img, name, department, address, id) {
    return InkWell(
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => DetailsPage(id.toString())),
        );
      },
      child: Container(
        //height: 90,
        margin: EdgeInsets.fromLTRB(0,0,0,10),
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
                imageUrl: img,
                height: 70,
                width: 70,
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
                        Text(name,
                          style: GoogleFonts.poppins(
                              color: BLACK,
                              fontSize: 13,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Text(department,
                          style: GoogleFonts.poppins(
                              color: BLACK,
                              fontSize: 11,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 10,),
                  Container(
                    child: Text(address.toString(),
                      style: GoogleFonts.poppins(
                          color: LIGHT_GREY_TEXT,
                          fontSize: 10,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10,),
          ],
        ),
      ),
    );
  }

  Widget header(){
    return Stack(
      children: [
        Image.asset(
          "assets/homeScreenImages/header_bg.png",
          height: 180,
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
                    Text("$SEARCH, ",
                      style: GoogleFonts.poppins(
                        color: WHITE,
                      ),
                    ),
                    Text(HERE,
                      style: GoogleFonts.poppins(
                          color: WHITE,
                          fontSize: 25,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        //margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: WHITE,
                        ),
                        child: TextField(
                          controller: _textController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: WHITE),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: SEARCH_DOCTOR_BY_NAME,
                              hintStyle: GoogleFonts.poppins(
                                  color: LIGHT_GREY_TEXT,
                                  fontSize: 13
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
                                          ? AlwaysStoppedAnimation(Theme.of(context).hintColor)
                                          : AlwaysStoppedAnimation(Colors.transparent),
                                    ),
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: WHITE),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: WHITE),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: WHITE),
                                borderRadius: BorderRadius.circular(15),
                              )
                          ),
                          onChanged: (val){
                            // setState(() {
                            //   searchKeyword = val;
                            //   _onChanged(val);
                            //   print(searchKeyword);
                            // });
                          },
                          onSubmitted: (val){
                            setState(() {
                              searchKeyword = val;
                              _onSubmit(val);
                            });
                          },
                        ),

                      ),
                    ),
                    SizedBox(width: 5,),
                    InkWell(
                      onTap: (){
                        _onSubmit(_textController.text);
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => SearchedScreen(_textController.text)));
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: WHITE,
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

  _onChanged(String value) async{

    if(value.length == 0){
      setState(() {
        _newData.clear();
        isErrorInLoading = false;
        isSearching = false;
        print("length 0");
        print(_newData);
      });
    }
    else {
      setState(() {
        isLoading = true;
        isSearching = true;
      });
      final response = await get(
          Uri.parse("$SERVER_ADDRESS/api/searchdoctor?term=$value"))
      .catchError((e){setState(() {
        isLoading = false;
        isErrorInLoading = true;
      });});
      try {
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
          //print([0].name);
          setState(() {
            _newData.clear();
            //print(searchDoctorClass.data.doctorData);
            _newData.addAll(searchDoctorClass!.data!.doctorData!);
            nextUrl = searchDoctorClass!.data!.links!.last.url!;
            print(nextUrl);
            isLoading = false;
          });
        }
      }catch(e){
        setState(() {
          isLoading = false;
          isErrorInLoading = true;
        });
      }
    }

  }

  _loadMoreFunc() async{
    if(nextUrl == null){
      return;
    }
    setState(() {
      isLoadingMore = true;
    });
    print(searchKeyword);
    final response = await get(
        Uri.parse("$nextUrl&term=$searchKeyword"));
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


  _onSubmit(String value) async{

    if(value.length == 0){
      setState(() {
        _newData.clear();

        isSearching = false;
        print("length 0");
        print(_newData);
      });
    }
    else {
      setState(() {
        isLoading = true;
        isSearching = true;
      });
      final response = await get(
          Uri.parse("$SERVER_ADDRESS/api/searchdoctor?term=$value"));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
        //print([0].name);
        setState(() {
          _newData.clear();
          //print(searchDoctorClass.data.doctorData);
          _newData.addAll(searchDoctorClass!.data!.doctorData!);
          nextUrl = searchDoctorClass!.data!.links!.last.url!;
          print(nextUrl);
          isLoading = false;
        });
      }
    }

  }



}
