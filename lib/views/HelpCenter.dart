import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';


class HelpCenter extends StatefulWidget {
  @override
  _HelpCenterState createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {

  //WebViewController _controller;
  String fileText = "";
  bool isLoading = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadHtmlFromAssets();
    //getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            flexibleSpace: header(),
            leading: Container(),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: isLoading?Center(child: CircularProgressIndicator(),):Html(
                data: """$fileText""",
                onLinkTap: (url,_,__,___){
                    launch(url!);
                },
              ),
            ),
          )
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
              SizedBox(width: 15,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                HELP_CENTER,
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

  _loadHtmlFromAssets() async {
    String x = await rootBundle.loadString('assets/helpcenter.html');

    setState(() {
      fileText = x;
      isLoading = false;
    });
    // _controller.loadUrl(Uri.dataFromString(
    //     fileText,
    //     mimeType: 'text/html',
    //     encoding: Encoding.getByName('utf-8')
    // ).toString());
  }
}

