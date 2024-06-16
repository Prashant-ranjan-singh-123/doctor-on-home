import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/ReviewsClass.dart';
import 'package:appcode3/views/loginAsUser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewsScreen extends StatefulWidget {

  String id;

  ReviewsScreen(this.id);

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {

  int starCount = 0;
  String message = "";
  String? user_id = "";
  String doctor_id = "";
  String description = "";
  bool showSheet = false;
  ReviewsClass? reviewsClass;
  TextEditingController textEditingController = TextEditingController();
  Future? _future;
  bool isReviewExist = false;
  bool isLoggedIn = false;

  fertchReviews() async{
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/reviewlistbydoctor?doctor_id=${widget.id}")).catchError((e){
      setState(() {
        isReviewExist = false;
      });
    });
    if(response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == 1) {
        setState(() {
          reviewsClass = ReviewsClass.fromJson(jsonResponse);
          isReviewExist = true;
        });
      }else{
        setState(() {
          isReviewExist = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((pref){
      setState(() {
        isLoggedIn = pref.getBool("isLoggedIn") ?? false;
        user_id = pref.getString("userId");
        _future = fertchReviews();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: header(),
          leading: Container(),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: FutureBuilder(
                  future: _future,
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Container(
                        height: MediaQuery.of(context).size.height - 100 ,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if(snapshot.connectionState == ConnectionState.done && isReviewExist){
                      return Column(
                        children: [
                          reviewsList(),
                          SizedBox(height: 80,),
                        ],
                      );
                    }else{
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(No_REVIEWS),
                        ),
                      );
                    }
                  }),
            ),
            showSheet ? InkWell(
              onTap: (){
                setState(() {
                  showSheet = false;
                });
              },
                  child: Container(
              color: Colors.black38,
            ),
                ) : Container(),
            button(),
            bottomSheet(),
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
                REVIEW,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: WHITE,
                    fontSize: 22
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget button(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 50,
        margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
        //width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: (){
            if(isLoggedIn) {
              setState(() {
                showSheet = true;
              });
            }else{
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => LoginAsUser()
              ));
            }
           // bottomSheet();
            //Navigator.push(context, MaterialPageRoute(builder: (context) => MakeAppointment(widget.id, doctorDetailsClass.data.name)));
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset("assets/moreScreenImages/header_bg.png",
                  height: 50,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Center(
                child: Text(
                  isLoggedIn ? ADD_A_REVIEW : LOGIN_TO_ADD_REVIEW,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: WHITE,
                      fontSize: 18
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget reviewsList(){
    return ListView.builder(
        itemCount: reviewsClass!.data!.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index){
          return appointmentListWidget(
            index,
            reviewsClass!.data![index].name,
            reviewsClass!.data![index].rating,
            reviewsClass!.data![index].description,
            reviewsClass!.data![index].image,
          );
        });
  }

  Widget appointmentListWidget(i, name, rating, description, image) {
    return Container(
      margin: EdgeInsets.fromLTRB(10,10,10,10),
      //padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: image,
                  height: 50,
                  width: 50,placeholder: (context, url) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 30, width: 30,),
                ),),
                  errorWidget: (context,url,err) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 30, width: 30,),
                  )),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                            style: GoogleFonts.poppins(
                                color: BLACK,
                                fontSize: 16,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                int.parse(rating) >= 1
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              ),
                              Image.asset(
                                int.parse(rating) >= 2
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              ),
                              Image.asset(
                                int.parse(rating) >= 3
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              ),
                              Image.asset(
                                int.parse(rating) >= 4
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              ),
                              Image.asset(
                                int.parse(rating) >= 5
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(description,
                   style: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontSize: 11,
                      fontWeight: FontWeight.w400
                  ),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 0.5,
            height: 20,
            color: LIGHT_GREY_TEXT,
          ),
        ],
      ),
    );
  }

  Widget submitReview(){
    return Container(
      height: 50,
      margin: EdgeInsets.fromLTRB(0, 30, 20, 0),
      //width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: (){
          uploadReview();
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset("assets/moreScreenImages/header_bg.png",
                height: 50,
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Center(
              child: Text(
                SUBMIT,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: WHITE,
                    fontSize: 18
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  uploadReview() async{
    dialog();
    final response = await post(Uri.parse("$SERVER_ADDRESS/api/addreview"),
      body: {
        "user_id" : user_id,
        "rating" : starCount.toString(),
        "doc_id" : widget.id,
        "description" : message,
      }
    ).catchError((e){
      Navigator.pop(context);
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      print(e);
    });
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      print(response.body);
      if(jsonResponse["success"] == 1){
        Navigator.pop(context);
        setState(() {
          textEditingController.text = "";
          starCount = 0;
          showSheet = false;
          _future = fertchReviews();
        });
      }else{
        Navigator.pop(context);
        messageDialog(ERROR, jsonResponse["register"]);
      }
    }
  }

  bottomSheet(){
    return Visibility(
      visible: showSheet,
      child: DraggableScrollableSheet(
          initialChildSize: 350/MediaQuery.of(context).size.height,
          maxChildSize: 350/MediaQuery.of(context).size.height,
          minChildSize: 350/MediaQuery.of(context).size.height,
          builder: (context, scrollController){
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(
              height: 350,
              color: WHITE,
              padding: EdgeInsets.all(15),
              child: Column(
                //mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ADD_A_REVIEW ,
                    style: GoogleFonts.poppins(
                        color: BLACK,
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text(
                    YOUR_RATING ,
                    style: GoogleFonts.poppins(
                        color: BLACK,
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 5,),
                  Row(
                    children: [
                      InkWell(
                        onTap: (){
                          setState(() {
                            starCount = 1;
                            print(starCount);

                          });
                        },
                        child: Image.asset(
                          starCount >= 1
                              ? "assets/detailScreenImages/star_fill.png"
                              : "assets/detailScreenImages/star_no_fill.png",
                          height: 25,
                          width: 25,
                        ),
                      ),
                      SizedBox(width: 3,),
                      InkWell(
                        onTap: (){
                          setState(() {
                            starCount = 2;
                            print(starCount);
                          });
                        },
                        child: Image.asset(
                          starCount >= 2
                              ? "assets/detailScreenImages/star_fill.png"
                              : "assets/detailScreenImages/star_no_fill.png",
                          height: 25,
                          width: 25,
                        ),
                      ),
                      SizedBox(width: 3,),
                      InkWell(
                        onTap: (){
                          setState(() {
                            starCount = 3;
                            print(starCount);
                          });
                        },
                        child: Image.asset(
                          starCount >= 3
                              ? "assets/detailScreenImages/star_fill.png"
                              : "assets/detailScreenImages/star_no_fill.png",
                          height: 25,
                          width: 25,
                        ),
                      ),
                      SizedBox(width: 3,),
                      InkWell(
                        onTap: (){
                          setState(() {
                            starCount = 4;
                            print(starCount);
                          });
                        },
                        child: Image.asset(
                          starCount >= 4
                              ? "assets/detailScreenImages/star_fill.png"
                              : "assets/detailScreenImages/star_no_fill.png",
                          height: 25,
                          width: 25,
                        ),
                      ),
                      SizedBox(width: 3,),
                      InkWell(
                        onTap: (){
                          setState(() {
                            starCount = 5;
                            print(starCount);
                          });
                        },
                        child: Image.asset(
                          starCount >= 5
                              ? "assets/detailScreenImages/star_fill.png"
                              : "assets/detailScreenImages/star_no_fill.png",
                          height: 25,
                          width: 25,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 10,),
                  TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      labelText: ENTER_YOUR_MESSAGE,
                      labelStyle: GoogleFonts.poppins(
                          color: LIGHT_GREY_TEXT,
                          fontWeight: FontWeight.w400
                      ),
                      border: UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: LIGHT_GREY_TEXT)
                      ),
                      //errorText: isNameError ? "Enter your name" : null,
                    ),
                    style: GoogleFonts.poppins(
                        color: BLACK,
                        fontWeight: FontWeight.w500
                    ),
                    onChanged: (val){
                      setState(() {
                        message = val;
                        //isNameError = false;
                      });
                    },
                  ),
                  submitReview(),
                ],
              ),
            ),
          );
          },
      ),
    );
  }

  dialog(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(UPLOADING_REVIEW,
              style: GoogleFonts.poppins(),
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(WAIT_FOR_A_WHILE,
                      style: GoogleFonts.poppins(
                          fontSize: 12
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(s1,style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.bold,
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: GoogleFonts.poppins(
                  fontSize: 14,
                ),)
              ],
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                // color: Theme.of(context).primaryColor,
                child: Text(OK,style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: BLACK,
                ),),
              ),
            ],
          );
        }
    );
  }



}
