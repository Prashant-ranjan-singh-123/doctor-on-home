// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/holiday_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;


class AddUpdateHoliday extends StatefulWidget {
  int? holidayId;
  DateTime? startDate;
  DateTime? endDate;
  String? description;
  AddUpdateHoliday({this.holidayId = 0, this.startDate, this.endDate, this.description});

  @override
  _AddUpdateHolidayState createState() => _AddUpdateHolidayState();
}

class _AddUpdateHolidayState extends State<AddUpdateHoliday> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final kToday = DateTime.now();
  var kFirstDay;
  var kLastDay;
  List<dynamic> Function(DateTime)? events;
  DateRangePickerController controller = DateRangePickerController();
  TextEditingController descController = TextEditingController();
  Data? data;
  String? doctorId;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {

    SharedPreferences.getInstance().then((pref){
      setState(() {
        doctorId = pref.getString("userId");
      });
    });

    if(widget.startDate != null){
      controller.selectedRange = PickerDateRange(
        widget.startDate,
        widget.endDate
      );
      descController.text = widget.description!;
    }

    kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

    super.initState();
  }

  // List<Event> _getEventsForDay(DateTime day) {
  //   return events[day] ?? [];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            header(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      SizedBox(
                        height: 20,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Select Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 18
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Select a date or a number of dates for adding then to your holidays list',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: LIGHT_GREY_TEXT,
                            fontSize: 12
                          ),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.all(16),
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.8)
                          ),
                        ),
                        child: SfDateRangePicker(
                          controller: controller,
                          enablePastDates: false,
                          maxDate: DateTime.now().add(Duration(days: 30)),
                          view: DateRangePickerView.month,
                          selectionMode: DateRangePickerSelectionMode.range,
                          onSelectionChanged:  _onSelectionChanged,
                          initialSelectedRange: controller.selectedRange,
                          rangeSelectionColor: Colors.amber.withOpacity(0.6),
                          todayHighlightColor: Colors.amber,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: descController,
                          validator: (val){
                            if(val!.isEmpty){
                              print(val);
                              return THIS_FIELD_IS_REQUIRED;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: DESCRIPTION,
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                            ),
                            border: UnderlineInputBorder(),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
                            ),
                          ),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Visibility(
                        visible: widget.holidayId != 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              removeButton(),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          )
                      ),
                      addButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 100),
      //   child: FloatingActionButton(
      //       onPressed: (){
      //         setState(() {
      //           controller.selectedRanges = [
      //             PickerDateRange(DateTime.now(), DateTime.now())
      //           ];
      //         });
      //       },
      //   ),
      // ),
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

                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                ADD_HOLIDAY,
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

  Widget addButton() {
    return Container(
      height: 50,
      // color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      //width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: (){
          addHoliday();
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
                widget.holidayId == 0 ? ADD_HOLIDAY : UPDATE_HOLIDAY,
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
  
  Widget removeButton() {
    return Container(
      height: 50,
      // color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      //width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: (){
          removeHoliday();
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: LIGHT_GREY_TEXT.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40)
              ),
              child: Center(
                child: Text(
                  REMOVE,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: BLACK,
                      fontSize: 15
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  removeHoliday() async{
    dialog();
    var request = http.Request('GET', Uri.parse('$SERVER_ADDRESS/api/deleteholiday?id=${widget.holidayId}'));

    http.StreamedResponse response = await request.send();

    Navigator.pop(context);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      if(jsonResponse['success'].toString() == '1'){
        Navigator.pop(context, true);
      }else{
        errorDialog(ERROR, jsonResponse['msg']);
      }
    }
    else {
      errorDialog(ERROR, response.reasonPhrase!);
    }

  }

  _onSelectionChanged(DateRangePickerSelectionChangedArgs data){
    print(data.value);
  }


  addHoliday() async{
    if(controller.selectedRange == null){
      errorDialog(ERROR, ADD_DATE_ERROR);
    }else if(formKey.currentState!.validate()) {

      print(controller.selectedRange!.startDate.toString().substring(0,10));

      dialog();
      var request = http.MultipartRequest('POST', Uri.parse(
          '$SERVER_ADDRESS/api/saveholiday'));
      request.fields.addAll({
        'doctor_id': '$doctorId',
        'id': widget.holidayId.toString(),
        'start_date': controller.selectedRange!.startDate.toString().substring(0, 10),
        'end_date': controller.selectedRange!.endDate == null ? controller.selectedRange!.startDate.toString().substring(0, 10) : controller.selectedRange!.endDate.toString().substring(0, 10),
        'description': descController.text
      });


      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(await response.stream.bytesToString());
        print(jsonResponse);
        Navigator.pop(context);

        if (jsonResponse['success'].toString() == "1") {
          data = Data.fromJson(jsonResponse);
          Navigator.pop(context, true);
          print(data);
        } else {
          errorDialog(ERROR, jsonResponse['msg']);
        }
      }
      else {
        errorDialog(ERROR, response.reasonPhrase!);
        print(response.reasonPhrase);
      }
    }
  }

  errorDialog(String s1, String s2){
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


}
