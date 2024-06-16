//import 'package:facebook_audience_network/ad/ad_native.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
// import 'package:native_admob_flutter/native_admob_flutter.dart';

import 'main.dart';

class CustomAds{

  final String ADMOB_ID = "ca-app-pub-7803172892594923/5172476997";
  final String FACEBOOK_AD_ID = "727786934549239_727793487881917";

  // final nativeAdController = NativeAdmobController();

  Widget nativeAds({required int id}){

    return
      //id==0
      //    ?
      Container(
        margin: EdgeInsets.symmetric(
            vertical: 10
        ),
        child: NativeAds(),
      );
    //   FacebookNativeAd(
    //     placementId: FACEBOOK_AD_ID,
    //     adType: NativeAdType.NATIVE_BANNER_AD,
    //     bannerAdSize: NativeBannerAdSize.HEIGHT_50,
    //     width: double.infinity,
    //     backgroundColor: Colors.blue,
    //     titleColor: Colors.white,
    //     descriptionColor: Colors.white,
    //     buttonColor: Colors.deepPurple,
    //     buttonTitleColor: Colors.white,
    //     buttonBorderColor: Colors.white,
    //     listener: (result, value) {
    //       print("Native Ad: $result --> $value");
    //     },
    //   );
  }
}


class NativeAds extends StatefulWidget {
  const NativeAds({Key? key}) : super(key: key);

  @override
  _NativeAdsState createState() => _NativeAdsState();
}

class _NativeAdsState extends State<NativeAds>
    with AutomaticKeepAliveClientMixin {
  Widget? child;

  // final controller = NativeAdController();
  //
  @override
  void initState() {
    super.initState();
    // controller.load();

  }



  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (child != null) return child!;
    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}

