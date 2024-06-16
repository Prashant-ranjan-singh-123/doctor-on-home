import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../en.dart';
import '../../../main.dart';
import '../../../modals/subscriptionlist_model.dart';
import 'package:http/http.dart' as http hide MultipartFile;


class SubScriptionScreen extends StatefulWidget {
  const SubScriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubScriptionScreen> createState() => _SubScriptionScreenState();
}

class _SubScriptionScreenState extends State<SubScriptionScreen> {

  String? docId;
  bool isErrorInLoading = false;

  Future? future;
  SubscriptionListModel? subscriptionListModel;
  List<DoctorsSubscription> info=[];
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

        ///------ doctor id with get api call ---------
        docId = pref.getString("userId") ?? "";
        fetchSubList();
      });
    });

  }

  ///--------- get plan api ---------
  fetchSubList() async {
    isErrorInLoading = true;
    print(
        'fetch package url ------------------------------> ${Uri.parse("$SERVER_ADDRESS/api/doctor_subscription_list?doctor_id=$docId")}');
    final response =
    // await get(Uri.parse("$SERVER_ADDRESS/api/doctor_subscription_list?doctor_id=2"))
    await get(Uri.parse("$SERVER_ADDRESS/api/doctor_subscription_list?doctor_id=$docId"))

        .catchError((e) {
      setState(() {
        isErrorInLoading = true;
      });
    });
    print(
        'fetch package url ------------------------------> ${Uri.parse("$SERVER_ADDRESS/api/doctor_subscription_list?doctor_id=$docId")}');
    try {
      if (response.statusCode == 200) {
        print('status----------${response.body}');
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          subscriptionListModel = SubscriptionListModel.fromJson(jsonResponse);
          print("subscriptionListModel ${subscriptionListModel}");
          info=subscriptionListModel!.data!.doctorsSubscription!;
          isErrorInLoading = false;
        });
      } else {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        isErrorInLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(

        child: Scaffold(
          // backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
          backgroundColor:Colors.red,
          appBar: AppBar(
            // automaticallyImplyLeading: false,
            flexibleSpace: header(),
          ),
          body: Container(
            color: LIGHT_GREY_SCREEN_BACKGROUND,
            child: isErrorInLoading?Center(child: CircularProgressIndicator(color: Colors.blue,)):ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: info.length,
              itemBuilder: (ctx, index) {

                return GestureDetector(
                  onTap: () {


                    // Navigator.of(context).pushNamed(CourseDetailScreen.routeName, arguments: id);
                  },
                  child: Container(
                    // margin: EdgeInsets.only(top: 20),
                    height: 120.0,
                    width: 300,




                    child: Padding(
                      padding:
                      const EdgeInsets.all(10),
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
                            // color: Color(0xffEEEEEE),
                            color: Colors.white,

                          ),
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Color(0xffEEEEEE).withOpacity(0.9),
                                    // color: LIGHT_GREY_SCREEN_BACKGROUND,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child:   Text(
                                    '\$${info[index].price}',
                                    // '${getSubscriptionPlanClass!.data!.currency}${data.price}/',
                                    style: Theme.of(
                                        context)
                                        .textTheme
                                        .subtitle1!
                                        .apply(
                                        color:  Colors
                                            .black,
                                        fontSizeFactor:
                                        1.6,
                                        fontWeightDelta:
                                        2),),

                                ),
                              ),
                              Container(
                                // margin: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.end,
                                      // crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${info[index].month} $Monthly', style: Theme.of(
                                            context)
                                            .textTheme
                                            .subtitle1!
                                            .apply(
                                            color:  Colors
                                                .black,
                                            fontSizeFactor:
                                            0.9,
                                            fontWeightDelta:
                                            1),),
                                        SizedBox(
                                          width: 80,
                                        ),
                                        Row(
                                          // mainAxisAlignment:
                                          // MainAxisAlignment
                                          //     .start,
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 13,
                                              color: info[index].status.toString()=='1'?Colors.blue
                                                  :info[index].status.toString()=='2'?Colors.green
                                              :info[index].status.toString()=='3'?Colors.grey:Colors.yellow,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              info[index].status.toString()=='1'?'Not Active'
                                                  :info[index].status.toString()=='2'?'Active'
                                                  : info[index].status.toString()=='3'?'Expire':'Reject',
                                              // maxLines: 2,
                                              style: Theme
                                                  .of(
                                                  context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .apply(
                                                  color: info[index].status.toString()=='1'?Colors.blue
                                                      :info[index].status.toString()=='2'?Colors.green
                                                      :info[index].status.toString()=='3'?Colors.grey:Colors.yellow,
                                                  // color:
                                                  // Color(0xffDDDDDD),
                                                  fontSizeFactor:
                                                  0.8,
                                                  fontWeightDelta:
                                                  2),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),

                                    Text('${info[index].date.toString().substring(0, 10)}'),

                                  ],
                                ),
                              ),



                            ],
                          ),
                       

                        ),
                      ),
                    ),
                  ),
                );
                // return Container(
                //   // height: 10,
                //   // width: 300,
                //   color: Colors.amber,
                //   child: Container(
                //
                //       child: Text('hello')),
                //
                // );
              },

            ),
          ),
        )
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
              SizedBox(width: 55,),
              Text(
                  'Subscription List',
                  style: Theme.of(context).textTheme.headline5!.apply(color: Theme.of(context).backgroundColor,
                      fontWeightDelta: 5
                  )
              )
            ],
          ),
        ),
      ],
    );
  }
}
