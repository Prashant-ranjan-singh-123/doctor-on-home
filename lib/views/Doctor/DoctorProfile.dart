// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'package:appcode3/views/Doctor/DoctorProfileSteps/add_holiday.dart';
import 'package:dio/dio.dart' as dio;
import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/DoctorProfileSetails.dart';
import 'package:appcode3/modals/DoctorScheduleDetails.dart';
import 'package:appcode3/modals/SpecialityClass.dart';
import 'package:appcode3/views/Doctor/DoctorProfileSteps/DoctorProfileStepOne.dart';
import 'package:appcode3/views/Doctor/DoctorProfileSteps/DoctorProfileStepThree.dart';
import 'package:appcode3/views/Doctor/DoctorProfileSteps/DoctorProfileStepTwo.dart';
import 'package:appcode3/views/Doctor/DoctorProfileSteps/StepThreeDetailsScreen.dart';
import 'package:appcode3/views/Doctor/DoctorTabScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geocode/geocode.dart' as geo;
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'DoctorProfileSteps/holiday_list.dart';
import 'package:geocoding/geocoding.dart';

class DoctorProfile extends StatefulWidget {
  @override
  _DoctorProfileState createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile>{

  int index = 0;
  DoctorProfileDetails? doctorProfileDetails;
  DoctorScheduleDetails? doctorScheduleDetails;
  Future? future;
  Future? future2;
  String? doctorId;
  bool isErrorInLoading = false;
  List<String> daysList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  List<MyData> myData = [];


  fetchDoctorSchedule() async{
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/getdoctorschedule?doctor_id=$doctorId"));
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
        doctorScheduleDetails = DoctorScheduleDetails.fromJson(jsonResponse);
        fetchSlotsCount();
        setState(() { });
    }
  }

