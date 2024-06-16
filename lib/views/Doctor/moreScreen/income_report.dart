import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/incomeReport.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*class IncomeReport extends StatefulWidget {
  const IncomeReport({super.key});

  @override
  State<IncomeReport> createState() => _IncomeReportState();
}

class _IncomeReportState extends State<IncomeReport> {
  String? doctorId;
  bool st = false;
  String showOption = "Today's";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        doctorId = pref.getString("userId");
        getIncomeReport("today");
      });
    });
  }

  getIncomeReport(String duration) async {
    setState(() {
      st = false;
    });
    print("Doctor Id -  ${doctorId}");
    final response = await post(Uri.parse("$SERVER_ADDRESS/api/income_report"),
        body: {'doctor_id': doctorId, 'duration': duration});
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      incomeReport = IncomeReportRes.fromJson(jsonDecode(response.body));
      st = true;
      setState(() {});
    }
  }

  IncomeReportRes incomeReport = IncomeReportRes();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        // appBar: AppBar(
        //   flexibleSpace: header(),
        // ),
        body: Column(
          children: [
            header(),
            SizedBox(
              height: 10,
            ),
            st
                ? incomeReport.success.toString() == "0" ?  Container(
              height: Get.height * 0.5,
              alignment: Alignment.center,
              child: Text("$showOption you have not any income."),
            ) : Expanded(
                    child: ListView.builder(
                    itemCount: incomeReport.data!.incomeRecord!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 50,
                        margin: EdgeInsets.fromLTRB(16, 5, 16, 5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${incomeReport.data!.incomeRecord![index].date}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                              Text(
                                "${incomeReport.data!.incomeRecord![index].amount} $CURRENCY",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ))
                : Container(
                    height: Get.height * 0.5,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(color: PRIMARY),
                  )
          ],
        ),
      ),
    );
  }

  DateTimeRange? selectedDateRange;

  void _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().add(Duration(days: -7)),
      end: DateTime.now().add(Duration(days: 7)),
    );

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: initialDateRange,
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      makeApi();
    }
  }

  makeApi(){
    print("Selected Date Range: ${selectedDateRange!.start.toString().substring(0,10)} to ${selectedDateRange!.end.toString().substring(0,10)}");
    showOption = "";
    setState(() {

    });
    getIncomeReport("${selectedDateRange!.start.toString().substring(0,10)},${selectedDateRange!.end.toString().substring(0,10)}");
  }

  Widget header() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10)),
          child: Image.asset(
            "assets/moreScreenImages/header_bg.png",
            height: 115,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                ),
                Text(INCOME_REPORT,
                    style: Theme.of(context).textTheme.headline5!.apply(
                        color: Theme.of(context).backgroundColor,
                        fontWeightDelta: 5))
              ],
            ),
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "$showOption total income",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      st ? incomeReport.success.toString() == "0" ? Text(
                        "0 $CURRENCY",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ) : Text(
                        "${incomeReport.data!.totalIncome} $CURRENCY",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ) : Container(),                    ],
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String selectedValue) {
                      print("${selectedValue}");
                      if(selectedValue == '1'){
                        setState(() {
                          showOption = "Today's";
                        });
                        getIncomeReport("today");
                      }
                      else if(selectedValue == '2'){
                        setState(() {
                          showOption = "Last 7 day's";
                        });
                        getIncomeReport("last 7 days");
                      }
                      else if(selectedValue == '3'){
                        setState(() {
                          showOption = "Last 30 day's";
                        });
                        getIncomeReport("last 30 days");
                      }
                      else if(selectedValue == '4'){
                        getIncomeReport("today");
                        _showDateRangePicker(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: '1',
                        child: Text('Today'),
                      ),
                      PopupMenuItem<String>(
                        value: '2',
                        child: Text('Last 7 days'),
                      ),
                      PopupMenuItem<String>(
                        value: '3',
                        child: Text('Last 30 days'),
                      ),
                      PopupMenuItem<String>(
                        value: '4',
                        child: Text('Select date range'),
                      ),
                      // Add more options as needed
                    ],
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 15, right: 8),
                      child: Row(
                        children: [
                          Text("Filter",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_drop_down_sharp),
                        ],
                      ),
                    )),
                  // Container(
                  //   height: 35,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     color: Colors.white,
                  //   ),
                  //   alignment: Alignment.center,
                  //   padding: EdgeInsets.only(left: 15,right: 8),
                  //   child: Row(
                  //     children: [
                  //       Text("Filter",
                  //           style: TextStyle(
                  //               fontSize: 18,
                  //               color: Colors.black,
                  //               fontWeight: FontWeight.w400)),
                  //       SizedBox(width: 8,),
                  //       Icon(Icons.arrow_drop_down_sharp)
                  //     ],
                  //   ),
                  // )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}*/

class IncomeReport extends StatefulWidget {
  const IncomeReport({super.key});

  @override
  State<IncomeReport> createState() => _IncomeReportState();
}

