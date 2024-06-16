import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/views/ReportIssuesScreen.dart';
import 'package:appcode3/views/SpecialityScreen.dart';
import 'package:appcode3/views/TermAndConditions.dart';
import 'package:appcode3/views/UserEditProfile.dart';
import 'package:appcode3/views/loginAsUser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectycube_sdk/connectycube_chat.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AboutScreen.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  List<String> list = [
    SPECIALIST,
    ABOUT,
    TERM_AND_CONDITIONS,
    REPORT_ISSUES,
    // 'Recent chats',
    LOGOUT
  ];

  String? userId;
  String? name;
  String? email;
  String? profileImage;
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  initialize() async {
    setState(() {
      isLoading = true;
    });
    await SharedPreferences.getInstance().then((pref) {
      setState(() {
        userId = pref.getString("userId");
        isLoggedIn = pref.getBool("isLoggedIn") ?? false;
        print(isLoggedIn);
        name = pref.getString("name");
        //pref.setString("phone", jsonResponse['register']['phone']);
        email = pref.getString("email");
        //pref.setString("token", token.toString());
        profileImage = pref.getString("profile_image");
      });
    }).then((x) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        body: isLoading
            ? LinearProgressIndicator()
            : Column(
                children: [
                  header(),
                  profile(),
                  SizedBox(
                    height: 5,
                  ),
                  options(),
                  //_getAdContainer(),
                ],
              ),
      ),
    );
  }

  Widget header() {
    return Stack(
      children: [
        Image.asset(
          "assets/moreScreenImages/header_bg.png",
          height: 60,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          height: 60,
          child: Row(
            children: [
              SizedBox(
                width: 15,
              ),

              // InkWell(
              //   onTap: (){
              //
              //   },
              //   child: Image.asset("assets/moreScreenImages/back.png",
              //     height: 25,
              //     width: 22,
              //   ),
              // ),
              // SizedBox(width: 10,),

              Text(
                MORE,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 22),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget profile() {
    return Stack(
      children: [
        Container(
          child: Image.network(
              "https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1189&q=80",
              height: 130,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover),
          foregroundDecoration: BoxDecoration(color: Colors.black45),
        ),
        Container(
          height: 130,
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 15,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: CachedNetworkImage(
                  imageUrl: isLoggedIn
                      ? profileImage == null
                          ? " "
                          : profileImage!
                      : " ",
                  //imageUrl: " ",
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
                child: InkWell(
                  onTap: () {
                    SharedPreferences.getInstance().then((value) {
                      value.setString("isBack", "0");
                    });
                    if (!isLoggedIn) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginAsUser()));
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLoggedIn ? name.toString() : SIGN_IN,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: WHITE,
                            fontSize: 17),
                      ),
                      Text(
                        isLoggedIn ? email! : SIGN_IN_TO_CONTINUE,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: WHITE,
                            fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ),
              isLoggedIn
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserEditProfile(
                                      "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1050&q=80"),
                                ));
                            // initialize();
                          },
                          child: Image.asset(
                            "assets/moreScreenImages/edit.png",
                            height: 23,
                            fit: BoxFit.fill,
                            width: 23,
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                width: 15,
              ),
            ],
          ),
        )
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

  Widget options() {
    return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        itemCount: isLoggedIn ? list.length : list.length - 2,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              // if(index == 5){
              //   Navigator.push(context, MaterialPageRoute(
              //     builder: (context) => SpecialityScreen(),
              //   ));
              // }
              if (index == 3) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportIssuesScreen(),
                    ));
              }
              // if(index == 3){
              //   Navigator.push(context, MaterialPageRoute(
              //     builder: (context) => HelpCenter(),
              //   ));
              // }
              if (index == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermAndConditions(),
                    ));
              }
              if (index == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutScreen(),
                    ));
              }
              if (index == 0) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecialityScreen(),
                    ));
              }
              // if(index == 4){
              //   Navigator.push(context, MaterialPageRoute(
              //     builder: (context) => ChatListScreen(),
              //   ));
              // }
              if (index == 4) {
                print(index);
                try {
                  CubeChatConnection.instance.logout();
                } catch (e) {}
                await SharedPreferences.getInstance().then((pref) {
                  pref.setBool("isLoggedInAsDoctor", false);
                  pref.setBool("isLoggedIn", false);
                  // pref.setString("userId", null);
                  // pref.setString("name", null);
                  // pref.setString("phone", null);
                  // pref.setString("email", null);
                  // pref.setString("password", null);
                  // pref.setString("token", null);
                  // pref.setString("profile_image", null);
                  pref.clear();
                });
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => TabsScreen()));
              }
            },
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      list[index],
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          color: BLACK,
                          fontSize: 13),
                    ),
                    Image.asset(
                      "assets/moreScreenImages/detail_arrow.png",
                      height: 15,
                      fit: BoxFit.fill,
                      width: 15,
                    ),
                  ],
                ),
                SizedBox(
                  height: 7,
                ),
                Divider(
                  thickness: 0.3,
                  color: LIGHT_GREY_TEXT,
                ),
              ],
            ),
          );
        });
  }
}