  fetchDoctorProfileDetails() async{
    print("REQUEST URL : $SERVER_ADDRESS/api/doctordetail?doctor_id=$doctorId");
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/doctordetail?doctor_id=$doctorId"))
    .catchError((e){
      setState(() {
        isErrorInLoading = true;
      });
      messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
    });
    if(response.statusCode == 200){

      final jsonResponse = jsonDecode(response.body);
      print(response.request);
      print(jsonResponse);
      // print(departmentList.toString()+"kiii");

      setState(() {
        try {
          doctorProfileDetails = DoctorProfileDetails.fromJson(jsonResponse);
        }catch(E){
          print('Doctor Get Error is $E');
        }
        print('name is : ${doctorProfileDetails!.data!.name}');
        print('name is : ${doctorProfileDetails!.data!.image}');
        print('name is : ${doctorProfileDetails!.data!.workingTime}');

        nameController.text = name = doctorProfileDetails!.data!.name!;
        password = doctorProfileDetails!.data!.password ?? "";
        phoneController.text = phone = doctorProfileDetails!.data!.phoneno.toString();
        print("DEPARTMENT NAME " + doctorProfileDetails!.data!.departmentName.toString());
        selectedValue = (doctorProfileDetails!.data!.departmentName == null || doctorProfileDetails!.data!.departmentName!.length == 0?null:doctorProfileDetails!.data!.departmentName!)!;
        print("DEPARTMENT NAME " + selectedValue!);
        print("\n\n\n\n"+doctorProfileDetails!.data!.name!);
        worktimeController.text = workingTime = doctorProfileDetails!.data!.workingTime ?? "";
        feeController.text = consultationFee = doctorProfileDetails!.data!.consultationFees.toString() ;
        aboutUsController.text = aboutUs = doctorProfileDetails!.data!.aboutus ?? "";
        serviceController.text = service = doctorProfileDetails!.data!.services ?? "";
        healthcareController.text = healthcare = doctorProfileDetails!.data!.healthcare ?? "";
        facebookController.text = facebook = doctorProfileDetails!.data!.facebookUrl ?? "";
        twitterController.text = twitter = doctorProfileDetails!.data!.twitterUrl ?? "";
        // passController.text = password = doctorProfileDetails!.data!.password ?? "";
        if(doctorProfileDetails!.data!.lat != null) {
          _center = LatLng(
              double.parse(doctorProfileDetails!.data!.lat!),
              double.parse(doctorProfileDetails!.data!.lon!));
          locateMarker(_center!, true);
        }else{
          _getLocationStart();
        }

        //print("details retrieved" + doctorProfileDetails.data.name);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSpecialities();
    getLocation = _getLocationStart();
    SharedPreferences.getInstance().then((pref){
      setState(() {
        doctorId = pref.getString("userId");
      });
    }).then((value){
      future = fetchDoctorProfileDetails();
      future2 = fetchDoctorSchedule();
    });
  }

  Future<bool> _onWillPopScope() async {
    bool? x;
    if(index > 0){
      setState(() {
        index = index - 1;
        x = false;
      });
    }
    else {
      x = true;
    }
      return x!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
          onWillPop: _onWillPopScope,
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: header(),
              leading: Container(),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 16,left: 16,right: 16,bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: index >= 0
                                      ? AMBER
                                      : Theme.of(context).primaryColorLight
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: index >= 1
                                      ? AMBER
                                      : Theme.of(context).primaryColorDark.withOpacity(0.2),
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: index >= 2
                                    ? AMBER
                                    : Theme.of(context).primaryColorDark.withOpacity(0.2),
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: index >= 3
                                    ? AMBER
                                    : Theme.of(context).primaryColorDark.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      future: future,
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting || future == null || future2 == null){
                          return Container(
                            height: MediaQuery.of(context).size.height - 190,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        // else if(snapshot.hasError){
                        //   return Center(
                        //     child: Icon(Icons.error, color:  Colors.red, size: 40,),
                        //   );
                        // }


                        else if(snapshot.connectionState == ConnectionState.done){
                          return Expanded(
                            child: Stack(
                              children: [
                                Visibility(
                                    visible: index >= 0 ? true : false,
                                    child: stepOne()),
                                Visibility(
                                    visible: index >= 1 ? true : false,
                                    child: stepTwo()),
                                Visibility(
                                    visible: index >= 2 ? true : false,
                                    child: stepThree()),
                                Visibility(
                                    visible: index >= 3 ? true : false,
                                    child: stepFour()),

                              ],
                              //physics: NeverScrollableScrollPhysics(),
                            ),
                          );
                        }else {
                          return Container(
                            height: MediaQuery.of(context).size.height - 170,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                      }
                    ),
                  ],
                ),
                button(),
              ],
            ),
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
              index > 0 ? SizedBox(width: 15,) : Container(),
              index > 0 ? InkWell(
                onTap: (){
                  _onWillPopScope();
                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ) : Container(),
              SizedBox(width: 10,),
              Text(
                  PROFILE,
                  style: Theme.of(context).textTheme.headline5!.apply(color: Theme.of(context).backgroundColor, fontWeightDelta: 5)
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
        height: 70,
        color: Theme.of(context).backgroundColor,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        //width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: (){
            if(index == 0){
              print("index 0");

              if(name.isEmpty){
                setState(() {
                  isNameError = true;
                });
              }else if(phone.length < 10){
                setState(() {
                  isPhoneError = true;
                });
              }
              // else if(password.isEmpty){
              //   setState(() {
              //     isPassError = true;
              //   });
              // }
              else if(selectedValue == null){
                setState(() {
                  isDepartmentError = true;
                });
              }else if(workingTime.isEmpty){
                setState(() {
                  isWorkingTimeError = true;
                });
              }else if(consultationFee.isEmpty){
                setState(() {
                  isFeeError = true;
                });
              }else if(aboutUs.isEmpty){
                setState(() {
                  isAboutUsError = true;
                });
              }else if(service.isEmpty){
                setState(() {
                  isServiceError = true;
                });
              }else if(healthcare.isEmpty){
                setState(() {
                  isHealthCareError = true;
                });
              }else if(facebook.isEmpty){
                setState(() {
                  isFacebookError = true;
                });
              }else if(twitter.isEmpty){
                setState(() {
                  isTwitterError = true;
                });
              }else{
                setState(() {
                  index = index + 1;
                });
              }
            }
            else if(index == 1){
              print("index 1");
              if(textEditingController.text.isEmpty){
                setState(() {
                  isAddressError = true;
                });
              }else{
                setState(() {
                      index = index + 1;
                    });
              }
            }
            else if(index == 2){
              print("index 2");

              setState(() {
                index++;
              });
              // uploadData();
            }else if(index == 3){
              print("index 3");
              uploadData();
            }
            else{
              print("else");

            }

            // if(index < 3){
            //   setState(() {
            //     index = index + 1;
            //   });
            // }
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
                  index == 3 ? UPDATE : NEXT,
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

  //step one ----------------------------------------

  bool isNameError = false;
  bool isPhoneError = false;
  bool isPassError = false;
  bool isWorkingTimeError = false;
  bool isAboutUsError = false;
  bool isServiceError = false;
  bool isDepartmentError = false;
  bool isHealthCareError = false;
  bool isFacebookError = false;
  bool isTwitterError = false;
  bool isFeeError = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController aboutUsController = TextEditingController();
  TextEditingController serviceController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController worktimeController = TextEditingController();
  TextEditingController healthcareController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController feeController = TextEditingController();

  String name = "";
  String phone = "";
  String password = "";
  String workingTime = "";
  String aboutUs = "";
  String service = "";
  String healthcare = "";
  String facebook = "";
  String twitter = "";
  String consultationFee = "";
  List<String> departmentList = [];
  String? selectedValue;
  SpecialityClass? specialityClass;
  File? _image;
  final picker = ImagePicker();
  String? base64image;

  Future getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 30);

    setState(() {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          base64image = base64Encode(_image!.readAsBytesSync());
          print(base64image);
        });
      } else {
        print('No image selected.');
      }
    });
  }
  
  getSpecialities() async{
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/getspeciality"));

    print(response.request);

    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      specialityClass = SpecialityClass.fromJson(jsonResponse);
      for(int i=0;i<specialityClass!.data!.length;i++){
        departmentList.add(specialityClass!.data![i].name!);
      }

      print(departmentList);
    }
  }

  Widget stepOne(){
    // print('image path ${doctorProfileDetails!.data!.image}');
    return Scaffold(
      backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
        child: SingleChildScrollView(
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
                            child: _image != null
                                ? Image.file(
                              _image!,
                              height: 130,
                              width: 130,
                              fit: BoxFit.cover,
                            )
                                : CachedNetworkImage(
                              imageUrl: doctorProfileDetails!.data!.image!.toString(),
                              height: 130,
                              width: 130,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Transform.scale(
                                  scale: 3.1,
                                  child: Icon(Icons.account_circle, color: Theme.of(context).primaryColorDark.withOpacity(0.3), size: 50,)),
                              errorWidget: (context, url, error) => Transform.scale(
                                  scale: 3.1,
                                  child: Icon(Icons.account_circle, color: Theme.of(context).primaryColorDark.withOpacity(0.3), size: 50,)),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 135,
                        width: 135,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: (){
                              getImage();
                            },
                            child: Image.asset(
                              "assets/homeScreenImages/edit.png",
                              height: 35,
                              width: 35,
                            ),
                          )
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
      ),
    );
  }

  formToEdit(){
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: nameController,
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
            controller: phoneController,
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
          // SizedBox(
          //   height: 3,
          // ),
          // TextField(
          //   controller: passController,
          //   obscureText: true,
          //   decoration: InputDecoration(
          //     labelText: PASSWORD,
          //     labelStyle: TextStyle(
          //       color: Theme.of(context).primaryColorDark.withOpacity(0.4),
          //     ),
          //     border: UnderlineInputBorder(),
          //     focusedBorder: UnderlineInputBorder(
          //         borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
          //     ),
          //     errorText: isPassError ? ENTER_PASSWORD : null,
          //   ),
          //   style: TextStyle(
          //       fontWeight: FontWeight.w600,
          //       fontSize: 14
          //   ),
          //   onChanged: (val){
          //     setState(() {
          //       password = val;
          //       isPassError = false;
          //     });
          //   },
          // ),
          SizedBox(
            height: 25,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            //width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(color: !isDepartmentError
                  ? Theme.of(context).primaryColorDark.withOpacity(0.4)
                  : Colors.red.shade700,
                  width: 1),
            ),
            child: departmentList == null ? Container() : DropdownButton(
              hint: Text(SELECT_DEPARTMENT),
              items: departmentList.map((x){
                return DropdownMenuItem(
                  child: Text(x,style: TextStyle(fontSize: 14),),
                  value: x,
                );
              }).toList(),
              value: selectedValue,
              onTap: (){
                setState(() {
                  isDepartmentError = false;
                });
              },
              onChanged: (val){
                setState(() {
                  selectedValue = val.toString();
                });
                print("DEPARTMENT NAME " + selectedValue!);

              },
              isExpanded: true,
              underline: Container(),
              //value: selectedValue.isEmpty ? DENTIST : selectedValue,
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
            controller: worktimeController,
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

          ///CONSULTATION FEE
          SizedBox(
            height: 3,
          ),
          TextField(
            controller: feeController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: CONSULTATION_FEE,
              prefixText: CURRENCY,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              errorText: isFeeError ? THIS_FIELD_IS_REQUIRED : null,
            ),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                consultationFee = val;
                isFeeError = false;
              });
            },
          ),
          ///-------------

          SizedBox(
            height: 3,
          ),
          TextField(
            controller: aboutUsController,
            keyboardType: TextInputType.text,
            minLines: 1,
            maxLines: 5,
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
            minLines: 1,
            maxLines: 5,
            controller: serviceController,
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
          SizedBox(
            height: 3,
          ),
          TextField(
            controller: healthcareController,
            keyboardType: TextInputType.text,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              labelText: HEALTHCARE,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              errorText: isHealthCareError ? THIS_FIELD_IS_REQUIRED : null,
            ),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                healthcare = val;
                isHealthCareError = false;
                //isPhoneError = false;
              });
            },
          ),
          SizedBox(
            height: 3,
          ),
          TextField(
            controller: facebookController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: FACEBOOK,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
               errorText: isFacebookError ? THIS_FIELD_IS_REQUIRED : null,
            ),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                facebook = val;
                isFacebookError = false;
                //isPhoneError = false;
              });
            },
          ),
          SizedBox(
            height: 3,
          ),
          TextField(
            controller: twitterController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: TWITTER,
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.4),
              ),
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
               errorText: isTwitterError ? THIS_FIELD_IS_REQUIRED : null,
            ),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14
            ),
            onChanged: (val){
              setState(() {
                twitter = val;
                isTwitterError = false;
                //isPhoneError = false;
              });
            },
          ),
          SizedBox(height: 100,),
        ],
      ),
    );
  }



  // step two ---------------------------------------

  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};
  LatLng? _center;
  Future? getLocation;
  bool isAddressError = false;
  TextEditingController textEditingController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  locateMarker(LatLng latLng, bool x) async{
    final marker = Marker(
      markerId: MarkerId("curr_loc"),
      position: latLng,
      infoWindow: InfoWindow(title: 'Doctor location'),
    );
    setState(() {
      _markers["Current Location"] = marker;
    });
    print("\n\n\n\n Marker: ${_markers["Current Location"]}\n\n");

    GeoCode geoCode = GeoCode();
    //if(x) {
      final coordinates = new Coordinates(latitude: latLng.latitude, longitude: latLng.longitude);
      print(coordinates);

    List<Placemark> placemarks = await placemarkFromCoordinates(coordinates.latitude!, coordinates.longitude!);

    print('PLACEMARK : ${placemarks.first}');

    var first = placemarks.first;

    textEditingController.text = first.name! +
        ", " +
        first.postalCode! +
        ", " +
        first.locality! +
        ", " +
        first.subAdministrativeArea! +
        ", " +
        first.administrativeArea!;

  }

  stepTwo(){
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: TextField(
                maxLines: 3,
                minLines: 1,
                controller: textEditingController,
                decoration: InputDecoration(
                  labelText: ADDRESS,
                  labelStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                  ),
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
                  ),
                  errorText: isAddressError ? SELECT_ADDRESS_FROM_MAP : null,
                ),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder(
                    future: getLocation,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || future == null || future2 == null) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return GoogleMap(
                          onMapCreated: _onMapCreated,
                          //scrollGesturesEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: _center ?? LatLng(40.7731125115069, -73.96187393112228),
                            zoom: 15.0,
                          ),
                          onTap: (latLang) {
                            //Toast.show(latLang.toString(), context,duration: 2);
                            setState(() {
                              //_getLocation(latLang);
                              _center = latLang;
                              locateMarker(_center!, true);
                            });
                          },
                          buildingsEnabled: true,
                          compassEnabled: true,
                          markers: _markers.values.toSet(),
                        );
                      }
                    }
                ),
              ),
            ),
            //_getAdContainer(),
            SizedBox(height: 70,),
          ],
        ),
      ),
    );
  }

  _getLocationStart() async {
    print('Started');
    //Toast.show("loading", context);
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((value) async {
      setState(() {
        _center = LatLng(value.latitude, value.longitude);
        print("\n\n\n\n\nLocation loaded");
        locateMarker(_center!, false);
      });
      return value;
    }).catchError((e) {
      Toast.show(e.toString());
      print(e);
    });
  }

  // step three ---------------------------

  List<int> slotsCount = [0,0,0,0,0,0,0];
  stepThree(){
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),
              FutureBuilder(
                future: future2,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting || future == null || future2 == null){
                    return Container(
                      height: MediaQuery.of(context).size.height - 170,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }else if(snapshot.connectionState == ConnectionState.done){
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: 7,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index){
                        return MyCard(index);
                      },
                    );
                  }else{
                    return Container(
                      height: MediaQuery.of(context).size.height - 170,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                }
              ),
              //_getAdContainer(),
              SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }

  fetchSlotsCount() {
    slotsCount = [0, 0, 0, 0, 0, 0, 0];
    for (int i = 0; i < doctorScheduleDetails!.data!.length; i++) {
      setState(() {
        if (doctorScheduleDetails!.data![i].dayId == 0) {
          slotsCount[0] = slotsCount[0] + 1;
        } else if (doctorScheduleDetails!.data![i].dayId == 1) {
          slotsCount[1] = slotsCount[1] + 1;
        } else if (doctorScheduleDetails!.data![i].dayId == 2) {
          slotsCount[2] = slotsCount[2] + 1;
        } else if (doctorScheduleDetails!.data![i].dayId == 3) {
          slotsCount[3] = slotsCount[3] + 1;
        } else if (doctorScheduleDetails!.data![i].dayId == 4) {
          slotsCount[4] = slotsCount[4] + 1;
        } else if (doctorScheduleDetails!.data![i].dayId == 5) {
          slotsCount[5] = slotsCount[5] + 1;
        } else if (doctorScheduleDetails!.data![i].dayId == 6) {
          slotsCount[6] = slotsCount[6] + 1;
        }
      });
    }
  }

  Widget MyCard(int i) {

    myData.add(MyData(
      avgratting: doctorProfileDetails!.data!.avgratting,
      departmentName: selectedValue,
      id: 1,
      name: name,
      email: doctorProfileDetails!.data!.email,
      aboutus: aboutUs,
      workingTime: workingTime,
      address: textEditingController.text,
      lat: _center!.latitude.toString(),
      lon: _center!.longitude.toString(),
      phoneno: phone,
      password: password,
      services: service,
      healthcare: healthcare,
      facebookUrl: facebook,
      twitterUrl: twitter,
      consultationFees: consultationFee,
    ));

    return InkWell(
      onTap: () async{
        bool x = await Navigator.push(context, MaterialPageRoute(
          builder: (context) => StepThreeDetailsScreen(i.toString(),
              myData[i], doctorId!, _image == null ? 'null' : base64image!),
        ));
        if(x){
          setState(() {
            future2 = fetchDoctorSchedule();
          });
        }
      },
      child: Container(
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
                      Text(daysList[i],
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  // Row(
                  //   children: [
                  //     SizedBox(width: 20,),
                  //     Image.asset(
                  //       "assets/detailScreenImages/time.png",
                  //       height: 13,
                  //       width: 13,
                  //       color: Colors.amber.shade700,
                  //     ),
                  //     SizedBox(width: 5,),
                  //     Text("${doctorScheduleDetails.data[i].startTime} - ${doctorScheduleDetails.data[i].endTime}", style: TextStyle(
                  //       fontWeight: FontWeight.w900,
                  //       fontSize: 11,
                  //     ),),
                  //   ],
                  // ),
                  Container(
                    child: ListView.builder(
                      itemCount: slotsCount[i],
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, ind){

                        int length = 0;
                        for(int k=0; k<i; k++){
                          length = length + slotsCount[k];
                        }
                        print(length);

                        return Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 20,),
                                Image.asset(
                                  "assets/detailScreenImages/time.png",
                                  height: 13,
                                  width: 13,
                                  color: AMBER,
                                ),
                                SizedBox(width: 5,),
                                Text("${doctorScheduleDetails!.data![ind + length].startTime} - ${doctorScheduleDetails!.data![ind+length].endTime}", style: TextStyle(
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
      ),
    );

  }

  // step four --------------------

  stepFour(){
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      body: HolidayList(),
    );
  }

  bool isSuccessful = false;

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
                  if(isSuccessful){
                    setState(() {
                      future = fetchDoctorProfileDetails();
                      future2 = fetchDoctorSchedule();
                      index = 0;
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(
                          builder: (context) => DoctorTabsScreen()
                        )
                      );
                    });
                  }else {
                    Navigator.pop(context);
                  }
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

  uploadData() async{
    int? departmentId;
    setState(() {
      departmentId = 0;
    });

    for(int i=0;i<departmentList.length;i++){
      if(specialityClass!.data![i].name == selectedValue){
        setState(() {
          departmentId = specialityClass!.data![i].id!;
          print("DEPARTMENT NAME ${i+1}" + selectedValue!);
        });
        break;
      }
    }
    await Future.delayed(Duration.zero);
    dialog();
    print("\n\n\nLoading...       ${doctorId}");
    print(healthcare);
    print(facebook);
    print(twitter);
    print(base64image);
    if(_image == null){
      final response = await post(Uri.parse("$SERVER_ADDRESS/api/doctoreditprofile"),
          body: {
            "doctor_id" : doctorId,
            "name" : name,
            "password" :password,
            "email" : doctorProfileDetails!.data!.email ?? "",
            "consultation_fees" : consultationFee,
            "aboutus" : aboutUs,
            "working_time" : workingTime,
            "address" : textEditingController.text,
            "lat" : _center!.latitude.toString(),
            "lon" : _center!.longitude.toString(),
            "phoneno" : phone,
            "services" : service,
            "healthcare" : healthcare,
            //widget.base64image == null ? "doctor_id" : widget.doctorId : "image" : widget.base64image,
            "department_id" : departmentId.toString(),
            "facebook_url" : facebook,
            "twitter_url" : twitter,
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
          setState(() {
            isSuccessful = true;
            messageDialog(SUCCESSFUL, PROFILE_UPDATED_SUCCESSFULLY);
          });
        }else{
          Navigator.pop(context);
          messageDialog(ERROR, jsonResponse['register']);
        }
      }
    }
    else{

      Dio d = Dio();

      var formData = dio.FormData.fromMap({
        "doctor_id" : doctorId,
        "name" : name,
        "password" :password,
        "email" : doctorProfileDetails!.data!.email ?? "",
        "aboutus" : aboutUs,
        "consultation_fees" : consultationFee,
        "working_time" : workingTime,
        "address" : textEditingController.text,
        "lat" : _center!.latitude.toString(),
        "lon" : _center!.longitude.toString(),
        "phoneno" : phone,
        "services" : service,
        "healthcare" : healthcare,
        "department_id" : departmentId.toString(),
        "facebook_url" : facebook,
        "twitter_url" : twitter,
        'image' : await dio.MultipartFile.fromFile(_image!.path, filename: 'image.jpg'),
      });
      var response = await d.post("$SERVER_ADDRESS/api/doctoreditprofile", data: formData).catchError((e){
        Navigator.pop(context);
        messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
        print(e);
      });

      // final response = await post("$SERVER_ADDRESS/api/doctoreditprofile",
      //     body: {
      //       "doctor_id" : doctorId,
      //       "name" : name,
      //       "password" :password,
      //       "email" : doctorProfileDetails.data.email ?? "",
      //       "aboutus" : aboutUs,
      //       "working_time" : workingTime,
      //       "address" : textEditingController.text,
      //       "lat" : _center.latitude.toString(),
      //       "lon" : _center.longitude.toString(),
      //       "phoneno" : phone,
      //       "services" : service,
      //       "healthcare" : healthcare,
      //       "image" : base64image,
      //       "department_id" : departmentId.toString(),
      //       "facebook_url" : facebook,
      //       "twitter_url" : twitter,
      //     }
      // ).catchError((e){
      //   Navigator.pop(context);
      //   messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      //   print(e);
      // });

      if(response.statusCode == 200){
        final jsonResponse = jsonDecode(response.data);
        print(jsonResponse['success']);
        print(response.data);
        if(jsonResponse['success'].toString() == "1"){
          Navigator.pop(context);
          setState(() {
            isSuccessful = true;
            messageDialog(SUCCESSFUL, PROFILE_UPDATED_SUCCESSFULLY);
          });
        }else{
          Navigator.pop(context);
          messageDialog(ERROR, response.data['register']);
        }
      }
    }
  }

}
