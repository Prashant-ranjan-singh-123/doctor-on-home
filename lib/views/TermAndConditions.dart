import 'dart:convert';

import 'package:appcode3/en.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';


class TermAndConditions extends StatefulWidget {
  @override
  _TermAndConditionsState createState() => _TermAndConditionsState();
}

class _TermAndConditionsState extends State<TermAndConditions> {

  // WebViewController? _controller;
  String fileText = "";
  bool isLoading = true;

  InAppWebViewController? webViewController;
  String url = "";
  double progress = 0;
  final GlobalKey webViewKey = GlobalKey();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    privacypolicy();
    //getMessages();
  }

  privacypolicy() async {
    final response = await get(
        // Uri.parse("$SERVER_ADDRESS/api/privecy"))
        Uri.parse("$SERVER_ADDRESS/api/about"))
        .catchError((e) {
      setState(() {
        isLoading = true;
      });
    });

    print("API : " + response.request!.url.toString());

    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse.toString());
    if (response.statusCode == 200 && jsonResponse['status'] == 1) {
      //print([0].name);
      if (mounted) {
        setState(() {
          fileText = jsonResponse['data']["trems"];
          isLoading = false;
        });
      }
    }
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator(),)
                  : SingleChildScrollView(
                child: Html(
                  data: """$fileText""",
                ),
              ),
              // child: isLoading? Center(child: CircularProgressIndicator(),):InAppWebView(
              //   key: webViewKey,
              //   // contextMenu: contextMenu,
              //   initialUrlRequest:
              //   // URLRequest(url: Uri.parse("https://github.com/flutter")),
              //   URLRequest(url: Uri.parse("${SERVER_ADDRESS}/privacy")),
              //   // initialFile: "assets/index.html",
              //   onWebViewCreated: (controller) {
              //     webViewController = controller;
              //
              //     // webViewController!.addJavaScriptHandler(handlerName:'handlerFoo', callback: (args) {
              //     //   // return data to JavaScript side!
              //     //   return {
              //     //     'bar': 'bar_value', 'baz': 'baz_value'
              //     //   };
              //     // });
              //     //
              //     // webViewController!.addJavaScriptHandler(handlerName: 'handlerFooWithArgs', callback: (args) {
              //     //   print(args);
              //     //   // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
              //     // });
              //
              //   },
              //   androidOnPermissionRequest:
              //       (controller, origin, resources) async {
              //     return PermissionRequestResponse(
              //         resources: resources,
              //         action: PermissionRequestResponseAction.GRANT);
              //   },
              //   shouldOverrideUrlLoading:
              //       (controller, navigationAction) async {
              //     var uri = navigationAction.request.url!;
              //
              //     if (![
              //       "http",
              //       "https",
              //       "file",
              //       "chrome",
              //       "data",
              //       "javascript",
              //       "about"
              //     ].contains(uri.scheme)) {
              //       if (await canLaunch(url)) {
              //         // Launch the App
              //         await launch(
              //           url,
              //         );
              //         // and cancel the request
              //         return NavigationActionPolicy.CANCEL;
              //       }
              //     }
              //
              //     return NavigationActionPolicy.ALLOW;
              //   },
              //   onConsoleMessage: (controller, consoleMessage) {
              //     print(consoleMessage);
              //   },
              // )
            ),
          )
      ),
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
                TERM_AND_CONDITIONS,
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
}