class _IncomeReportState extends State<IncomeReport> {
  String? doctorId;
  bool st = false;
  String showOption = "Today's";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        doctorId = pref.getString("userId");
        getIncomeReport("today");
      });
    });
  }

  getIncomeReport(String duration) async {
    setState(() {
      st = false;
    });
    print("Doctor Id -  ${doctorId}");
    final response = await post(Uri.parse("$SERVER_ADDRESS/api/income_report"),
        body: {'doctor_id': doctorId, 'duration': duration});
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      incomeReport = IncomeReportRes.fromJson(jsonDecode(response.body));
      st = true;
      setState(() {});
    }
  }

  IncomeReportRes incomeReport = IncomeReportRes();

  optionBottomSheet() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            height: 295,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15), topLeft: Radius.circular(15)),
            ),
            child: Column(children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15)),
                ),
                height: 60,
                // alignment: Alignment.center,
                child: Stack(
                  children: [
                    Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Filter Reports by",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF808080),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      margin: EdgeInsets.only(right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: Image.asset(
                                "assets/moreScreenImages/close.png",
                                width: 30,
                                height: 30,
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              CustomOptionTile(() {
                Get.back();
                setState(() {
                  showOption = "Today's";
                });
                getIncomeReport("today");
              }, "Today's Earning Report"),
              CustomOptionTile(() {
                Get.back();
                setState(() {
                  showOption = "Last 7 day's";
                });
                getIncomeReport("last 7 days");
              }, "Last 7 Days Earning Report"),
              CustomOptionTile(() {
                Get.back();
                setState(() {
                  showOption = "Last 30 day's";
                });
                getIncomeReport("last 30 days");
              }, "Last 30 Days Earning Report"),
              CustomOptionTile(() {
                Get.back();
                setState(() {
                  showOption = "";
                });
                _showDateRangePicker(context);
              }, "Select Date Range"),
              SizedBox(
                height: 5,
              ),
            ]));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          flexibleSpace: header(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color(0xFFe3fffd)),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      st
                          ? incomeReport.success.toString() == "0"
                              ? Text(
                                  "0 $CURRENCY",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  "${double.parse("${incomeReport.data!.totalIncome}").toStringAsFixed(1)} $CURRENCY",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                          : Container(),
                      // Expanded(
                      //   child:
                      Text(
                        "$showOption total income",
                        style:
                            TextStyle(color: Color(0xFF757575), fontSize: 18),
                      ),
                      // ),
                    ],
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  InkWell(
                      onTap: () {
                        optionBottomSheet();
                      },
                      child: Image.asset(
                        "assets/moreScreenImages/dots.png",
                        width: 25,
                        height: 25,
                      ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                DETAILED_REPORTS,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            st
                ? incomeReport.success.toString() == "0"
                    ? Container(
                        height: Get.height * 0.5,
                        alignment: Alignment.center,
                        child: Text("$showOption $YOU_HAVE_NOT_ANY_INCOME",
                            style: TextStyle(fontSize: 20)),
                      )
                    : Expanded(
                        child: ListView.builder(
                        itemCount: incomeReport.data!.incomeRecord!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 50,
                            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${incomeReport.data!.incomeRecord![index].date.toString().substring(8,10)}/${incomeReport.data!.incomeRecord![index].date.toString().substring(5,7)}/${incomeReport.data!.incomeRecord![index].date.toString().substring(0,4)}",
                                    style: TextStyle(
                                        color: Color(0xFF757575), fontSize: 16),
                                  ),
                                  Text(
                                    "${double.parse("${incomeReport.data!.incomeRecord![index].amount}").toStringAsFixed(1)} $CURRENCY",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 19),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ))
                : Container(
                    height: Get.height * 0.5,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(color: PRIMARY),
                  ),
          ],
        ),
      ),
    );
  }

  DateTimeRange? selectedDateRange;

  void _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now().add(Duration(days: -7)),
      end: DateTime.now().add(Duration(days: 7)),
    );

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: initialDateRange,
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      makeApi();
    }
  }

  makeApi() {
    print(
        "Selected Date Range: ${selectedDateRange!.start.toString().substring(0, 10)} to ${selectedDateRange!.end.toString().substring(0, 10)}");
    showOption = "";
    setState(() {});
    getIncomeReport(
        "${selectedDateRange!.start.toString().substring(0, 10)},${selectedDateRange!.end.toString().substring(0, 10)}");
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 55,
              ),
              // Container(
              //   margin: EdgeInsets.symmetric(horizontal: 3),
              //   child: IconButton(
              //       onPressed: () {
              //         Navigator.pop(context);
              //       },
              //       icon: Icon(
              //         Icons.arrow_back,
              //         color: Colors.white,
              //       )),
              // ),
              Text(INCOME_REPORT,
                  style: Theme.of(context).textTheme.headline5!.apply(
                      color: Theme.of(context).backgroundColor,
                      fontWeightDelta: 5))
            ],
          ),
        ),
      ],
    );
  }
}

class CustomOptionTile extends StatelessWidget {
  VoidCallback _callback;
  String text;

  CustomOptionTile(this._callback, this.text);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _callback,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.only(
          left: 10,
        ),
        height: 45,
        decoration: BoxDecoration(
            color: Color(0xFFeeeeee), borderRadius: BorderRadius.circular(7)),
        alignment: Alignment.centerLeft,
        child: Text("$text",
            style: TextStyle(
                color: Color(0xFF1e1e1e),
                fontSize: 17,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
