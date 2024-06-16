import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/holiday_model.dart';
import 'package:appcode3/views/Doctor/DoctorProfileSteps/add_holiday.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HolidayList extends StatefulWidget {
  const HolidayList({Key? key}) : super(key: key);

  @override
  _HolidayListState createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList> {

  List<String> months = [
    JANUARY,
    FEBRUARY,
    MARCH,
    APRIL,
    MAY,
    JUNE,
    JULY,
    AUGUST,
    SEPTEMBER,
    OCTOBER,
    NOVEMBER,
    DECEMBER,
  ];

  HolidayModel? holidayModel;
  Future<HolidayModel>? futureHoliday;
  String? doctorId;

  @override
  void initState() {
    SharedPreferences.getInstance().then((pref){
      setState(() {
        doctorId = pref.getString("userId");
        futureHoliday = loadHolidays();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
      body: SafeArea(
          child: FutureBuilder<HolidayModel>(
            future: futureHoliday,
              builder: (context, snapshot){
                if(snapshot.hasData){
                  if(snapshot.data!.data == null){
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [

                         Image.asset(
                           'assets/homeScreenImages/no_appo_img.png',
                           width: 250,
                         ),

                         SizedBox(
                           height: 10,
                         ),

                         Text(
                           NO_HOLIDAY_SO_FAR,
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 18
                           ),
                         ),

                         Text(
                           NO_HOLIDAY_SO_FAR_DESC,
                           style: TextStyle(
                               fontWeight: FontWeight.normal,
                               color: LIGHT_GREY_TEXT,
                               fontSize: 12
                           ),
                         ),

                         SizedBox(
                           height: 80,
                         ),
                       ],
                     ),
                   );
                  }
                  else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                          bottom: 200
                      ),
                      itemCount: snapshot.data!.data!.length,
                      itemBuilder: (context, index) {
                        return holidayCard(
                          snapshot.data!.data![index].id!,
                          DateTime.parse(snapshot.data!.data![index].startDate!),
                          DateTime.parse(snapshot.data!.data![index].endDate!),
                          snapshot.data!.data![index].description!,
                        );
                      },
                    );
                  }
                }else if(snapshot.hasError){
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                }else{
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                }
              },
          ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 70
        ),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: WHITE,
          ),
          // backgroundColor: AMBER,
          onPressed: () async{
            bool x = await Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddUpdateHoliday()
            ));
            if(x != null){
              setState(() {
                futureHoliday = loadHolidays();
              });
            }
          },
        ),
      ),
    );
  }

  holidayCard(int id, DateTime startDate, DateTime endDate, String description) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.circular(15)
      ),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    startDate == endDate
                        ? Text(
                      "${startDate.day} ${months[startDate.month - 1]} ${startDate.year}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12
                      ),
                    )
                        : Text(
                      "${startDate.day} ${months[startDate.month - 1]} ${startDate.year} - ${endDate.day} ${months[endDate.month - 1]} ${endDate.year}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12
                      ),
                    ),
                    Text(
                        (startDate
                          .difference(endDate)
                          .inDays
                          .abs() + 1
                        ).toString() + ' Days Holiday',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AMBER,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: WHITE,
                  ),
                  onPressed: () async{
                    bool x = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddUpdateHoliday(
                      holidayId: id,
                      startDate: startDate,
                      endDate: endDate,
                      description: description,
                    ),),);
                    if(x!=null){
                      setState(() {
                        futureHoliday = loadHolidays();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          Divider(
            color: LIGHT_GREY_TEXT,
          ),
          Text(
            description,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: LIGHT_GREY_TEXT,
            ),
          ),
        ],
      ),
    );
  }

  Future<HolidayModel> loadHolidays() async{
    var request = http.Request('GET', Uri.parse('$SERVER_ADDRESS/api/getholiday?doctor_id=$doctorId'));

      http.StreamedResponse response = await request.send();
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      return HolidayModel.fromJson(jsonResponse);

  }

}
