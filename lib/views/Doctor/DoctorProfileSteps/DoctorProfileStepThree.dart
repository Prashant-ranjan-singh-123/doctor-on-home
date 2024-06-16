
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorProfileStepThree extends StatefulWidget {
  @override
  _DoctorProfileStepThreeState createState() => _DoctorProfileStepThreeState();
}

class _DoctorProfileStepThreeState extends State<DoctorProfileStepThree> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColorLight,
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10,),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: 10,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index){
                    return MyCard();
                  },
                ),
                SizedBox(height: 100,),
              ],
            ),
          ),
        ),
    );
  }

  Widget MyCard() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(16,5,16,5),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/homeScreenImages/calender.png",
                      height: 15,
                      width: 15,
                    ),
                    SizedBox(width: 5,),
                    Text("Sunday",
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  child: ListView.builder(
                    itemCount: 2,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, i){
                      return Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 20,),
                              Image.asset(
                                "assets/detailScreenImages/time.png",
                                height: 13,
                                width: 13,
                                color: Colors.amber.shade700,
                              ),
                              SizedBox(width: 5,),
                              Text("09:00AM - 12:30PM", style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),),
                            ],
                          ),
                          SizedBox(height: 8,),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Image.asset("assets/moreScreenImages/detail_arrow.png",
            height: 15,
            width: 15,
          ),
          SizedBox(width: 5,)
        ],
      ),
    );
  }
}
