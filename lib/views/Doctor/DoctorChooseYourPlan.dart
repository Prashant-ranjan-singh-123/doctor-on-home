import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' hide MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../en.dart';
import '../../main.dart';
import 'package:http/http.dart' as http hide MultipartFile;
import '../../modals/GetSubscriptionPlanClass.dart';
import '../my_photo_viewer.dart';
import 'DoctorTabScreen.dart';
import 'InAppWebiewSubscribtionScreen.dart';

class DoctorChooseYourPlan extends StatefulWidget {
  final String doctorUrl;

  const DoctorChooseYourPlan({Key? key, required this.doctorUrl})
      : super(key: key);

  @override
  State<DoctorChooseYourPlan> createState() => _DoctorChooseYourPlanState();
}

class _DoctorChooseYourPlanState extends State<DoctorChooseYourPlan> {
  String? userName;
  String? email;
  String? phone;
  String doctorImageUrl = '';
  String? userId;
  bool isErrorInLoading = false;
  GetSubscriptionPlanClass? getSubscriptionPlanClass;
  Future? future;
  File? _image;
  final picker = ImagePicker();
  int? selectedSubId = 1;
  int? selectedAmount;
  int? selectedAmount1;
  int? selectCard;
  int selectedIndex = 0;
  int uploadPer = 0;

  // late Razorpay _razorpay;

  TextEditingController _tcDes = TextEditingController();

  List<String> containerBg = [
    'assets/doctorSubscriptionPage/week-bg.png',
    'assets/doctorSubscriptionPage/month-bg.png',
    'assets/doctorSubscriptionPage/year-bg.png',
  ];

  List<String> planIcon = [
    'assets/doctorSubscriptionPage/week-icon.png',
    'assets/doctorSubscriptionPage/month-icon.png',
    'assets/doctorSubscriptionPage/year-icon.png',
  ];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        userName = pref.getString("name") ?? USER;
        phone = pref.getString('phone');
        email = pref.getString('email');
        doctorImageUrl = widget.doctorUrl;
        ///------ doctor id with get api call ---------
        userId = pref.getString("userId") ?? "";
        future = fetchPlanDetail();
      });
    });
  }
