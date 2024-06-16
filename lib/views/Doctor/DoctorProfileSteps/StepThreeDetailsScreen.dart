import 'dart:convert';

import 'package:appcode3/views/Doctor/DoctorProfile.dart';

import '../../../../en.dart';
import '../../../../main.dart';
import '../../../../modals/DoctorProfileSetails.dart';
import '../../../../modals/DoctorSlotDetails.dart';
import '../../../../modals/SpecialityClass.dart';
import '../../../../modals/Test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
// import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';
import 'package:toast/toast.dart';

class StepThreeDetailsScreen extends StatefulWidget {

  String id;
  MyData myData;
  String doctorId;
  String base64image;
  StepThreeDetailsScreen(this.id,this.myData,this.doctorId,this.base64image);

  @override
  _StepThreeDetailsScreenState createState() => _StepThreeDetailsScreenState();
}

class _StepThreeDetailsScreenState extends State<StepThreeDetailsScreen> {

  List<String> slotsInterval = [
    "15 $MINUTES",
    "30 $MINUTES",
    "45 $MINUTES",
    "60 $MINUTES",
  ];

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay? _picked;

  selectTime(i, bool isStartTime) async{
    FocusScope.of(context).unfocus();
    if(isStartTime && textEditingControllerStartTime[i].text.isNotEmpty){
      print(textEditingControllerStartTime[i].text);
      _time = TimeOfDay(hour: int.parse(textEditingControllerStartTime[i].text.split(":")[0]),minute: int.parse(textEditingControllerStartTime[i].text.split(":")[1]));
    }else if(textEditingControllerEndTime[i].text.isNotEmpty){
      _time = TimeOfDay(hour: int.parse(textEditingControllerEndTime[i].text.split(":")[0]),minute: int.parse(textEditingControllerEndTime[i].text.split(":")[1]));
    }else{
      _time = TimeOfDay.now();
    }
    _picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if(_picked != null){
      print(_picked);
      print(_picked!.hour.toString() + ":" +_picked!.minute.toString());
      setState(() {
        if(isStartTime) {
          print((_picked!.minute > 10 ? _picked!.minute.toString() : "0"+_picked!.minute.toString()));
          startTime[i] =
              (_picked!.hour > 10 ? _picked!.hour.toString() : "0"+_picked!.hour.toString()) + ":" + (_picked!.minute > 10 ? _picked!.minute.toString() : "0"+_picked!.minute.toString());
          print(startTime[i]);
          textEditingControllerStartTime[i].text =
              (_picked!.hour > 10 ? _picked!.hour.toString() : "0"+_picked!.hour.toString()) + ":" + (_picked!.minute > 10 ? _picked!.minute.toString() : "0"+_picked!.minute.toString());
          //_picked.hour > 10 ? _picked.hour.toString() : "0"+_picked.hour.toString() + ":" + (_picked.minute > 10 ? _picked.minute.toString() : "0"+_picked.minute.toString());
          isError[i] = false;
          print(startTime[i]);
          selectedvValue[i] = null;
        }
        else{
          endTime[i] =
              (_picked!.hour > 10 ? _picked!.hour.toString() : "0"+_picked!.hour.toString()) + ":" + (_picked!.minute > 10 ? _picked!.minute.toString() : "0"+_picked!.minute.toString());
          //_picked.hour > 10 ? _picked.hour.toString() : "0"+_picked.hour.toString() + ":" + (_picked.minute > 10 ? _picked.minute.toString() : "0"+_picked.minute.toString());
          textEditingControllerEndTime[i].text =
              (_picked!.hour > 10 ? _picked!.hour.toString() : "0"+_picked!.hour.toString()) + ":" + (_picked!.minute > 10 ? _picked!.minute.toString() : "0"+_picked!.minute.toString());
          //_picked.hour > 10 ? _picked.hour.toString() : "0"+_picked.hour.toString() + ":" + (_picked.minute > 10 ? _picked.minute.toString() : "0"+_picked.minute.toString());
          isError[i] = false;
          print(endTime[i]);
          selectedvValue[i] = null;
        }
      });
    }
  }


  bool areChangesMade = false;
  Future? _future;
  int totalCards = 1;
  bool isSlotAvailable = false;

  List<bool> isError = [];
  List<String> errorMessage = [];

  List<String?> selectedvValue = [];
  List<String> startTime = [];
  List<String> endTime = [];
  DateTime dateTime = DateTime.now();

  List<List<Getslotls>> slotsList = [];
  List<TextEditingController> textEditingControllerStartTime  = [];
  List<TextEditingController> textEditingControllerEndTime  = [];

