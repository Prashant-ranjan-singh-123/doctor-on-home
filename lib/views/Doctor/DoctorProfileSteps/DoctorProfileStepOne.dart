import 'package:appcode3/en.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorProfileStepOne extends StatefulWidget {
  @override
  _DoctorProfileStepOneState createState() => _DoctorProfileStepOneState();
}

class _DoctorProfileStepOneState extends State<DoctorProfileStepOne> {

  bool isNameError = false;
  bool isPhoneError = false;
  bool isWorkingTimeError = false;
  bool isAboutUsError = false;
  bool isServiceError = false;
  String name = "";
  String phone = "";
  String workingTime = "";
  String aboutUs = "";
  String service = "";
  List<String> departmentList = [
    "Cardiologist",
    "Ayurveda",
  ];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                            color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                            width: 1,
                        ),
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(65),
                          child: Image.asset(
                              "assets/homeScreenImages/doctor.PNG",
                            height: 130,
                            width: 130,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 135,
                      width: 135,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                            "assets/homeScreenImages/edit.png",
                          height: 35,
                          width: 35,

                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            formToEdit(),
          ],
        ),
      ),
    );
  }



  formToEdit(){
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: NAME,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              errorText: isNameError ? ENTER_NAME : null,
            ),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                name = val;
                isNameError = false;
              });
            },
          ),
          SizedBox(
            height: 3,
          ),
          TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: PHONE_NUMBER,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              errorText: isPhoneError ? ENTER_MOBILE_NUMBER : null,
            ),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                phone = val;
                isPhoneError = false;
              });
            },
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            //width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColorDark.withOpacity(0.4), width: 1),
            ),
            child: DropdownButton(
              hint: Text(SELECT_DEPARTMENT),
              items: departmentList.map((x){
                return DropdownMenuItem(
                  child: Text(x,style: TextStyle(fontSize: 14),),
                  value: x,
                );
              }).toList(),
              onChanged: (val){
                print(val);
                setState(() {
                  selectedValue = val.toString();
                });
              },
              isExpanded: true,
              underline: Container(),
              value: selectedValue,
              icon: Image.asset(
                "assets/homeScreenImages/dropdown.png",
                height: 15,
                width: 15,
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: WORKING_TIME,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              errorText: isWorkingTimeError ? ENTER_WORKING_TIME : null,
            ),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                workingTime = val;
                isWorkingTimeError = false;
              });
            },
          ),
          SizedBox(
            height: 3,
          ),
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: ABOUT_US,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              errorText: isAboutUsError ? ENTER_ABOUT_US : null,
            ),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                aboutUs = val;
                isAboutUsError = false;
              });
            },
          ),
          SizedBox(
            height: 3,
          ),
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: SERVICES,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              errorText: isServiceError ? ENTER_SERVICES : null,
            ),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                service = val;
                isServiceError = false;
              });
            },
          ),
          SizedBox(height: 100,),
        ],
      ),
    );
  }

}