///--------- get plan api ---------
  fetchPlanDetail() async {
    print(
        'fetch package url ------------------------------> ${'$SERVER_ADDRESS/api/get_subscription_list'}');
    final response =
    await get(Uri.parse("$SERVER_ADDRESS/api/get_subscription_list"))

        .catchError((e) {
      setState(() {
        isErrorInLoading = true;
      });
    });
    print('fetch plane------------api -------------${Uri.parse("$SERVER_ADDRESS/api/get_subscription_list")}');
    try {
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          getSubscriptionPlanClass =
              GetSubscriptionPlanClass.fromJson(jsonResponse);
          selectedAmount1 = getSubscriptionPlanClass!.data!.data![0].price;

        });
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        isErrorInLoading = true;
      });
    }
  }
  int? id;
  int? price;
  int? price2;
  int? index;
  String? currency;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xffEEEEEE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  // color: Colors.cyanAccent,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            // 'assets/doctorSubscriptionPage/header-bg.png'),
                              'assets/moreScreenImages/header_bg.png'),
                          fit: BoxFit.cover)),
                  height: 100,
                ),
                Container(
                  margin: EdgeInsets.only(top: 50),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      // Image.asset(
                      //   'assets/doctorSubscriptionPage/user.png',
                      //   height: 110,
                      // ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: doctorImageUrl,
                          height: 100,
                          width: 100,
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
                      SizedBox(height: 5,),
                      Text(
                        '$HELLO_DR$userName',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .apply(fontSizeFactor: 1.2, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Positioned(
                //     top: 50,
                //     left: 20,
                //     child: InkWell(
                //       onTap: () {
                //         Navigator.pop(context);
                //       },
                //       child: Image.asset(
                //         'assets/doctorSubscriptionPage/arrow.png',
                //         height: 15,
                //       ),
                //     ))
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              CHOOSE_YOUR_PLAN,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .apply(fontSizeFactor: 1.2, fontWeightDelta: 2,color: Color(0xff030303)),
            ),
            SizedBox(
              height: 5,
            ),
            isErrorInLoading
                ? Container(
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
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      UNABLE_TO_LOAD_DATA_FORM_SERVER,
                    )
                  ],
                ),
              ),
            )
                : FutureBuilder(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      userId == null) {
                    return Container(
                        height: 300.0,
                        // height: 100,
                        child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )));
                  }
                  // return Container(
                  //   child: ListView.builder(
                  //     // scrollDirection: Axis.horizontal,
                  //     padding: EdgeInsets.zero,
                  //     physics: NeverScrollableScrollPhysics(),
                  //     itemCount: 4,
                  //     shrinkWrap: true,
                  //     itemBuilder: (context, index) {
                  //
                  //       var data =
                  //       getSubscriptionPlanClass!.data!.data![index];
                  //       return Container(
                  //         margin: EdgeInsets.symmetric(vertical: 0),
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 14, vertical: 2),
                  //         height: 180,
                  //         width: double.infinity,
                  //         decoration: BoxDecoration(
                  //           // color: Colors.pink,
                  //           image: DecorationImage(
                  //               image: AssetImage(
                  //                 containerBg[index % containerBg.length],
                  //               ),
                  //               fit: BoxFit.fill),
                  //         ),
                  //         child: Row(
                  //           children: [
                  //             Expanded(
                  //               child: Container(
                  //                 child: Column(
                  //                   mainAxisAlignment:
                  //                   MainAxisAlignment.center,
                  //                   children: [
                  //                     Image.asset(
                  //                       planIcon[index % planIcon.length],
                  //                       height: 35,
                  //                     ),
                  //                     SizedBox(
                  //                       height: 5,
                  //                     ),
                  //                     Text('${data.month} $MONTH'),
                  //                   ],
                  //                 ),
                  //               ),
                  //             ),
                  //             Expanded(
                  //               flex: 3,
                  //               child: Container(
                  //                 child: Column(
                  //                   mainAxisAlignment:
                  //                   MainAxisAlignment.center,
                  //                   crossAxisAlignment:
                  //                   CrossAxisAlignment.start,
                  //                   children: [
                  //                     Align(
                  //                       alignment: Alignment.center,
                  //                       child: RichText(
                  //                         text: TextSpan(
                  //                           text:
                  //                           '${getSubscriptionPlanClass!.data!.currency}${data.price}/',
                  //                           style: Theme.of(context)
                  //                               .textTheme
                  //                               .subtitle1
                  //                               !.apply(
                  //                               color: Colors.white,
                  //                               fontSizeFactor: 2.2,
                  //                               fontWeightDelta: 2),
                  //                           children: <TextSpan>[
                  //                             TextSpan(
                  //                               text: MONTH.toLowerCase(),
                  //                               style: Theme.of(context)
                  //                                   .textTheme
                  //                                   .subtitle1
                  //                                   !.apply(
                  //                                   color: Colors.white,
                  //                                   fontSizeFactor: 1.5,
                  //                                   fontWeightDelta: 1),
                  //                             ),
                  //                           ],
                  //                         ),
                  //                       ),
                  //                     ),
                  //                     PackageBenifit(
                  //                       text: Dummy1,
                  //                     ),
                  //                     SizedBox(
                  //                       height: 5,
                  //                     ),
                  //                     PackageBenifit(
                  //                       text: Dummy2,
                  //                     ),
                  //                     SizedBox(
                  //                       height: 10,
                  //                     ),
                  //                     Align(
                  //                       alignment: Alignment.bottomRight,
                  //                       child: GestureDetector(
                  //                         onTap: () {
                  //                           selectedSubId = data.id;
                  //                           selectedAmount = data.price;
                  //                           // uploadingDialog();
                  //                           bottomSheet(
                  //                               getSubscriptionPlanClass
                  //                                   !.data!.currency,
                  //                               getSubscriptionPlanClass
                  //                                   !.data
                  //                                   !.data![index]
                  //                                   .price);
                  //                         },
                  //                         child: Container(
                  //                           margin: EdgeInsets.only(
                  //                               right: 10, top: 10),
                  //                           child: Text(
                  //                             CHOOSE_BTN,
                  //                             style: TextStyle(
                  //                                 color: Colors.black),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     )
                  //                   ],
                  //                 ),
                  //                 // color: Colors.green.withOpacity(0.3),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // );
                  ///--------------------
                  return Container(
                    margin: EdgeInsets.only(top: 20),

                    // margin: const EdgeInsets.symmetric(vertical: 0.0),
                    padding: EdgeInsets.only(left: 20),
                    // padding: const EdgeInsets.symmetric(horizontal: 20),
                    // height: 265.0,
                    height: 300.0,
                    // color: Colors.red,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (ctx, index) {
                        var data = getSubscriptionPlanClass!.data!.data![index];
                        // selectedSubId = data.id;
                        //   selectedAmount1 = data.price;
                        // id=data.id;
                        // price2=data.price;
                        price= getSubscriptionPlanClass
                        !.data
                        !.data![index]
                            .price;
                        print("selectedAmount $selectedAmount1");
                        return GestureDetector(
                          onTap: () {

                            setState(() {
                              selectedIndex = index;
                              // selectCard = index;
                              // selectedAmount = data.price;
                              selectedAmount1 = getSubscriptionPlanClass!.data!.data![index].price;

                              selectedSubId = data.id;


                            });
                            print("selectedSubId ${data.id}");
                            print("selectedSubId ${selectedSubId}");
                            // id=selectedSubId;
                            // price2=selectedAmount;
                            price = getSubscriptionPlanClass!.data!.data![index].price;

                            print('print price ----------------------${price}');
                            // getSubscriptionPlanClass
                            // !.data!.currency,
                            // purchase(data.id!.toInt(),data.price,index) ;
                            // Navigator.of(context).pushNamed(CourseDetailScreen.routeName, arguments: id);
                          },
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                height: 230.0,
                                width: 200,

                                child: Padding(
                                  padding:
                                  const EdgeInsets.only(right: 5.0),
                                  child: Card(
                                    // color: selectedIndex == index
                                    //     ? Color(0xff00D8C9)
                                    //     : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    child: Container(
                                      // width: width / 1.2,
                                      // height: height / 6,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            selectedIndex == index?Color(0xff00D8C9):Colors.white,
                                            selectedIndex == index?Color(0xff2FA3AB):Colors.white,
                                          ],
                                          begin: Alignment.topCenter,
                                          //begin of the gradient color
                                          end: Alignment.bottomCenter,
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 22),
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: 27),
                                              child: Text(
                                                  index == 0
                                                      ? '$Monthly'
                                                      : index == 1
                                                      ? '$Quarterly'
                                                      : index == 2
                                                      ? '$HalfYear'
                                                      : '$Yearly',
                                                  style: TextStyle(
                                                      color:
                                                      selectedIndex ==
                                                          index
                                                          ? Colors
                                                          .white
                                                          : Color(0xff707070),
                                                      fontSize: 23,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold)),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 22),
                                            child: RichText(
                                              text: TextSpan(
                                                text:
                                                '\$${data.price}/',
                                                // '${getSubscriptionPlanClass!.data!.currency}${data.price}/',
                                                style: Theme.of(
                                                    context)
                                                    .textTheme
                                                    .subtitle1!
                                                    .apply(
                                                    color: selectedIndex ==
                                                        index
                                                        ? Colors
                                                        .white
                                                        : Colors
                                                        .black,
                                                    fontSizeFactor:
                                                    1.6,
                                                    fontWeightDelta:
                                                    2),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: index == 0
                                                        ? '${data.month} ' +
                                                        Month
                                                            .toLowerCase()
                                                        : index == 1
                                                        ? '${data.month} ' +
                                                        Month
                                                            .toLowerCase()
                                                        : index ==
                                                        2
                                                        ? '${data.month} ' +
                                                        Month
                                                            .toLowerCase()
                                                        : '${data.month} ' +
                                                        Month
                                                            .toLowerCase(),
                                                    style: Theme.of(
                                                        context)
                                                        .textTheme
                                                        .subtitle1!
                                                        .apply(
                                                        color: selectedIndex ==
                                                            index
                                                            ? Colors
                                                            .white
                                                            : Colors
                                                            .black,
                                                        fontSizeFactor:
                                                        1.0,
                                                        fontWeightDelta:
                                                        9),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 20),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      size: 20,
                                                      color:  Color(0xffDDDDDD),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        SavePercentage,
                                                        // maxLines: 2,
                                                        style: Theme
                                                            .of(
                                                            context)
                                                            .textTheme
                                                            .subtitle1!
                                                            .apply(
                                                            color: Colors.black54,
                                                            // color:
                                                            // Color(0xffDDDDDD),
                                                            fontSizeFactor:
                                                            0.8,
                                                            fontWeightDelta:
                                                            1),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          // PackageBenifit(
                                          //   index: index,
                                          //   text: Dummy1,
                                          // ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 20),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      size: 20,
                                                      color:  Color(0xffDDDDDD),
                                                    ),
                                                    // Image.asset(
                                                    //   'assets/doctorSubscriptionPage/chack.png',
                                                    //   height: 15,color:Colors.white,
                                                    // ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            Gett,
                                                            // maxLines: 2,
                                                            style: Theme.of(context).textTheme.subtitle1!.apply(
                                                                color: Colors.black54,
                                                                // color:
                                                                // Color(0xffDDDDDD),
                                                                fontSizeFactor:
                                                                0.8,
                                                                fontWeightDelta:
                                                                1),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            Days,
                                                            // maxLines: 2,
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .subtitle1!
                                                                .apply(
                                                                color: selectedIndex == index ? Colors.white : Colors.black,
                                                                fontSizeFactor: 0.8,
                                                                fontWeightDelta: 6),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            Free,
                                                            // maxLines: 2,
                                                            style: Theme.of(context).textTheme.subtitle1!.apply(
                                                                color: Colors.black54,
                                                                // color:
                                                                // Color(0xffDDDDDD),
                                                                fontSizeFactor:
                                                                0.8,
                                                                fontWeightDelta:
                                                                1),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                left: 20),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      size: 20,
                                                      color:  Color(0xffDDDDDD),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        Available,
                                                        // maxLines: 2,
                                                        style: Theme
                                                            .of(
                                                            context)
                                                            .textTheme
                                                            .subtitle1!
                                                            .apply(
                                                            color: Colors.black54,
                                                            // color:
                                                            // Color(0xffDDDDDD),
                                                            fontSizeFactor:
                                                            0.8,
                                                            fontWeightDelta:
                                                            1),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),

                                          ///========== chose plan -----------------
                                          //  Align(
                                          //    alignment: Alignment.bottomRight,
                                          //    child: GestureDetector(
                                          //      onTap: () {
                                          //        selectedSubId = data.id;
                                          //        selectedAmount = data.price;
                                          //        // uploadingDialog();
                                          //        bottomSheet(
                                          //            getSubscriptionPlanClass
                                          //            !.data!.currency,
                                          //            getSubscriptionPlanClass
                                          //            !.data
                                          //            !.data![index]
                                          //                .price);
                                          //      },
                                          //      child: Container(
                                          //        margin: EdgeInsets.only(
                                          //            right: 10, top: 10),
                                          //        child: Text(
                                          //          CHOOSE_BTN,
                                          //          style: TextStyle(
                                          //              color: selectedIndex == index?Colors.white:Colors.black,),
                                          //        ),
                                          //      ),
                                          //    ),
                                          //  )
                                        ],
                                      ),
                                      // child:                Positioned(
                                      //   bottom: 26,
                                      //   child:
                                      // )
                                      ///--------
                                      // child: Column(
                                      //   // mainAxisAlignment: MainAxisAlignment.start,
                                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: <Widget>[
                                      //
                                      //
                                      //   ],
                                      // ),
                                    ),
                                  ),
                                ),
                              ),
                              selectedIndex == index
                                  ? Container(
// height:65,
                                margin: EdgeInsets.only(left: 20),

                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xffFF835B),
                                        Color(0xffD4E183),
                                      ],
                                      begin: Alignment.topCenter,
                                      //begin of the gradient color
                                      end: Alignment
                                          .bottomCenter, //end of the gradient color
                                      // stops: [0, 0.2, 0.5, 0.8] //stops for individual color
                                      //set the stops number equal to numbers of color
                                    ),
                                    shape: BoxShape.circle),

                                // child: CircleAvatar(
                                //
                                //   radius: 20,
                                //   backgroundColor:selectedIndex == index?Color(0xffFF835B):Color(0xffFF835B).withOpacity(0.2),
                                //
                                //
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                //   // child: Icon(Icons.check_circle,color: selectedIndex == index?Colors.white:Colors.black,size: 30,),
                                // ),
                              )
                                  : Container()
                            ],
                          ),
                        );
                      },
                      itemCount: 4,
                    ),
                  );
                }),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                LongText,
                // maxLines: 2,
                style: Theme
                    .of(
                    context)
                    .textTheme
                    .subtitle1!
                    .apply(
                    color: Colors.black54,
                    // color:
                    // Color(0xffA6A6A6),
                    fontSizeFactor:
                    0.8,
                    fontWeightDelta:
                    0),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            ///---------- continue to purchase --------
            GestureDetector(
              onTap: () {
                // purchase();
                print('selected price data -----------------------${id}');
                print('selected price id -----------------------${price}');
                print('selected price id -----------------------${selectedSubId}');
                print('selected price id -----------------------${selectedAmount1}');
                if(selectedIndex==selectedIndex){
                  selectedSubId;
                  // price2;
                  selectedAmount;
                  bottomSheet(
                      getSubscriptionPlanClass!.data!.currency,
                      selectedAmount1,selectedSubId);
                }else{
                  print('not select');
                }

              },
              child: Container(
                height: 60,
                width: 330,
                decoration: BoxDecoration(
                    color: Color(0xff00D8C9),
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text('Continue To Purchase',style: TextStyle(
                    color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18
                ),),
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }


  int? selectedPaymentMethod = 0;

  bottomSheet(currency, amount, int? selectedSubId) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: WHITE, borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                userName! + "'s ",
                                style: TextStyle(
                                    color: BLACK,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              currency + (amount.toString()),
                              style: GoogleFonts.ubuntu(
                                  color: AMBER,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.7,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          SELECT_A_PAYMENT_METHOD.toUpperCase(),
                          style: TextStyle(
                              color: LIGHT_GREY_TEXT,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),

                      // paymentMethodCardTile(title: ONLINE, explanation: ONLINE_EXPLAIN, index: 3, setState: setState),
                      // Divider(
                      //   color: Colors.grey,
                      //   thickness: 0.7,
                      // ),
                      /// Braintree
                      // paymentMethodCardTile(
                      //     title: BRAINTREE,
                      //     explanation: BRAINTREE_EXPLANATION,
                      //     index: 0,
                      //     setState: setState),
                      // Divider(
                      //   color: Colors.grey,
                      //   thickness: 0.7,
                      // ),
                      /// Razorpay
                      // paymentMethodCardTile(title: RazorpayString, explanation: RAZORPAY_EXPLANATION, index: 2, setState: setState),
                      // Divider(
                      //   color: Colors.grey,
                      //   thickness: 0.7,
                      // ),
                      paymentMethodCardTile(
                          title: UPLOAD_RECEIPT,
                          explanation: UPLOAD_RECIPES_DES,
                          index: 1,
                          setState: setState),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.7,
                      ),
                      paymentMethodCardTile(
                          title: PAYSTACK,
                          explanation: ONLINE_EXPLAIN_BOOKING,
                          index: 3,
                          setState: setState),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.7,
                      ),
                      paymentMethodCardTile(
                          title: RAVE,
                          explanation: ONLINE_EXPLAIN_BOOKING,
                          index: 4,
                          setState: setState),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.7,
                      ),
                      paymentMethodCardTile(
                          title: PAYTM,
                          explanation: ONLINE_EXPLAIN_BOOKING,
                          index: 5,
                          setState: setState),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.7,
                      ),
                      paymentMethodCardTile(
                          title: BRAINTREE,
                          explanation: ONLINE_EXPLAIN_BOOKING,
                          index: 6,
                          setState: setState),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.7,
                      ),
                      paymentMethodCardTile(
                          title: RazorpayString,
                          explanation: ONLINE_EXPLAIN_BOOKING,
                          index: 7,
                          setState: setState),
                      Divider(
                        color: Colors.grey,
                        thickness: 0.7,
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                  //width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      // if(selectedPaymentMethod == 3){
                      //   onlinePayment();
                      // }
                      // // else if (selectedPaymentMethod == 0) {
                      // //   processBrainTreePaymentAndBookAppointment(amount);
                      // // }
                      // else if (selectedPaymentMethod == 1) {
                      //   showUploadRecipeSheet();
                      //   // uploadPaymentRecipe();
                      //   // processStripePaymentAndBookAppointment();
                      // }
                      // else if(selectedPaymentMethod == 2){
                      //   print('razorpay');
                      //   // openCheckout(amount);
                      // }
                      //
                      // else {
                      //   // bookAppointment(type: "cod");
                      // }

                      if (selectedPaymentMethod == 1) {
                        print('selectedpaymenttype----------------------------1 ${selectedPaymentMethod}');
                        showUploadRecipeSheet();
                      } else {
                        print('selectedpaymenttype----------------------------2 ${selectedPaymentMethod}');
                        uploadRecipe(paymentGetawaysId: selectedPaymentMethod);
                      }
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            "assets/moreScreenImages/header_bg.png",
                            height: 50,
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Center(
                          child: Text(
                            selectedPaymentMethod == 1
                                ? MAKE_AN_SUBSCRIBE
                                : PROCESS_PAYMENT,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: WHITE,
                                fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Razorpay

  // void openCheckout(amount) async {
  //   var options;
  //   if(email!=null && phone!=null){
  //     options = {
  //       'key': RAZORPAY_KEY,
  //       // 'currency': CURRENCY_CODE,
  //       'amount': amount*100,
  //       'name': '$userName',
  //       'prefill': {'contact': '$phone', 'email': '$email'},
  //       'description': 'Subscription Payment',
  //     };
  //   }else{
  //     options = {
  //       'key': RAZORPAY_KEY,
  //       // 'currency': CURRENCY_CODE,
  //       'amount': amount*100,
  //       'name': '$userName',
  //       'description': 'Subscription Payment',
  //     };
  //   }
  //
  //
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // Razorpay Event
  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   print('Razorpay payment success');
  //   print('order id ${response.orderId}');
  //   print('paymentId id ${response.paymentId}');
  //   print('signature id ${response.signature}');
  //   placeSubscription(nonce: response.paymentId);
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   messageDialog('Faild', 'Your razorpay payment fail');
  //   print('Razorpay payment fail');
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   print('Razorpay payment external wallet');
  //   print('External Wallet ${response.walletName}');
  //   // Fluttertoast.showToast(
  //   //     msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIos: 4);
  // }

  onlinePayment() {
    uploadRecipe();
  }

  // processBrainTreePaymentAndBookAppointment(amount) async {
  //   var request = BraintreeDropInRequest(
  //     tokenizationKey: TOKENIZATION_KEY,
  //     collectDeviceData: true,
  //     googlePaymentRequest: BraintreeGooglePaymentRequest(
  //       totalPrice: amount.toString(),
  //       currencyCode: CURRENCY_CODE,
  //       billingAddressRequired: false,
  //     ),
  //     paypalRequest: BraintreePayPalRequest(
  //       amount: amount.toString(),
  //       displayName: userName! + "'s Plan Payment",
  //     ),
  //     cardEnabled: true,
  //   );
  //   final result = await BraintreeDropIn.start(request);
  //   if (result != null) {
  //     // print('result pass value');
  //     // print(result.paymentMethodNonce.nonce);
  //     // print('-----------------');
  //     placeSubscription(nonce: result.paymentMethodNonce.nonce);
  //     // bookAppointment(nonce: result.paymentMethodNonce.nonce, type: "1");
  //   }
  // }
///-------- card all payment -------------
  paymentMethodCardTile(
      {String? title,
        String? explanation,
        int? index,
        required StateSetter setState}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () {
            setState(() {

              selectedPaymentMethod = index!;
              print('selectedpaymenttype----------------------------3 ${selectedPaymentMethod}');
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: LIGHT_GREY_TEXT),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: selectedPaymentMethod == index
                        ? AMBER
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style:
                      TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    Text(
                      explanation!,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: LIGHT_GREY_TEXT),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );

  /// place subscription use to Place Subscription on api
  placeSubscription({nonce}) async {
    print('selection sub id -----------------------------1 ${selectedSubId}');
    print('selection sub id -----------------------------2 ${id}');
    print('payment method -----------------------------2 ${nonce}');
    print('print place subscription call');
    dialog();
    var request = http.MultipartRequest(
        'POST', Uri.parse('$SERVER_ADDRESS/api/place_subscription'));
    print('placesubscription------------api -------------${Uri.parse('$SERVER_ADDRESS/api/place_subscription')}');
    request.fields.addAll({
      'doctor_id': userId!,
      'subscription_id':  selectedSubId.toString(),
      'amount': selectedAmount1.toString(),
      'payment_method_nonce': nonce
    });
    http.StreamedResponse response = await request.send();
    print('status code ${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      print('success ${jsonResponse['success']}');
      print('msg ${jsonResponse['msg']}');
      // print(jsonResponse['register']);
      if (jsonResponse['success'].toString() == "1") {
        print('success payment paypal');
        Navigator.pop(context);
        Navigator.pop(context);
        messageDialog('Success', jsonResponse['register']);
      } else {
        Navigator.pop(context);
        messageDialog('Faild', jsonResponse['msg']);
      }
    } else {
      print('coming in else');
      Navigator.pop(context);
      messageDialog(ERROR, response.reasonPhrase!);
      print('error place_subscription ${response.reasonPhrase}');
      // Navigator.pop(context);
    }
  }

  // Upload recipe

  // uploadRecipe() async {
  //   dialog();
  //   var request = http.MultipartRequest(
  //       'POST', Uri.parse('$SERVER_ADDRESS/api/subscription_upload'));
  //   request.fields.addAll({
  //     'doctor_id': userId,
  //     'subscription_id': selectedSubId.toString(),
  //     'amount': selectedAmount.toString(),
  //     'description' : _tcDes.text
  //   });
  //   request.files.add(
  //       await http.MultipartFile.fromPath('file', '${_image.path}'));
  //
  //   http.StreamedResponse response = await request.send();
  //   print('content length : ${request.contentLength}');
  //
  //   if (response.statusCode == 200) {
  //     final jsonResponse = jsonDecode(await response.stream.bytesToString());
  //     print(jsonResponse['success']);
  //     print(jsonResponse['msg']);
  //     if (jsonResponse['success'].toString() == "1") {
  //       // messageDialog('Success', jsonResponse['msg']);
  //       Navigator.pop(context);
  //       messageDialog('Success', jsonResponse['msg']);
  //       // Navigator.of(context, rootNavigator: true).pop();
  //     }
  //   } else {
  //     messageDialog(ERROR, response.reasonPhrase);
  //     print(response.reasonPhrase);
  //   }
  // }
  ///---------- payment  ------ 2 -------

  uploadRecipe( {int? paymentGetawaysId}) async {
    print('selection sub id -----------------------------1 ${selectedSubId}');
    print('selection sub id -----------------------------2 ${id}');
    print('payment type -----------------------------5 ${selectedPaymentMethod}');
    print('userId ----------------------------- ${userId}');
    print('selectedSubId ----------------------------- ${selectedSubId}');
    print('selectedAmount1 ----------------------------- ${selectedAmount1}');
    print('_tcDes.text ----------------------------- ${_tcDes.text}');

    int paymenType;

    if (selectedPaymentMethod == 1) {
      print('payment go to web view --------------------11111111');
      paymenType = 2;
    } else {
      print('payment go to web view --------------------22222222');
      paymenType = 1;
    }

    // print('selected payment type => $paymenType');
    ProgressDialog pd = ProgressDialog(context: context);
    // pd.show(
    //   progressValueColor: Color(0xff01d8c9),
    //   progressBgColor: Colors.grey.shade400,
    //   progressType: ProgressType.valuable,
    //   max: 100,
    //   msg: RECIPES_UPLOADING,);
    // String fileName;
    // if(paymenType==2){
    //   fileName = _image!.path.split('/').last;
    // }
    print('paymenttype-------------------${paymenType}');
    FormData data;
    if (paymenType == 2) {
      pd.show(
        progressValueColor: Color(0xff01d8c9),
        progressBgColor: Colors.grey.shade400,
        progressType: ProgressType.valuable,
        max: 100,
        msg: RECIPES_UPLOADING,
      );
      String fileName = _image!.path.split('/').last;
      data = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          _image!.path,
          filename: fileName,
        ),
        'doctor_id': userId,
        'subscription_id': selectedSubId.toString(),
        // 'subscription_id': selectedSubId.toString()=='null'?id.toString(): selectedSubId.toString(),
        'amount': selectedAmount1.toString(),
        'description': _tcDes.text,
        'payment_type': paymenType.toString(),
      });
    } else {
      print('paymenType $paymenType');
      dialog();
      data = FormData.fromMap({
        'doctor_id': userId,
        'subscription_id': selectedSubId.toString(),
        'amount': selectedAmount1.toString(),
        'description': _tcDes.text,
        'payment_type': paymenType.toString(),
      });
    }
    print(userId);
    print(id.toString());
    print(price2.toString());
    print(_tcDes.text);
    print('url ->--------------- ${'$SERVER_ADDRESS/api/subscription_upload'}');
    Dio dio = new Dio();
    dio.post(
      "$SERVER_ADDRESS/api/subscription_upload",
      data: data,
      onSendProgress: (int sent, int total) {
        if (paymenType == 2) {
          print("$sent $total");
        }
        int progress = (((sent / total) * 100).toInt());
        pd.update(value: progress - 5);
      },
    ).then((response) async {
      pd.update(value: 100);
      pd.close();
      print('upoad response = ${response.data}');
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(await response.data);
        print(jsonResponse['success']);
        print(jsonResponse['msg']);
        if (jsonResponse['success'].toString() == "1") {
          if (paymenType == 2) {
            print('payment succesfully ---------------------');
            messageDialog1('Success', jsonResponse['msg']);

            // Navigator.push(context, MaterialPageRoute (builder: (context)=>DoctorTabsScreen()));
            // Navigator.pop(context);
            print('msg payment ---------------------${jsonResponse['msg']}');
          } else {
            Navigator.pop(context);

            // String paymentLink = jsonResponse['url'];
            String finalid = jsonResponse['id'].toString();
            String? paymentLink;
            print('id of new ----------------------${id}');

            if (selectedPaymentMethod == 3) {
              paymentLink = '$SERVER_ADDRESS/paystack-payment?id=$finalid&type=2';
            } else if (selectedPaymentMethod == 4) {
              paymentLink = '$SERVER_ADDRESS/rave-payment?id=$finalid&type=2';
            } else if (selectedPaymentMethod == 5) {
              paymentLink = '$SERVER_ADDRESS/paytm-payment?id=$finalid&type=2';
            } else if (selectedPaymentMethod == 6) {
              paymentLink = '$SERVER_ADDRESS/braintree_payment?id=$finalid&type=2';
            } else if (selectedPaymentMethod == 7) {
              paymentLink = '$SERVER_ADDRESS/pay_razorpay?id=$finalid&type=2';
            } else {
              messageDialog(FAIL, FAIL_DES);
            }
            print(paymentLink);
            var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => InAppWebViewScreen(url: paymentLink ?? '',isDoctor: 0)));

            // var result = await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => InAppWebViewScreen(
            //           url: paymentLink ?? '',
            //         )));
            print('result is ++++++++++++++++++++++++++++----------> $result');
            if (result == 'success') {
              setState(() {
                messageDialog1('Success', 'Your payment success');
              });

              print('data-----------------web view dialogue -----------------');


            } else if (result == 'fail') {
              messageDialog('Fail', 'Your payment fail try again');
            }
            // else {
            //   messageDialog('Fail', 'Your payment fail try again');
            // }
          }
        }
      } else {
        messageDialog(ERROR, response.statusMessage!);
        print(response.statusMessage);
      }
    }).catchError((error) {
      print('catch errpr $error');
      // Navigator.pop(context);
      messageDialog(ERROR, SOMETHING_WRONG);
    });
  }

  messageDialog1(String s1, String s2) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              s1,
              style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute (builder: (context)=>DoctorTabsScreen()));
                  // Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                // color: Theme.of(context).primaryColor,
                child: Text(
                  OK,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                  ),
                ),
              ),
            ],
          );
        });
  }

  openWebpageLink(String url) async {
    //
    try {
      print('try call');
      ChromeSafariBrowser browser = new MyChromeSafariBrowser();
      await browser.open(
        url: Uri.parse(url),
        options: ChromeSafariBrowserClassOptions(
          android: AndroidChromeCustomTabsOptions(
            addDefaultShareMenuItem: false,
            enableUrlBarHiding: true,
          ),
          ios: IOSSafariOptions(
            barCollapsingEnabled: true,
          ),
        ),
      );
    } catch (error) {
      print('catch call');
      await launch(url);
    }
    //
    // refreshDataSet();
    print('refreshDataSet call');
  }

  dialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              PROCESSING,
              style: GoogleFonts.poppins(),
            ),
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
                      PLEASE_WAIT_WHILE_PROCESSING,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  messageDialog(String s1, String s2) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              s1,
              style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                // color: Theme.of(context).primaryColor,
                child: Text(
                  OK,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                  ),
                ),
              ),
            ],
          );
        });
  }

  // double heightOfModalBottomSheet = 700;
  ///---------- upload reciept dialog============

  showUploadRecipeSheet() {
    _image = null;
    _tcDes.clear();
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      context: context,
      // backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                // direction: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 5),
                    child: Text(
                      UPLOAD_RECIPE,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 5),
                    child: Text(
                      UPLOAD_RECIPE_DES,
                      style: TextStyle(color: LIGHT_GREY_TEXT, fontSize: 12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: TextField(
                      controller: _tcDes,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // hintText: ENTER_DES,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Stack(
                      children: [
                        _image == null
                            ? DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(12),
                          padding: EdgeInsets.all(6),
                          dashPattern: [5, 3, 5, 3],
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.all(Radius.circular(12)),
                            child: InkWell(
                              onTap: () async {
                                final pickedFile = await picker.getImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 25);

                                if (pickedFile != null) {
                                  setState(() {
                                    _image = File(pickedFile.path);
                                    print(_image!.path);
                                  });
                                  // Navigator.pop(context);
                                } else {
                                  print('No image selected.');
                                }
                              },
                              child: Container(
                                height: 150,
                                width: double.maxFinite,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 50,
                                        color: Colors.amber,
                                      ),
                                      Text(
                                        'Choose from gallery',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _image!,
                            height: 180,
                            fit: BoxFit.cover,
                            width: double.maxFinite,
                          ),
                        ),
                        Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              final pickedFile =
                                              await picker.getImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 25);

                                              if (pickedFile != null) {
                                                setState(() {
                                                  _image = File(pickedFile.path);
                                                  print(_image!.path);
                                                });
                                                // Navigator.pop(context);
                                              } else {
                                                print('No image selected.');
                                              }
                                            },
                                            icon: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                            ),
                                            iconSize: 20,
                                            constraints: BoxConstraints(
                                                maxHeight: 40, maxWidth: 40),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _image == null
                                        ? SizedBox()
                                        : Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              final pickedFile =
                                              await picker.getImage(
                                                  source:
                                                  ImageSource.gallery,
                                                  imageQuality: 25);

                                              if (pickedFile != null) {
                                                setState(() {
                                                  _image =
                                                      File(pickedFile.path);
                                                  print(_image!.path);
                                                });
                                                // Navigator.pop(context);
                                              } else {
                                                print('No image selected.');
                                              }
                                            },
                                            icon: Icon(
                                              Icons.photo,
                                              color: Colors.white,
                                            ),
                                            iconSize: 20,
                                            constraints: BoxConstraints(
                                                maxHeight: 40, maxWidth: 40),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _image == null
                                        ? SizedBox()
                                        : Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyPhotoView(
                                                            imagePath:
                                                            _image!.path,
                                                            isFromFile: true,
                                                          )));
                                            },
                                            icon: Icon(
                                              Icons.open_in_full,
                                              color: Colors.white,
                                            ),
                                            iconSize: 20,
                                            constraints: BoxConstraints(
                                                maxHeight: 40, maxWidth: 40),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  _image == null
                      ? SizedBox()
                      : Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Container(
                      height: 50,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _image = null;
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: LIGHT_GREY_TEXT.withOpacity(0.2),
                              ),
                            ),
                            Center(
                              child: Text(REMOVE_PRESCRIPTION,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .apply(
                                      color: Colors.black,
                                      fontSizeDelta: 2)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Container(
                      // margin: EdgeInsets.only(bottom: 30),
                      height: 50,
                      child: InkWell(
                        onTap: () {
                          if (_image != null && _tcDes.text.isNotEmpty) {
                            Navigator.pop(context);
                            uploadRecipe();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                "assets/moreScreenImages/header_bg.png",
                                height: 50,
                                fit: BoxFit.fill,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            Center(
                              child: Text(
                                  _image != null ? UPLOAD_PRESCRIPTION : CANCEL,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .apply(
                                      color:
                                      Theme.of(context).backgroundColor,
                                      fontSizeDelta: 2)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future getImage(bool isFromGallery) async {
    final pickedFile = await picker.getImage(
        source: isFromGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 25);

    setState(() {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          print(_image!.path);
        });
        // Navigator.pop(context);
      } else {
        print('No image selected.');
      }
    });
  }
}

class PackageBenifit extends StatelessWidget {
  PackageBenifit({
    Key? key,
    this.text,
    required this.index,
  }) : super(key: key);
  final text;
  int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/doctorSubscriptionPage/chack.png',
                height: 15,
                color: Colors.black,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  text,
                  // maxLines: 2,
                  style: Theme.of(context).textTheme.subtitle1!.apply(
                      color: Colors.black,
                      fontSizeFactor: 0.7,
                      fontWeightDelta: 1),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}
