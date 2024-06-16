import 'dart:async';
import 'dart:collection';
// import 'dart:convert';
import 'dart:io';
// import 'dart:typed_data';

import 'package:appcode3/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../en.dart';
import '../UserAppointmentDetails.dart';
import 'DoctorDashboard.dart';
import 'DoctorTabScreen.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String url;
  int isDoctor;
  String? AppointmentId;

  InAppWebViewScreen({Key? key, required this.url,required this.isDoctor,this.AppointmentId}) : super(key: key);
  @override
  _InAppWebViewScreenState createState() =>
      new _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();

  // String SUCCESS_PAYMENT_URL = "https://demo.freaktemplate.com/bookappointment_new/payment_success";
  String SUCCESS_PAYMENT_URL = "$SERVER_ADDRESS/payment_success";
  String FAIL_PAYMENT_URL = "$SERVER_ADDRESS/payment_failed";
  // String FAIL_PAYMENT_URL = "https://demo.freaktemplate.com/bookappointment_new/payment_failed";

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
          print('web view url ------------------------->');
          // Navigator.push(context, MaterialPageRoute (builder: (context)=>DoctorDashboard()));
        }
      },
    );
  }


  @override
  void dispose() {
    super.dispose();
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
                  '',
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            flexibleSpace: header(),
          ),
          // drawer: myDrawer(context: context),
          body: SafeArea(
              child: Column(children: <Widget>[
                // TextField(
                //   decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
                //   controller: urlController,
                //   keyboardType: TextInputType.url,
                //   onSubmitted: (value) {
                //     var url = Uri.parse(value);
                //     if (url.scheme.isEmpty) {
                //       url = Uri.parse("https://www.google.com/search?q=" + value);
                //     }
                //     webViewController?.loadUrl(urlRequest: URLRequest(url: url));
                //   },
                // ),
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        // contextMenu: contextMenu,
                        initialUrlRequest:
                        // URLRequest(url: Uri.parse("https://github.com/flutter")),
                        URLRequest(url: Uri.parse("${widget.url}")),
                        // initialFile: "assets/index.html",
                        initialUserScripts: UnmodifiableListView<UserScript>([]),
                        initialOptions: options,
                        pullToRefreshController: pullToRefreshController,
                        onWebViewCreated: (controller) {
                          webViewController = controller;

                          webViewController!.addJavaScriptHandler(handlerName:'handlerFoo', callback: (args) {
                            // return data to JavaScript side!
                            return {
                              'bar': 'bar_value', 'baz': 'baz_value'
                            };
                          });

                          webViewController!.addJavaScriptHandler(handlerName: 'handlerFooWithArgs', callback: (args) {
                            print(args);
                            // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
                          });

                        },
                        onLoadStart: (controller, url) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        androidOnPermissionRequest:
                            (controller, origin, resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          var uri = navigationAction.request.url!;

                          if (![
                            "http",
                            "https",
                            "file",
                            "chrome",
                            "data",
                            "javascript",
                            "about"
                          ].contains(uri.scheme)) {
                            if (await canLaunch(url)) {
                              // Launch the App
                              await launch(
                                url,
                              );
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          print('on load stop url success url ------------**************-----------> $url');

                          pullToRefreshController.endRefreshing();
                          print('success payment url  1---------------------$url');
                          setState(() {
                            print('success payment url  =2---------------------$url');
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                          print('success payment url  3---------------------${urlController.text}');
                          if(url.toString() == SUCCESS_PAYMENT_URL){
                            print('success payment link ---------------');
                            if(widget.isDoctor == 0){
                              print("widget.isDoctor ${widget.isDoctor}");
                              Navigator.pop(context,'success');
                            }
                            else{
                              Navigator.pop(context);
                              messageDialog1('Success', 'Your payment success');
                            }

                            // Timer(Duration(seconds: 1),(){
                            //   Navigator.pop(context,'success');
                            // });
                            // Navigator.pop(context,'Success');
                            // Navigator.push(context, MaterialPageRoute (builder: (context)=>TabsScreen()));
                            // Navigator.popUntil(context, (route) => route.isFirst);

                          }else if(url.toString() == FAIL_PAYMENT_URL){
                            print("url.toString() == FAIL_PAYMENT_URL");
                            Navigator.pop(context,'fail');
                            // Timer(Duration(seconds: 1),(){
                            //   Navigator.pop(context,'fail');
                            // });
                            print('fail payment link');
                          }
                          else{
                            print("Else");
                          }
                        },
                        onLoadError: (controller, url, code, message) {
                          pullToRefreshController.endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            pullToRefreshController.endRefreshing();
                          }
                          setState(() {
                            this.progress = progress / 100;
                            urlController.text = this.url;
                          });
                        },
                        onUpdateVisitedHistory: (controller, url, androidIsReload) {
                          setState(() {
                            this.url = url.toString();
                            urlController.text = this.url;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          print(consoleMessage);
                        },
                      ),
                      progress < 1.0
                          ? LinearProgressIndicator(value: progress)
                          : Container(),
                    ],
                  ),
                ),
                // ButtonBar(
                //   alignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     ElevatedButton(
                //       child: Icon(Icons.arrow_back),
                //       onPressed: () {
                //         webViewController?.goBack();
                //       },
                //     ),
                //     ElevatedButton(
                //       child: Icon(Icons.arrow_forward),
                //       onPressed: () {
                //         webViewController?.goForward();
                //       },
                //     ),
                //     ElevatedButton(
                //       child: Icon(Icons.refresh),
                //       onPressed: () {
                //         webViewController?.reload();
                //       },
                //     ),
                //   ],
                // ),
              ]))),
    );
  }

  messageDialog1(String s1, String s2) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              s1,
              style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute (builder: (context)=>TabsScreen()));
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TabsScreen(),
                      ));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserAppointmentDetails(widget.AppointmentId!),
                      ));
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                // color: Theme.of(context).primaryColor,
                child: Text(
                  OK,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                  ),
                ),
              ),
            ],
          );
        });
  }
}