  DoctorSlotsDetails? doctorSlotsDetails;
  SpecialityClass? specialityClass;
  int departmentId = 1;
  bool isErrorInLoading = false;


  getSpecialities() async{
    setState(() {
      departmentId = 0;
    });
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/getspeciality"));
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      specialityClass = SpecialityClass.fromJson(jsonResponse);
      for(int i=0;i<specialityClass!.data!.length;i++){
        if(specialityClass!.data![i].name == widget.myData.departmentName){
          setState(() {
            departmentId = i+1;
          });
          break;
        }
      }
    }
  }

  fetchDoctorSlots() async{
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/getdoctorschedule?doctor_id=${widget.doctorId}")).catchError((e){
      setState(() {
        isErrorInLoading = true;
      });
    });
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'].toString() == "1") {
        setState(() {
          doctorSlotsDetails = DoctorSlotsDetails.fromJson(jsonResponse);
          print(doctorSlotsDetails!.data);
          if(doctorSlotsDetails!.data!.isEmpty){
            isSlotAvailable = false;
          }else {
            initializeValues();
            isSlotAvailable = true;
          }
          //print("\n\n\n\n\nisSlotAvailable : "+isSlotAvailable.toString());
        });
      }else{
        setState(() {
          isSlotAvailable = false;
        });
      }
    }
  }

  List<int> slotsCount = [0,0,0,0,0,0,0];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = fetchDoctorSlots();
    print("\n\n\nDepartment id : $departmentId");
    print("\n\n\nimage path : ${widget.myData.image}");
    getSpecialities();
  }

  initializeValues(){
    for(int i=0; i<doctorSlotsDetails!.data!.length; i++){
      isError.add(false);
      errorMessage.add("x");
      //selectedvValue.add(slotsInterval[0]);
      startTime.add(doctorSlotsDetails!.data![i].startTime!);
      endTime.add(doctorSlotsDetails!.data![i].endTime!);
      slotsList.add(doctorSlotsDetails!.data![i].getslotls!);
      selectedvValue.add("${doctorSlotsDetails!.data![i].duration} $MINUTES");
      textEditingControllerEndTime.add(TextEditingController(text: endTime[i]));
      textEditingControllerStartTime.add(TextEditingController(text: startTime[i]));
    }
  }

  addValues(){
    //for(int i=0; i<doctorSlotsDetails.data.length; i++){
    setState(() {
      isError.add(false);
      errorMessage.add("x");
      selectedvValue.add("15 $MINUTES");
      startTime.add("x");
      endTime.add("x");
      slotsList.add([]);
      doctorSlotsDetails!.data!.add(SlotsData(dayId: int.parse(widget.id), duration: "15", doctorId: 1,
          getslotls: slotsList[slotsList.length-1]));
      textEditingControllerEndTime.add(TextEditingController(text: ""));
      textEditingControllerStartTime.add(TextEditingController(text: ""));
    });
      //      slotsList[slotsList.length + 1].add(Getslotls());

    //selectedvValue.add("${doctorSlotsDetails.data[i].duration} Minutes");
    //}
  }

  Future<bool> _onWillPopScope() async{
    Navigator.pop(context,areChangesMade);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: SafeArea(
          child: Scaffold(
            backgroundColor: Theme.of(context).primaryColorLight,
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
                ) : FutureBuilder(
                  future: _future,
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Container(
                        height: MediaQuery.of(context).size.height - 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }else if(snapshot.hasError){
                      return Text(snapshot.stackTrace.toString());
                    }
                    else if(snapshot.connectionState == ConnectionState.done) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: doctorSlotsDetails == null ? 0 : doctorSlotsDetails!.data!.length,
                              itemBuilder: (context, index) {
                                return MyCard(index);
                              },
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FloatingActionButton(
                                  child: Icon(Icons.add, color: Theme.of(context).backgroundColor,),
                                  backgroundColor: AMBER,
                                  onPressed: (){
                                    setState(() {
                                      addValues();
                                      totalCards = totalCards + 1;
                                    });
                                  },
                                ),
                                SizedBox(width: 20,)
                              ],
                            ),
                            SizedBox(height: 150,),
                          ],
                        ),
                      );
                    }else{
                      return Container(
                        height: MediaQuery.of(context).size.height - 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                  }
                ),
                button(),
              ],
            ),
          ),
      ),
    );
  }

  MyCard(i){
    return Visibility(
      visible: widget.id == doctorSlotsDetails!.data![i].dayId.toString() ? true : false,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        color: WHITE,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(START_TIME,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Stack(
                        children: [
                          TextField(
                            controller: textEditingControllerStartTime[i],
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "--:--",
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColorDark.withOpacity(0.6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColorDark.withOpacity(0.6)),
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.asset("assets/detailScreenImages/time.png", height: 5, width: 5,),
                              ),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(5),
                              FilteringTextInputFormatter.allow(RegExp("[0-9:]")),
                              MaskedTextInputFormatter(
                                mask: '00:00',
                                separator: ':',
                              ),
                            ],
                            onTap: (){
                              selectTime(i, true);
                            },
                            onChanged: (val){
                              setState(() {
                                startTime[i] = val;
                                isError[i] = false;
                                print(startTime[i]);
                                selectedvValue[i] = null;
                              });
                            },
                          ),
                          InkWell(
                              onTap: (){
                                selectTime(i, true);
                              },
                              child: Container(
                                height: 50,
                                color: Colors.transparent,)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(END_TIME,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Stack(
                        children: [
                          TextField(
                            controller: textEditingControllerEndTime[i],
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "--:--",
                              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColorDark.withOpacity(0.6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColorDark.withOpacity(0.6)),
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.asset("assets/detailScreenImages/time.png", height: 5, width: 5,),
                              )
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(5),
                              FilteringTextInputFormatter.allow(RegExp("[0-9:]")),
                              MaskedTextInputFormatter(
                                mask: '00:00',
                                separator: ':',
                              ),
                            ],
                            onTap: (){
                              selectTime(i, false);
                            },
                            onChanged: (val){
                              setState(() {
                                endTime[i] = val;
                                print(endTime[i]);
                                isError[i] = false;
                                selectedvValue[i] = null;
                                // if(val.length == 5){
                                //   slotsDistribution(startTime[i], endTime[i], int.parse(val.toString().substring(0,2)), i);
                                // }
                              });
                            },
                          ),
                          InkWell(
                              onTap: (){
                                selectTime(i, false);
                              },
                              child: Container(
                                height: 50,
                                color: Colors.transparent,)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                InkWell(
                  onTap: (){
                    print(i);
                    setState(() {
                      doctorSlotsDetails!.data!.removeAt(i);
                      errorMessage.removeAt(i);
                      //selectedvValue.add(slotsInterval[0]);
                      startTime.removeAt(i);
                      endTime.removeAt(i);
                      slotsList.removeAt(i);
                      selectedvValue.removeAt(i);
                      textEditingControllerStartTime.removeAt(i);
                      textEditingControllerEndTime.removeAt(i);
                    });
                  },
                  child: Image.asset(
                      "assets/homeScreenImages/delete_icon.png",
                    width: 60,
                    height: 50,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            isError[i]
                ? Row(
                  children: [
                    Text(errorMessage[i], style: TextStyle(color: Colors.red.shade800, fontSize: 10, fontWeight: FontWeight.bold),),
                  ],
                )
                : Container(),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColorDark.withOpacity(0.4), width: 1),
              ),
              child: DropdownButton(
                hint: Text("Select interval"),
                items: slotsInterval.map((x){
                  return DropdownMenuItem(
                    child: Text(x,style: TextStyle(fontSize: 14,color: BLACK),),
                    value: x,
                  );
                }).toList(),
                style: Theme.of(context).textTheme.bodyText1,
                onChanged: (val){
                  print(val);
                   setState(() {
                    selectedvValue[i] = val.toString();
                    slotsDistribution(startTime[i], endTime[i], int.parse(val.toString().substring(0,2)), i);
                   });
                },
                value: selectedvValue[i],
                isExpanded: true,
                underline: Container(),
                icon: Image.asset(
                  "assets/homeScreenImages/dropdown.png",
                  height: 15,
                  width: 15,
                ),
              ),
            ),
            SizedBox(height: 15,),
            grids(i),
          ],
        ),
      ),
    );
  }

  slotsDistribution(String startTime, String endTime, interval, i){
    print(startTime + " " + endTime);
    if(interval.toString().isEmpty){
      setState(() {
        slotsList[i].clear();
      });
      return;
    }
    setState(() {
      slotsList[i].clear();
    });
    try {
      if(int.parse(startTime.split(":")[1]) >= 60 || int.parse(endTime.split(":")[1]) >= 60){
        setState(() {
          errorMessage[i] = TIMINGS_ENTERED_INCORRECTLY;
          isError[i] = true;
        });
      } else {
        DateTime d1 = DateTime(dateTime.year, dateTime.month, dateTime.day,
            int.parse(startTime.split(":")[0]),
            int.parse(startTime.split(":")[1]));
        DateTime d2 = DateTime(dateTime.year, dateTime.month, dateTime.day,
            int.parse(endTime.split(":")[0]),
            int.parse(endTime.split(":")[1]));
        print(d2
            .difference(d1)
            .inMinutes);
        if (d2
            .difference(d1)
            .inMinutes
            .isNegative) {
          setState(() {
            errorMessage[i] = ENDING_TIME_CAN_NOT_BE_SMALLER_THAT_STARTING_TIME;
            isError[i] = true;
          });
        } else {
          for (int x = 0; x < d2
              .difference(d1)
              .inMinutes / interval; x++) {
            dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day,
              int.parse(startTime.split(":")[0]),
              int.parse(startTime.split(":")[1]),);
            // print(dateTime.add(Duration(minutes: x * interval))
            //     .toString()
            //     .substring(11, 16) + "${dateTime
            //     .add(Duration(minutes: x * interval))
            //     .hour > 12 ? " PM" : " AM"}");
            setState(() {

              int ii = interval;
              slotsList[i].add(Getslotls(slot: dateTime.add(Duration(minutes: x * ii))
                  .toString()
                  .substring(11, 16) + "${dateTime
                  .add(Duration(minutes: x * ii))
                  .hour > 12 ? " $PM" : " $AM"}"));
            });

          }
        }
      }
    }catch(e){
      print(e);
      setState(() {
        errorMessage[i] = START_END_TIME_NOT_ENTERED_CORRECTLY;
        isError[i] = true;
      });
    }
  }

  grids(int i) {
    return GridView.count(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2,
      children: List.generate(slotsList[i].length, (index){
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColorDark.withOpacity(0.5),width: 0.5)
          ),
          child: Center(
            child: Text(slotsList[i][index].slot!,style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).primaryColorDark.withOpacity(0.6),
            ),),
          ),
        );
      }),
    );
  }

  Widget header() {
    return Stack(
      children: [
        Image.asset("assets/moreScreenImages/header_bg.png",
          height: 60,
          fit: BoxFit.fill,
          width: MediaQuery
              .of(context)
              .size
              .width,
        ),
        Container(
          height: 60,
          child: Row(
            children: [
              SizedBox(width: 15,),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                  PROFILE,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline5
                      !.apply(color: Theme
                      .of(context)
                      .backgroundColor)
              )
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
            generateJson();
            //print(doctorSlotsDetails.toJson());
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
                  SAVE,
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

  generateJson(){
    List<int> slotsCount = [0,0,0,0,0,0,0];
    print(doctorSlotsDetails!.data);
    if(doctorSlotsDetails!.data!.isEmpty){
      print("doctorslotdetails is null");
      messageDialog(EMPTY, NO_CHANGES_HAVE_BEEN_MADE);
    }
    else{
      print(doctorSlotsDetails!.data!.length);
      for (int i = 0; i < doctorSlotsDetails!.data!.length; i++) {
        setState(() {
          if (doctorSlotsDetails!.data![i].dayId == 0) {
            slotsCount[0] = slotsCount[0] + 1;
          } else if (doctorSlotsDetails!.data![i].dayId == 1) {
            slotsCount[1] = slotsCount[1] + 1;
          } else if (doctorSlotsDetails!.data![i].dayId == 2) {
            slotsCount[2] = slotsCount[2] + 1;
          } else if (doctorSlotsDetails!.data![i].dayId == 3) {
            slotsCount[3] = slotsCount[3] + 1;
          } else if (doctorSlotsDetails!.data![i].dayId == 4) {
            slotsCount[4] = slotsCount[4] + 1;
          } else if (doctorSlotsDetails!.data![i].dayId == 5) {
            slotsCount[5] = slotsCount[5] + 1;
          } else if (doctorSlotsDetails!.data![i].dayId == 6) {
            slotsCount[6] = slotsCount[6] + 1;
          }
        });
      }

      print(slotsCount);

      String x = "{\"timing\":{";
      for (int i = 0; i < 7; i++) {
        int z = 0;
        x = x + "\"$i\":[";
        for (int j = 0; j < doctorSlotsDetails!.data!.length; j++) {
          //print(startTime[j]);
          if (i == doctorSlotsDetails!.data![j].dayId) {
            z = z + 1;
            x = x +
                "{\"start_time\":\"${startTime[j]}\",\"end_time\":\"${endTime[j]}\",\"duration\":\"${selectedvValue[j]
                !.substring(0, 2)}\"}${slotsCount[i] == z ? "" : ","}";
          }
        }
        x = x + "]${i < 6 ? "," : ""}";
      }
      x = x + "}}";
      //print("x----->  "+x);
      bool isErrorExist = false;
      String msg = "";
      for (int i = 0; i < isError.length; i++) {
        if (isError[i]) {
          isErrorExist = true;
          msg = errorMessage[i];
          break;
        }
      }

      isErrorExist ? messageDialog(ERROR, msg) : uploadData(x);


      // print();
    }
    // else

    // }
  }

  uploadData(x) async{
    dialog();
    print("\n\n\nLoading...       ${widget.doctorId}");
    print(widget.myData.healthcare);
    print(widget.myData.facebookUrl);
    print(widget.myData.twitterUrl);
    print(widget.base64image);
    if(widget.base64image == null){
    final response = await post(Uri.parse("$SERVER_ADDRESS/api/doctoreditprofile"),
         body: {
          "doctor_id" : widget.doctorId,
          "name" : widget.myData.name,
          "password" : widget.myData.password,
          "email" : widget.myData.email,
           "consultation_fees" : widget.myData.consultationFees,
           "aboutus" : widget.myData.aboutus,
          "working_time" :widget.myData.workingTime,
          "address" : widget.myData.address,
          "lat" : widget.myData.lat,
          "lon" : widget.myData.lon,
          "phoneno" : widget.myData.phoneno,
          "services" : widget.myData.services,
          "healthcare" : widget.myData.healthcare,
          //widget.base64image == null ? "doctor_id" : widget.doctorId : "image" : widget.base64image,
          "department_id" : departmentId.toString(),
          "facebook_url" : widget.myData.facebookUrl,
          "twitter_url" : widget.myData.twitterUrl,
          "time_json" : x,
    }
     ).catchError((e){
       Navigator.pop(context);
       messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
       print(e);
     });
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if(jsonResponse['success'].toString() == "1"){
        // Navigator.pop(context);
        setState(() {
            isError.clear();
            errorMessage.clear();
            selectedvValue.clear();
            startTime.clear();
            endTime.clear();
            slotsList.clear();
            doctorSlotsDetails!.data!.clear();
            textEditingControllerEndTime.clear();
            textEditingControllerStartTime.clear();
            _future = fetchDoctorSlots();
            //fetchDoctorSlots();
          areChangesMade = true;
        });
        Navigator.pop(context,areChangesMade);
        return false;
      }else{
        Navigator.pop(context);
        messageDialog(ERROR, jsonResponse['register']);
      }
    }
  }
    else{
    final response = await post(Uri.parse("$SERVER_ADDRESS/api/doctoreditprofile"),
         body: {
          "doctor_id" : widget.doctorId,
          "name" : widget.myData.name,
           "password" : widget.myData.password,
           "email" : widget.myData.email,
           "consultation_fees" : widget.myData.consultationFees,
           "aboutus" : widget.myData.aboutus,
          "working_time" :widget.myData.workingTime,
          "address" : widget.myData.address,
          "lat" : widget.myData.lat,
          "lon" : widget.myData.lon,
          "phoneno" : widget.myData.phoneno,
          "services" : widget.myData.services,
          "healthcare" : widget.myData.healthcare,
          "image" : widget.base64image,
          "department_id" : departmentId.toString(),
          "facebook_url" : widget.myData.facebookUrl,
          "twitter_url" : widget.myData.twitterUrl,
          "time_json" : x,
    }
     ).catchError((e){
      Navigator.pop(context);
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      print(e);
     });
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      if(jsonResponse['success'].toString() == "1"){
        Navigator.pop(context);
        print("test");
        showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: Text(SUCCESSFUL,style: GoogleFonts.comfortaa(
                  fontWeight: FontWeight.bold,
                ),),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(SUCCESSFUL_TIME_SLOT,style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),)
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: (){
                      setState(() {
                        isError.clear();
                        errorMessage.clear();
                        selectedvValue.clear();
                        startTime.clear();
                        endTime.clear();
                        slotsList.clear();
                        doctorSlotsDetails!.data!.clear();
                        textEditingControllerEndTime.clear();
                        textEditingControllerStartTime.clear();
                        _future = fetchDoctorSlots();
                        //fetchDoctorSlots();
                        areChangesMade = true;
                      });
                      Navigator.pop(context,areChangesMade);
                      Navigator.pop(context,areChangesMade);
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

        // Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorProfile()));

      }else{
        Navigator.pop(context);
        messageDialog(ERROR, jsonResponse['register']);
      }
    }
  }
  }

  dialog(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(PROCESSING,
              style: GoogleFonts.poppins(),
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(PLEASE_WAIT_WHILE_SAVING_CHANGES,
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


class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
  }) {}

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 0) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
            '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}

