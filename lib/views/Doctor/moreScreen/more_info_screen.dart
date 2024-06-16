//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
//
//
// class DoctorInfoScreen extends StatefulWidget {
//   int profileType;
//   DoctorInfoScreen(this.profileType);
//
//   @override
//   State<DoctorInfoScreen> createState() => _DoctorInfoScreenState();
// }
//
// class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
//
//   var name;
//   BottomNavigationController bottomNavigationController = Get.put(BottomNavigationController());
//   // final viewUserProfileController = Get.put(ViewUserProfileController());
//
//
//
//
//   // ViewUserProfileController viewUserProfileController=Get.put(ViewUserProfileController());
//
//
//
//   bool isLoading = true;
//
//   var phoneNumber;
//   var email;
//   var id;
//   var image;
//
//   @override
//   void initState() {
//
//     getData();
//     super.initState();
//   }
//   getData() async {
//     final prefs = await SharedPreferences.getInstance();
//     name = prefs.getString('name');
//     phoneNumber = prefs.getInt('phone');
//     id=prefs.getInt('user_id').toString();
//     image = prefs.getString('image');
//     // viewUserProfileController.getProfileData();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         decoration:  BoxDecoration(
//           image: DecorationImage(
//             fit: BoxFit.cover,
//             image:brightness == Brightness.light? AssetImage('assets/order_list/bg-design.png'):AssetImage(
//               AppImages.imageAppBg,
//             ),
//           ),
//         ),
//         child: ListView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: EdgeInsets.zero,
//           children: [
//             Text(
//               More[AppConst.LANGUAGE_TYPE],
//               style: AppFontStyle.appBarTextStyle.copyWith( color: ThemeManager().getBlackColor),
//             ),
//             const SizedBox(height: 20),
//             GetBuilder<ViewUserProfileController>(
//                 init: ViewUserProfileController(),
//                 builder: (VUP) {
//                   return  VUP.isProfileDataLoading == true ? Center(child: CircularProgressIndicator(),) : GestureDetector(
//                     onTap: () async{
//                       // SharedPreferences prefs = await SharedPreferences.getInstance();
//                       // prefs.setString('userImage', VUP.viewProfileModel!.data.image.toString());
//                       // prefs.setString('userName', VUP.viewProfileModel!.data.name.toString());
//                       // profile.setId=VUP.viewProfileModel!.data.id.toInt();
//                       // profile.setName=VUP.viewProfileModel!.data.name.toString();
//                       // profile.setEmail=VUP.viewProfileModel!.data.email.toString();
//                       // profile.setImg=VUP.viewProfileModel!.data.image.toString();
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
//                       decoration: BoxDecoration(
//                         color: ThemeManager().textFieldFillColor.withOpacity(0.8),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Row(
//                         children: [
//                           Stack(
//                             alignment:Alignment.bottomRight,
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(50),
//                                 child: Container(
//                                   height: 50,
//                                   width: 50,
//                                   decoration: BoxDecoration(
//                                     borderRadius:
//                                     BorderRadius.circular(50),
//                                   ),
//                                   child: CachedNetworkImage(
//                                     imageUrl: VUP.viewProfileModel!.data.image == "null"
//                                         ? AppImages.userDefault
//                                         : AppConst.editProfile + VUP.viewProfileModel!.data.image.toString(),
//                                     placeholder: (context, url) =>
//                                         Image.asset(AppImages
//                                             .userDefault),
//                                     errorWidget: (context, url, error) => Image.asset(AppImages
//                                         .userDefault),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//
//                             ],
//                           ),
//
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Flexible(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   VUP.viewProfileModel!.data.name == '' && VUP.viewProfileModel!.data.name == null ?
//                                   // '${profile.getName}',
//                                   AppStrings.userName: VUP.viewProfileModel!.data.name.toString(),
//                                   style: GoogleFonts.poppins(
//                                       color: ThemeManager().getBlackColor,
//                                       fontWeight: FontWeight.w300,
//                                       fontSize: 20),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 Text(
//                                   VUP.viewProfileModel!.data.phone == '' && VUP.viewProfileModel!.data.phone == null ?
//                                   // "$phoneNumber",
//                                   // '123456789':  VUP.viewProfileModel!.data.phone.toString(),
//                                   '123456789':  phoneNumber.toString(),
//                                   style: AppFontStyle.smallGreyFont,
//                                   overflow: TextOverflow.ellipsis,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//
//                     ),
//                   );}
//
//             ),
//             const SizedBox(height: 12),
//
//             ///-------Give FeedBack-------
//             const SizedBox(height: 12),
//             GestureDetector(
//                 onTap: (){
//                   Get.to(()=>GiveFeedBackScreen());
//                 },
//                 child: MoreUserCard( title: Give_Feedback[AppConst.LANGUAGE_TYPE])),
//             ///-------Recommended Pharmacy-------
//             (widget.profileType == DOCTOR ) ? const SizedBox(height: 12) : SizedBox(height: 0,),
//             (widget.profileType == DOCTOR ) ?
//             GestureDetector(
//                 onTap: () {
//                   Get.to(() => RecommendedPharmacyScreen());
//                 },
//                 child: MoreUserCard(
//                     title: Recommended_Pharmacy[AppConst.LANGUAGE_TYPE])) : Container(),
//
//             // (widget.profileType == DOCTOR || widget.profileType == HOSPITAL) ? const SizedBox(height: 12) : SizedBox(height: 0,),
//             // (widget.profileType == DOCTOR || widget.profileType == HOSPITAL) ? GestureDetector(
//             //     onTap: (){
//             //       Get.to(()=>RecommendedPharmacyScreen());
//             //     },
//             //     child: MoreUserCard( title: Recommended_Pharmacy[AppConst.LANGUAGE_TYPE])) : Container(),
//             ///--------- call ambulance ---------
//             (widget.profileType == HOSPITAL) ? const SizedBox(height: 12) : SizedBox(height: 0,),
//             ( widget.profileType == HOSPITAL) ?
//             GetBuilder<ViewUserProfileController>(
//                 init: ViewUserProfileController(),
//                 builder: (VUP) {
//                   return GestureDetector(
//                       onTap: (){
//                         print("SetupProfileController ${VUP.ambulancePrice}");
//                         // print('ambulance price------${VUP.viewProfileModel!.data.ambulancePrice}');
//                         Get.to(()=>AddAmbulanceScreen(VUP.ambulancePrice));
//                       },
//                       child: MoreUserCard( title:  Add_Ambulance[AppConst.LANGUAGE_TYPE],));
//                 })
//                 : Container(),
//             ///--------- Department ---------
//             (widget.profileType == HOSPITAL) ? const SizedBox(height: 12) : SizedBox(height: 0,),
//             ( widget.profileType == HOSPITAL) ? GestureDetector(
//                 onTap: (){
//
//                   Get.to(()=>DepartmentListScreen());
//                 },
//                 child: MoreUserCard( title: Departments[AppConst.LANGUAGE_TYPE])) : Container(),
//             ///-------Log Out-------
//             const SizedBox(height: 12),
//             GestureDetector(
//                 onTap: () async {
//                   _showLogoutDialog(context,bottomNavigationController);
//                 },
//                 child: MoreUserCard(
//                     title: logOut[AppConst.LANGUAGE_TYPE])
//             ),
//
//             const SizedBox(height: 20),
//
//           ],
//         ),
//       ),
//
//
//     );
//   }
//
// }
//
//
//
// ///----------- logout dialog -----------------
// Future<void> _showLogoutDialog(context, BottomNavigationController bottomNavigationController,) async {
//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false, // user must tap button!
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20.0))),
//         contentPadding:
//         const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//         backgroundColor: ThemeManager().dropDownBackGroundColor,
//         // title: const Text('AlertDialog Title'),
//         content: SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                 Image.asset(
//                   AppImages.logout,
//                   height: 40,
//                 ),
//                 const SizedBox(width: 15),
//                 Text(Logout[AppConst.LANGUAGE_TYPE],
//                     style: AppFontStyle.appBarLightTextStyle
//                         .copyWith(fontSize: 35)),
//               ]),
//               const SizedBox(height: 10),
//               Center(
//                   child: Text(
//                     LogoutConMsg[AppConst.LANGUAGE_TYPE],
//                     style: AppFontStyle.smallGreyFont.copyWith(fontSize: 18),
//                     textAlign: TextAlign.center,
//                   )),
//               const SizedBox(height: 15),
//               Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         Get.back();
//                       },
//                       child: Container(
//                         height: 50,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: AppColor.blue),
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Center(
//                           child: Text(
//                             no[AppConst.LANGUAGE_TYPE],
//                             style: GoogleFonts.poppins(
//                                 color: ThemeManager().getFontBlackColor,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () async {
//                         await SharedPreferences.getInstance().then((pref) async {
//                           int? id = pref.getInt(AppConst.userId);
//                           // FirebaseDatabase.instance
//                           //     .reference()
//                           //     .child(id!.toString())
//                           //     .child("TokenList")
//                           //     .set({"device": 'logout'}).then((value) async {
//
//                           Get.delete<DoctorDashboardController>();
//                           Get.delete<AppointmentDetailController>();
//                           Get.delete<SetupProfileController>();
//
//                           Get.delete<PharmacyDashboardController>();
//                           Get.delete<AppointmentDetailController>();
//                           Get.delete<MyWalletController>();
//                           Get.delete<PharmacyProfileController>();
//                           Get.delete<UploadSpecialistController>();
//
//                           Get.delete<LaboratoryDashboardController>();
//                           Get.delete<LaboratoryOrderDetailController>();
//                           Get.delete<LaboratoryProfileController>();
//                           Get.delete<AllLaboratoryOrderListScreen>();
//
//                           Get.delete<HospitalDashboardController>();
//
//                           Get.delete<PharmacyProductListController>();
//
//                           Get.delete<BeautyDashboardController>();
//
//                           Get.delete<ViewUserProfileController>();
//                           Get.delete<MedicalDashboardController>();
//                           Get.delete<MedicalOrderDetailController>();
//                           Get.delete<MedicalProfileController>();
//                           Get.delete<MedicalProductListController>();
//
//
//                           try{
//                             CubeChatConnection.instance.logout();
//                           }catch(e){
//                             print('Logout error $e');
//                           }
//
//                           // if(setupProfileController.currentIndex==0){
//                           //   Get.delete<DoctorDashboardController>();
//                           //   Get.delete<AppointmentDetailController>();
//                           //   Get.delete<MyWalletController>();
//                           //   Get.delete<SetupProfileController>();
//                           //   Get.delete<UploadSpecialistController>();
//                           //   update();
//                           // }
//
//                           // else if(laboratoryProfileController.currentIndex == 0){
//                           //   Get.delete<LaboratoryDashboardController>();
//                           //   Get.delete<LaboratoryOrderDetailController>();
//                           //   Get.delete<LaboratoryProfileController>();
//                           //   Get.delete<AllLaboratoryOrderListScreen>();
//                           //   Get.delete<MyWalletController>();
//                           //   Get.delete<AppointmentDetailController>();
//                           //   update();
//                           // }
//
//                           // else if(pharmacyProfileController.currentIndex == 0){
//                           //   Get.delete<PharmacyDashboardController>();
//                           //   Get.delete<AppointmentDetailController>();
//                           //   Get.delete<MyWalletController>();
//                           //   Get.delete<PharmacyProfileController>();
//                           //   Get.delete<UploadSpecialistController>();
//                           //   update();
//                           // }
//
//                           // Get.delete<PharmacyDashboardController>();
//                           // Get.delete<AppointmentDetailController>();
//                           // Get.delete<MyWalletController>();
//                           // Get.delete<PharmacyProfileController>();
//                           // Get.delete<UploadSpecialistController>();
//                           //
//                           // // Get.delete<DoctorDashboardController>();
//                           // // Get.delete<AppointmentDetailController>();
//                           // // Get.delete<SetupProfileController>();
//                           //
//                           // Get.delete<LaboratoryDashboardController>();
//                           // Get.delete<LaboratoryOrderDetailController>();
//                           // Get.delete<LaboratoryProfileController>();
//                           // Get.delete<AllLaboratoryOrderListScreen>();
//                           //
//                           // Get.delete<HospitalDashboardController>();
//                           //
//                           // Get.delete<PharmacyProductListController>();
//                           // Get.delete<SetupProfileController>();
//
//
//                           // setupProfileController.currentIndex = 0;
//                           // final prefs = await SharedPreferences.getInstance();
//                           String? token = await pref.getString('token');
//                           await pref.clear();
//                           await pref.setString('token', token!);
//                           await pref.setBool('seen',true);
//                           // Get.delete<BottomNavigationController>();
//                           bottomNavigationController.tabIndex = 0;
//                           Get.offAll(() => Login());
//                           // });
//                         });
//
//                         // doctorDashboardController.doctorDashboardDetailModel.
//                         // CubeChatConnection.instance.logout();
//                         // setupProfileController.currentIndex = 0;
//                         // Get.delete<DoctorDashboardController>();
//                         // Get.delete<AppointmentDetailController>();
//                         // Get.delete<MyWalletController>();
//                         // Get.delete<SetupProfileController>();
//                         // Get.delete<UploadSpecialistController>();
//                         // final prefs = await SharedPreferences.getInstance();
//                         // prefs.clear();
//                         // // Get.delete<BottomNavigationController>();
//                         // tabIndex = 0;
//                         // Get.offAll(() => Login());
//                       },
//                       child: Container(
//                         height: 50,
//                         decoration: BoxDecoration(
//                           image: const DecorationImage(
//                             image: AssetImage(
//                               AppImages.imageBtnBg2,
//                             ),
//                             fit: BoxFit.fill,
//                           ),
//                           // border:Border.all(color:AppColor.blue),
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         child: Center(
//                           child: Text(
//                             yes[AppConst.LANGUAGE_TYPE],
//                             style: GoogleFonts.poppins(
//                                 color: AppColor.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
//



import 'dart:convert';
import 'package:connectycube_sdk/connectycube_chat.dart';

import 'package:appcode3/en.dart';
import 'package:appcode3/main.dart';
import 'package:appcode3/modals/DoctorAppointmentClass.dart';
import 'package:appcode3/modals/DoctorPastAppointmentsClass.dart';
import 'package:appcode3/views/Doctor/DoctorChatListScreen.dart';
import 'package:appcode3/views/Doctor/DoctorAllAppointments.dart';
import 'package:appcode3/views/Doctor/DoctorAppointmentDetails.dart';
import 'package:appcode3/views/Doctor/DoctorProfileWithRating.dart';
import 'package:appcode3/views/Doctor/moreScreen/change_password_screen.dart';
import 'package:appcode3/views/Doctor/moreScreen/income_report.dart';
import 'package:appcode3/views/Doctor/moreScreen/subscription_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';



class MoreInfoScreen extends StatefulWidget {
  @override
  _MoreInfoScreenState createState() => _MoreInfoScreenState();
}

class _MoreInfoScreenState extends State<MoreInfoScreen> {

  DoctorPastAppointmentsClass? doctorAppointmentsClass;
  DoctorProfileWithRating? doctorProfileWithRating;
  Future? future;
  Future? future2;
  bool isAppointmentAvailable = false;
  String? doctorId;
  bool isErrorInLoading = false;

  fetchDoctorAppointment() async{
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/doctoruappointment?doctor_id=$doctorId"));
    print('dashboard api -> ${response.request}');
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'].toString() == "1") {
        setState(() {
          isAppointmentAvailable = true;
          doctorAppointmentsClass =
              DoctorPastAppointmentsClass.fromJson(jsonResponse);
        });
      }else{
        setState(() {
          isAppointmentAvailable = false;
        });
      }
    }
  }

  fetchDoctorDetails() async{
    print('doctor detail url ->${'$SERVER_ADDRESS/api/doctordetail?doctor_id=$doctorId'}');
    final response = await get(Uri.parse("$SERVER_ADDRESS/api/doctordetail?doctor_id=$doctorId"));
    //     .catchError((e){
    //   setState(() {
    //     isErrorInLoading = true;
    //   });
    // });
    try {
      if (response.statusCode == 200) {
        print("url --> ${response.request!.url}");
        print("body --> ${response.body}");
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          try {
            doctorProfileWithRating = DoctorProfileWithRating.fromJson(jsonResponse);
            // SharedPreferences sp = await SharedPreferences.getInstance();
            // sp.setString('profilePic', doctorProfileWithRating!.data!.image??'');
            // if(doctorProfileWithRating!.data!.isSubscription==0){
            //   Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => DoctorChooseYourPlan(doctorUrl: doctorProfileWithRating!.data!.image.toString())),
            //   );
            // }
            // ;
            print('doctor image is ${doctorProfileWithRating!.data!.image}');
          }catch(E){
            print('Dashboard error is : ${E}');
          }
        });
      } else {
        setState(() {

        });
      }
    }catch(e){

      setState(() {
        isErrorInLoading = true;
      });
    }
  }

  @override
  void initState() {
    // nativeAdController.setNonPersonalizedAds(true);
    // nativeAdController.setTestDeviceIds(["0B43A6DF92B4C06E3D9DBF00BA6DA410"]);
    // nativeAdController.stateChanged.listen((event) {
    //   print(event);
    // });
    // TODO: implement initState
    super.initState();
    //getMessages();
    SharedPreferences.getInstance().then((pref){
      setState(() {
        doctorId = pref.getString("userId");
        future = fetchDoctorAppointment();
        future2 = fetchDoctorDetails();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: header(),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                doctorProfile(),
                upCommingAppointments(),
              ],
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
              SizedBox(width: 15,),
              Text(
                  MORE_INFO,
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

  Widget doctorProfile() {
    return isErrorInLoading ? Container(
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
    ) :FutureBuilder(
        future: future2,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting || doctorId == null){
            return Container(
                height: 100,
                child: Center(child: CircularProgressIndicator(
                  strokeWidth: 2,
                )));
          }
          return Container(
            //margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(10),
              // color: Colors.red
              color: Theme.of(context).backgroundColor,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: doctorProfileWithRating!.data!.image!,
                    height: 85,
                    width: 85,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 20, width: 20,),
                    ),),
                    errorWidget: (context,url,err) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 20, width: 20,),
                    )),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctorProfileWithRating!.data!.name!,
                              style: Theme.of(context).textTheme.subtitle1!.apply(fontWeightDelta: 2),
                            ),
                            Row(
                              children: [
                                Text(doctorProfileWithRating!.data!.departmentName!.isEmpty ? SPECIALITY : doctorProfileWithRating!.data!.departmentName!,
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: Theme.of(context).primaryColorDark),
                                ),
                                SizedBox(width: 10,),
                                Image.asset(
                                  "assets/detailScreenImages/star_fill.png",
                                  height: 15,
                                  width: 15,
                                ),
                                SizedBox(width: 5,),
                                Text(double.parse(doctorProfileWithRating!.data!.avgratting.toString()).toString(),
                                  style: Theme.of(context).textTheme.bodyText1!.apply(color: Theme.of(context).primaryColorDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        child: Text(doctorProfileWithRating!.data!.address ?? ADDRESS_GOES_HERE,
                          style: Theme.of(context).textTheme.caption!.apply(
                            color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                            fontSizeDelta: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10,),

              ],
            ),
          );
        }
    );
  }

  Widget upCommingAppointments(){
    return Container(
      margin: EdgeInsets.only(top: 15),

      // margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ///---------  change password ----------
          GestureDetector(
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChangePassword()),
              );
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),

              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(CHANGE_PASSWORD,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Icon(Icons.arrow_forward_ios,size: 20,),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 15,),
          ///--------- subscription ------------
          GestureDetector(
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => SubScriptionScreen()),
              );
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),

              decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(SUBSCRIPTION,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Icon(Icons.arrow_forward_ios,size: 20,),
                    // TextButton(onPressed: (){
                    //   Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => DoctorAllAppointments()),
                    //   );
                    // }, child: Text(SEE_ALL,
                    //     style: Theme.of(context).textTheme.bodyText2!.apply(
                    //       color: Theme.of(context).hintColor,
                    //       fontWeightDelta: 5,
                    //     )
                    // ),)
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 15,),

          ///--------- subscription ------------
          GestureDetector(
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => IncomeReport()),
              );
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),

              decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(INCOME_REPORT,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Icon(Icons.arrow_forward_ios,size: 20,),
                    // TextButton(onPressed: (){
                    //   Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => DoctorAllAppointments()),
                    //   );
                    // }, child: Text(SEE_ALL,
                    //     style: Theme.of(context).textTheme.bodyText2!.apply(
                    //       color: Theme.of(context).hintColor,
                    //       fontWeightDelta: 5,
                    //     )
                    // ),)
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 15,),
          ///-----------logoout -------------
          GestureDetector(
            onTap: (){
              messageDialog(LOGOUT, ARE_YOU_SURE_TO_LOGOUT);
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => LogOutScreen()
              // ));
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),

              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LOGOUT,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Icon(Icons.arrow_forward_ios,size: 20),
                    // TextButton(onPressed: (){
                    //   Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => DoctorAllAppointments()),
                    //   );
                    // }, child: Text(SEE_ALL,
                    //     style: Theme.of(context).textTheme.bodyText2!.apply(
                    //       color: Theme.of(context).hintColor,
                    //       fontWeightDelta: 5,
                    //     )
                    // ),)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        barrierDismissible: true,
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
                onPressed: () async{
                  try {
                    CubeChatConnection.instance.logout();
                  } catch (e) {}
                  await SharedPreferences.getInstance().then((pref){
                    pref.setBool("isLoggedInAsDoctor", false);
                    pref.setBool("isLoggedIn", false);
                    pref.clear();
                    // pref.setString("userId", null);
                    // pref.setString("name", null);
                    // pref.setString("phone", null);
                    // pref.setString("email", null);
                    // pref.setString("token", null);
                  });
                  // Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => TabsScreen(),
                  ));
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).hintColor,
                ),
                // color: Theme.of(context).hintColor,
                child: Text(YES,style: GoogleFonts.poppins(
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

