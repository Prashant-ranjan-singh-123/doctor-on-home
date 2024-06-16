import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:appcode3/views/incoming_call_image_name.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:video_thumbnail/video_thumbnail.dart';

import '../main.dart';
import 'MyPhotoViewer.dart';
import 'MyVideoPlayer.dart';
import 'MyVideoThumbnail.dart';

class ChatScreen extends StatefulWidget {

  String? userName;
  String? uid;
  dynamic connectCubId;
  bool? isUser;
  List<dynamic>? deviceToken;
  String? callerImage;
  String? reciverImage;

  ChatScreen(this.userName, this.uid, this.connectCubId, this.isUser,
      this.deviceToken, this.callerImage, this.reciverImage);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {

  int listCount = 0;
  bool showButton = false;
  String? myUid;
  String globalMessage = "";
  String? channelId;
  String message = "";
  ScrollController _lvScrollCtrl = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  int perPage = 20;
  bool isLoading = false;
  bool showLoadingIndicator = false;
  bool isUserOnline = false;
  String userStatus = "";
  TextField? textField;
  DateTime? lastMessageDate;
  DateTime? dateTimeNext;
  int myMessages = 0;
  int yourMessages = 0;
  Timestamp? timestamp;
  String lastMessageUid = "";
  String myName = "";
  bool isSeenStatusExist = false;
  FilePickerResult? file;
  Uint8List? image;
  String? trimmedVideoPath;
  File? croppedFile;
  Set<dynamic>? oppConnectCubId;
  String senderName = '';
  String? myconnectCubId;
  Map<String, UploadItem> _tasks = {};
  bool isEmojiKeybord = false;
  bool isKeybord = false;
  String opponentName = '';
  String opponentImage = '';


  bool isFileUploading = false;
  double uploadingProgress = 0.0;
  Uint8List? fileThumbnail;
  bool isFirstMessage = false;
  Duration? timeDifference;
  List<String> monthsList = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  Future? future;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  DatabaseReference databaseReference2 = FirebaseDatabase.instance.ref();
  DatabaseReference databaseReference3 = FirebaseDatabase.instance.ref();

  Map<String, StreamSubscription> _progressSubscription = {};
  Map<String, StreamSubscription> _resultSubscription = {};

  var ds;
  bool isTyping = false;
  String imageLink = "";
  Timer timer = Timer(Duration(seconds: 1), () {});
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String token = "";
  String name = "";
  List<String> tokensList = [];
  int? requestStatus;
  DatabaseReference? seenRef;
  var seenRefListner;
  var checkSeenRefListner;
  int messageCount = 0;
  List<String> pendingMessagesList = [];
  bool showLoading = true;
  DateTime? currentTime;
  String? mytoken;
  late StreamSubscription<bool> keyboardSubscription;
  late FocusNode myFocusNode;
  File? _image;
  final picker = ImagePicker();

  getFileAccessPermision() async {
    var status = await Permission.manageExternalStorage.status;
    var status2 = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
      var status = await Permission.manageExternalStorage.status;
    }
    if (!status2.isGranted) {
      await Permission.storage.request();
    }
  }

  Future getImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        // setState(() {
        _image = File(pickedFile.path);
        print('image path is ${_image!.path}');
        uploadFileToServer(
            File(_image!.path).readAsBytesSync(), "jpg", "file", _image!.path);
        // });
        // Navigator.pop(context);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose type'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 4,
                      child: InkWell(
                        onTap: () {
                          getImage();
                          Navigator.pop(context);
                          // CallManager.instance.startNewCall(
                          //     context, CallType.AUDIO_CALL, {callId});
                          // Navigator.pop(context);
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                "assets/moreScreenImages/header_bg.png",
                                height: 50,
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 4,
                                fit: BoxFit.fill,
                                // width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            Center(
                              child:
                              // Text(
                              //     'Audio Call',
                              //     style: Theme.of(context).textTheme.bodyText1!.apply(
                              //         color: Theme.of(context).backgroundColor,
                              //         fontSizeDelta: 2
                              //     )
                              // ),
                              Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 4,
                      child: InkWell(
                        onTap: () {
                          pickFile();
                          Navigator.pop(context);
                          // CallManager.instance.startNewCall(
                          //     context, CallType.VIDEO_CALL, {callId});
                          // Navigator.pop(context);
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                "assets/moreScreenImages/header_bg.png",
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 4,
                                height: 50,
                                fit: BoxFit.fill,
                                // width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            Center(
                              child:
                              // Text(
                              //     'Video Call',
                              //     style: Theme.of(context).textTheme.bodyText1!.apply(
                              //         color: Theme.of(context).backgroundColor,
                              //         fontSizeDelta: 2
                              //     )
                              // ),
                              Icon(
                                Icons.file_present,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )
                // Text('This is a demo alert dialog.'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print('userName ${widget.userName}');
    print('uid ${widget.uid}');
    print('connectCubId ${widget.connectCubId}');
    print('isUser ${widget.isUser}');
    print('deviceToken ${widget.deviceToken}');
    print('callerImage ${widget.callerImage}');
    print('reciverImage ${widget.reciverImage}');

    Map mm = {
      'userName': widget.userName,
      'uid': widget.uid,
      'connectCubId': widget.connectCubId,
      'isUser': widget.isUser,
      'deviceToken': widget.deviceToken,
      'callerImage': widget.callerImage,
      'reciverImage': widget.reciverImage
    };

    print(mm);

    getFileAccessPermision();

    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    print('Keyboard visibility direct query: ${keyboardVisibilityController
        .isVisible}');

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool isKeybord) {
          print('Keyboard visibility update. Is visible: $isKeybord');
          setState(() {
            this.isKeybord = isKeybord;
          });

          if (isKeybord && isEmojiKeybord) {
            setState(() {
              isEmojiKeybord = false;
            });
          }
        });

    myFocusNode = FocusNode();

    getCurrentTime();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        // myUid = value.getString("userId");
        // myUid = value.getString('userId');
        myUid = value.getString('userIdWithAscii');
        // myUid = value.getString('uid');
        print('user id save in storage ${value.getString('userId')}');
        print('user id $myUid');
        senderName = value.getString('name')!;
        mytoken = value.getString('token');

        print('my token : $mytoken');
        // print('sender name $senderName');
        // name = myName = value.getString("name");
      });
      loadUserProfile();
      // doesSendNotification(widget.uid, false);
      print(widget.uid);
      getMyUid();
      checkSeenStatus();
      getUserPreference();
      markAsSeen();
      // initForegroundService();
      oppConnectCubId = {widget.connectCubId};
      myconnectCubId = value.getString('myCCID');
      // print('my cc id $myconnectCubId');
    });
    // SharedPrefs.getUser().then((value){
    //   myconnectCubId = value!.id;
    //   print('my cc id $myconnectCubId');
    // });
    WidgetsBinding.instance!.addObserver(this);
    _lvScrollCtrl.addListener(() {
      //print(_lvScrollCtrl);1
      if (_lvScrollCtrl.position.maxScrollExtent ==
          _lvScrollCtrl.position.pixels) {
        setState(() {
          showLoadingIndicator = true;
          perPage += 20;
          print(showLoadingIndicator);
          //print("updated perpage to"+perPage.toString());
        });
      }
    });

    SharedPreferences.getInstance().then((value) {
      // value.setString("payload", null);
      value.remove("payload");
      value.commit();
      print("0-> Chat Screen Payload : ${value.getString("payload")}");
    });
  }

  loadUserProfile() async {
    await FirebaseDatabase.instance.ref(widget.uid!).once().then((value) {
      setState(() {
      });
    });

    DatabaseReference starCountRef =
    FirebaseDatabase.instance.ref(widget.uid!).child("TokenList");
    starCountRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value;
      print("----------> " + event.snapshot.value.toString());
      if (data != null) {
        Map<dynamic, dynamic>.from(data as Map).forEach((key, values) {
          setState(() {
            tokensList.add(data[key]);
          });
        });
      }
      print("final token list :- ${tokensList}");
    });

    DatabaseReference starCountRef2 =
    FirebaseDatabase.instance.ref(myUid!).child("chatlist")
        .child(widget.uid!);

    starCountRef2.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot.value as Map;
      // print("----------> " + value.value.toString());
      // print("----------> " + snapshot.toString());
      if (snapshot != null) {
        // value;
        setState(() {
          requestStatus = snapshot['status'] ?? 1;
        });
      } else {
        setState(() {
          requestStatus = 1;
        });
      }
    });
  }

  uploadDataWithBackgroundService(String taskId, result) async {
    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection("Chats")
        .doc(channelId).collection("All Chat");

    print("501 -- ${jsonDecode(result.response)['data']}");
    print("503 -- ${jsonDecode(result.response)}");
    await collectionReference.doc(taskId.toString()).update({

      "msg": jsonDecode(result.response)['data'],
      "time": DateTime.now().toString(),
      "uid": myUid,
      "type": jsonDecode(result.response)['data'].toString().contains(".jpg")
          ? 1
          : 2,
    });

    if (isFirstMessage) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(myUid!)
          .child("chatlist")
          .child(widget.uid!);

      await dbRef.set({
        "time": DateTime.now().toString(),
        "last_msg": jsonDecode(result.response)['data'],
        "type": jsonDecode(result.response)['data'].toString().contains(".jpg")
            ? 1
            : 2,
        "messageCount": 0,
        "status": 1,
        "channelId": channelId
      });

      DatabaseReference dbRef2 = FirebaseDatabase.instance.ref(widget.uid!)
          .child("chatlist")
          .child(myUid!);

      await dbRef2.once().then((DatabaseEvent event) {
        final snapshot = event.snapshot.value as Map;
        print("method 5");

        dbRef2.set({
          "time": DateTime.now().toString(),
          "last_msg": jsonDecode(result.response)['data'],
          "type": jsonDecode(result.response)['data'].toString().contains(
              ".jpg") ? 1 : 2,
          "messageCount": snapshot.isEmpty == null
              ? 1
              : snapshot['messageCount'] + 1,
          "status": 0,
          "channelId": channelId
        });
      });
      setState(() {
        isFirstMessage = false;
      });
    }
    else {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(myUid!)
          .child("chatlist")
          .child(widget.uid!);
      print("method 1");
      await dbRef.update({
        // "time": DateTime.now().subtract(timeDifference!).toString(),
        "time": DateTime.now().toString(),
        "last_msg": jsonDecode(result.response)['data'],
        "type": jsonDecode(result.response)['data'].toString().contains(".jpg")
            ? 1
            : 2,
        "messageCount": 0,
        "channelId": channelId
      });

      DatabaseReference dbRef2 = FirebaseDatabase.instance.ref(widget.uid!)
          .child("chatlist")
          .child(myUid!);


      await dbRef2.once().then((DatabaseEvent event) {
        final snapshot = event.snapshot.value as Map;
        print("method 2");

        dbRef2.update({
          // "time": DateTime.now().subtract(timeDifference!).toString(),
          "time": DateTime.now().toString(),
          "last_msg": jsonDecode(result.response)['data'],
          "type": jsonDecode(result.response)['data'].toString().contains(
              ".jpg") ? 1 : 2,
          "messageCount": snapshot.isEmpty ? 1 : snapshot['messageCount'] + 1,
          "channelId": channelId
        });
      });
    }

    for (int i = 0; i < tokensList.length; i++) {
      sendNotification(senderName, "Shared a file", tokensList[i]);
    }

    //Toast.show(collectionReference., context, duration: 5);
    _progressSubscription['$taskId']?.cancel();
    _resultSubscription['$taskId']?.cancel();
  }

  getMyUid() async {
    print("My uid : " + myUid!);
    //myUid = FirebaseAuth.instance.currentUser.uid;
    if (widget.uid!.compareTo(myUid!) < 0) {
      setState(() {
        channelId = (widget.uid! + myUid!);
      });
    } else {
      setState(() {
        channelId = myUid! + widget.uid!;
      });
    }
    print("channelId : " + channelId!);
  }

  getUserPreference() {
    databaseReference2
        .child(widget.uid!)
        .onValue
        .listen((DatabaseEvent event) {
      final snapshot = event.snapshot.value as Map;
      // print('chat screen back value ===========<><><><>');
      // print(event.snapshot.value);
      // print('===========<><><><>');
      if (event.snapshot.value == null) {
        Navigator.pop(context);
      }
      else {
        if (mounted) {
          setState(() {
            if (event.snapshot.value != null) {
              if (snapshot['presence'] != null &&
                  currentTime != null) {
                if (snapshot['presence']) {
                  print("time difference : " +
                      currentTime
                      !.difference(
                          DateTime.parse(snapshot['last_seen']
                              .toString()))
                          .toString());
                  if (currentTime
                  !.difference(
                      DateTime.parse(
                          snapshot['last_seen'].toString()))
                      .inMinutes <= 1) {
                    userStatus = "Online";
                  } else {
                    userStatus = "last seen ${
                        DateTime.parse(snapshot['last_seen']
                            .toString()).add(DateTime
                            .now()
                            .timeZoneOffset)
                            .toString()
                            .substring(0, 19)
                    }";
                  }
                } else {
                  print("last seen ${snapshot['last_seen']}");
                  userStatus = "last seen ${snapshot['last_seen']
                      .toString()
                      .substring(0, 19)}";
                }
              }
            }
          });
        }
      }
    });

    databaseReference2
        .child(myUid!)
        .child("chatlist")
        .child(widget.uid!)
        .child("typingTime")
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.value == 1) {
        print("Typing........");
        setState(() {
          isTyping = true;
          showLoading = false;
        });
      } else {
        setState(() {
          isTyping = false;
          showLoading = false;
        });
      }
      //getTypingStatus();

    });
  }

  getTypingStatus() {
    setState(() {
      timer.cancel();
      isTyping = true;
      timer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          isTyping = false;
        });
      });
    });
  }

  Timer markTypingAsZerotimer = Timer(Duration(seconds: 1), () {});

  void markAsTyping() {
    DatabaseReference db = FirebaseDatabase.instance.ref();
    db.child(widget.uid!).child("chatlist").child(myUid!).update({
      "typingTime": 1
    },
    );

    db
        .child(widget.uid!)
        .child("chatlist")
        .child(myUid!)
        .child("typingTime")
        .onValue
        .listen((event) {
      markTypingAsZerotimer.cancel();
      if (event.snapshot.value == 1) {
        markTypingAsZerotimer = Timer(Duration(seconds: 1), () {
          db.child(widget.uid!).child("chatlist").child(myUid!).update({
            "typingTime": 0
          },);
        });
      }
    });
  }

  Future<bool> onBackPress() {
    if (isEmojiKeybord) {
      setState(() {
        isEmojiKeybord = false;
      });
    } else {
      // Get.back();
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ds.cancel();
    seenRefListner.cancel();
    checkSeenRefListner.cancel();
    keyboardSubscription.cancel();
    print("On dispose called");
    WidgetsBinding.instance.removeObserver(this);
  }

  final controller = Get.put(IncomingManageController());

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      getCurrentTime();
      getUserPreference();
      markAsSeen();
      checkSeenStatus();
    } else {
      ds.cancel();
      seenRefListner.cancel();
      checkSeenRefListner.cancel();
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,

            flexibleSpace: Stack(
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
                        widget.userName ?? "",
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
            ),
            leading: Container(),
          ),
          body: requestStatus == null
              ? Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("Chats")
                        .doc(channelId)
                        .collection("All Chat")
                        .orderBy("time", descending: true)
                        .limit(perPage).snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.length > 0) {
                        return Container(
                          child: ListView.builder(
                            controller: _lvScrollCtrl,
                            reverse: true,
                            itemCount: snapshot.data!.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (index == snapshot.data!.docs.length) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                    snapshot.data!.docs.length > 20) {
                                  print("\n\nwaiting : loaded");
                                  return Container();
                                } else if (snapshot.connectionState ==
                                    ConnectionState.active &&
                                    snapshot.data!.docs.length > 20) {
                                  print("\n\nactive : Loading " +
                                      snapshot.hasData.toString());
                                  isLoading = true;
                                  Timer(Duration(seconds: 3), () {
                                    setState(() {
                                      isLoading = showLoadingIndicator = false;
                                    });
                                  });
                                  return isLoading ? Container(
                                    margin: EdgeInsets.all(30),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.grey
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) : Container();
                                } else if (snapshot.data!.docs.length > 20) {
                                  print(snapshot.connectionState);
                                  return Container(
                                    margin: EdgeInsets.all(0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }

                              else if (index < snapshot.data!.docs.length) {
                                lastMessageUid =
                                snapshot.data!.docs[index]['uid'];
                                lastMessageDate = DateTime.parse(
                                    snapshot.data!.docs[index]['time']
                                        .toString())
                                    .toLocal();


                                int k = snapshot.data!.docs.length > index
                                    ? index + 1
                                    : snapshot.data!.docs.length - 1;

                                int daysDifference = DateTime
                                    .now()
                                    .difference(DateTime.parse(
                                    snapshot.data!.docs[index]['time']
                                        .toString())
                                    .toLocal())
                                    .inDays;
                                int daysDifference2 = k >=
                                    snapshot.data!.docs.length ? 3 : DateTime
                                    .now()
                                    .difference(DateTime.parse(
                                    snapshot.data!.docs[index + 1]['time']
                                        .toString()).toLocal())
                                    .inDays;

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      15, 0.5, 15, 1),
                                  child: Column(
                                    children: [

                                      k >= snapshot.data!.docs.length
                                          ? (daysDifference2 -
                                          daysDifference) >=
                                          1
                                          ? Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              height: 10,
                                              thickness: 0.5,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Text(daysDifference == 0
                                              ? "Today"
                                              : daysDifference == 1
                                              ? "Yesterday"
                                              : "${DateTime
                                              .now()
                                              .add(
                                              Duration(days: -daysDifference))
                                              .day}  ${monthsList[DateTime
                                              .now()
                                              .add(
                                              Duration(days: -daysDifference))
                                              .month - 1]}, ${DateTime
                                              .now()
                                              .add(
                                              Duration(days: -daysDifference))
                                              .year}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            child: Divider(
                                              height: 30,
                                              thickness: 0.5,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      )
                                          : Container()
                                          : lastMessageDate!.compareTo(
                                          DateTime.parse(
                                              snapshot.data!.docs[index]['time']
                                                  .toString()).toLocal()) == 0
                                          ? Container()
                                          : (daysDifference2 -
                                          daysDifference) >=
                                          1 ? Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              height: 10,
                                              thickness: 0.5,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Text(daysDifference == 0
                                              ? "Today"
                                              : daysDifference == 1
                                              ? "Yesterday"
                                              : "${DateTime
                                              .now()
                                              .add(
                                              Duration(days: -daysDifference))
                                              .day}  ${monthsList[DateTime
                                              .now()
                                              .add(
                                              Duration(days: -daysDifference))
                                              .month - 1]}, ${DateTime
                                              .now()
                                              .add(
                                              Duration(days: -daysDifference))
                                              .year}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                            child: Divider(
                                              height: 30,
                                              thickness: 0.5,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ) : Container(),

                                      Row(
                                        mainAxisAlignment: snapshot.data
                                        !.docs[index]['uid'] == myUid
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              k >= snapshot.data!.docs.length
                                                  ? Padding(
                                                padding: const EdgeInsets
                                                    .fromLTRB(0, 5, 0, 0),
                                                child: Text(
                                                  DateTime
                                                      .parse(snapshot.data
                                                  !.docs[index]['time']
                                                      .toString())
                                                      .add(DateTime
                                                      .now()
                                                      .timeZoneOffset)
                                                      .hour
                                                      .toString()
                                                      + ":" +
                                                      (DateTime
                                                          .parse(snapshot.data
                                                      !.docs[index]['time']
                                                          .toString())
                                                          .add(DateTime
                                                          .now()
                                                          .timeZoneOffset)
                                                          .minute < 10
                                                          ? "0" + DateTime
                                                          .parse(snapshot.data
                                                      !.docs[index]['time']
                                                          .toString())
                                                          .add(DateTime
                                                          .now()
                                                          .timeZoneOffset)
                                                          .minute
                                                          .toString()
                                                          : DateTime
                                                          .parse(snapshot.data
                                                      !.docs[index]['time']
                                                          .toString())
                                                          .add(DateTime
                                                          .now()
                                                          .timeZoneOffset)
                                                          .minute
                                                          .toString()),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10
                                                  ),
                                                ),
                                              )
                                                  : lastMessageUid ==
                                                  snapshot.data!.docs[index +
                                                      1]['uid'] &&
                                                  (DateTime
                                                      .parse(snapshot.data
                                                  !.docs[index]['time']
                                                      .toString())
                                                      .add(DateTime
                                                      .now()
                                                      .timeZoneOffset)
                                                      .minute - DateTime
                                                      .parse(
                                                      snapshot.data!
                                                          .docs[index +
                                                          1]['time'].toString())
                                                      .add(DateTime
                                                      .now()
                                                      .timeZoneOffset)
                                                      .minute) == 0
                                                  ? Container() : Padding(
                                                padding: const EdgeInsets
                                                    .fromLTRB(0, 5, 0, 0),
                                                child: Text(
                                                  DateTime
                                                      .parse(snapshot.data
                                                  !.docs[index]['time']
                                                      .toString())
                                                      .add(DateTime
                                                      .now()
                                                      .timeZoneOffset)
                                                      .hour
                                                      .toString()
                                                      + ":" +
                                                      (DateTime
                                                          .parse(snapshot.data
                                                      !.docs[index]['time']
                                                          .toString())
                                                          .add(DateTime
                                                          .now()
                                                          .timeZoneOffset)
                                                          .minute < 10
                                                          ? "0" + DateTime
                                                          .parse(snapshot.data
                                                      !.docs[index]['time']
                                                          .toString())
                                                          .add(DateTime
                                                          .now()
                                                          .timeZoneOffset)
                                                          .minute
                                                          .toString()
                                                          : DateTime
                                                          .parse(snapshot.data
                                                      !.docs[index]['time']
                                                          .toString())
                                                          .add(DateTime
                                                          .now()
                                                          .timeZoneOffset)
                                                          .minute
                                                          .toString()),
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10
                                                  ),
                                                ),
                                              )

                                            ],
                                          ),
                                        ],
                                      ),

                                      Row(
                                        mainAxisAlignment: snapshot.data
                                        !.docs[index]['uid'] ==
                                            myUid
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width - 120),
                                            decoration: BoxDecoration(
                                              borderRadius: k >=
                                                  snapshot.data!.docs.length
                                                  ? BorderRadius.circular(10)
                                                  : BorderRadius.only(
                                                topRight: snapshot.data
                                                !.docs[index]['uid'] == myUid
                                                    ? lastMessageUid ==
                                                    snapshot.data
                                                    !.docs[k]['uid'] &&
                                                    (DateTime
                                                        .parse(snapshot.data
                                                    !.docs[index]['time']
                                                        .toString())
                                                        .toLocal()
                                                        .minute - DateTime
                                                        .parse(snapshot.data
                                                    !.docs[index]['time']
                                                        .toString())
                                                        .toLocal()
                                                        .minute) == 0
                                                    ? Radius.circular(5)
                                                    : Radius.circular(0)
                                                    : Radius.circular(15),
                                                bottomRight: snapshot.data
                                                !.docs[index]['uid'] == myUid
                                                    ? Radius.circular(5)
                                                    : Radius.circular(10),
                                                bottomLeft: snapshot.data
                                                !.docs[index]['uid'] == myUid
                                                    ? Radius.circular(10)
                                                    : Radius.circular(5),
                                                topLeft: snapshot.data
                                                !.docs[index]['uid'] != myUid
                                                    ? lastMessageUid ==
                                                    snapshot.data
                                                    !.docs[k]['uid'] &&
                                                    (DateTime
                                                        .parse(snapshot.data
                                                    !.docs[index]['time']
                                                        .toString())
                                                        .toLocal()
                                                        .minute - DateTime
                                                        .parse(snapshot.data
                                                    !.docs[index]['time']
                                                        .toString())
                                                        .toLocal()
                                                        .minute) == 0
                                                    ? Radius.circular(5)
                                                    : Radius.circular(0)
                                                    : Radius.circular(15),
                                              ),
                                              color: snapshot.data
                                              !.docs[index]['uid'] == myUid
                                                  ? Theme
                                                  .of(context)
                                                  .primaryColor
                                                  .withOpacity(0.8)
                                                  : Colors.grey.shade200,
                                              gradient: snapshot.data
                                              !.docs[index]['uid'] == myUid
                                                  ? LinearGradient(
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.lightBlueAccent
                                                  ],
                                                  stops: [0.3, 1],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight
                                              )
                                                  : null,
                                            ),
                                            padding: snapshot.data
                                            !.docs[index]['type'] == "text"
                                                ? EdgeInsets.all(10)
                                                : EdgeInsets.all(4),
                                            child: InkWell(
                                              onLongPress: () {
                                                print("Long Pressed : ${snapshot
                                                    .data!.docs[index].id}");
                                                if (snapshot.data
                                                !.docs[index]['type'] !=
                                                    "task" && snapshot.data
                                                !.docs[index]['uid'] ==
                                                    myUid) {
                                                  unsendDialog(snapshot, index);
                                                }
                                              },
                                              child:

                                              typeToWidget(
                                                message: snapshot.data
                                                !.docs[index]['msg'],
                                                type: snapshot.data
                                                !.docs[index]['type'],
                                                uid: snapshot.data
                                                !.docs[index]['uid'],
                                              ),

                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                              else {
                                return LinearProgressIndicator();
                              }
                            },
                          ),
                        );
                      } else
                      if (snapshot.hasData && snapshot.data!.docs.length == 0) {
                        print("its first message");
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() {
                            isFirstMessage = true;
                          });
                        });
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image.asset(
                            //     "assets/say_hi.png",
                            //   height: 200,
                            // ),
                            Text("No Conversations",
                              style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 25
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text("You didn't made any conversation yet",
                              style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.grey.shade500
                              ),
                            ),
                            SizedBox(height: 25,),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.shade100
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Say Hi",
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Theme
                                          .of(context)
                                          .primaryColor
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }
                ),
              ),

              isSeenStatusExist ? Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("seen ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          fontSize: 10
                      ),
                    ),
                    Container(
                        height: 15,
                        width: 15,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Text('')
                        )
                    )
                  ],
                ),
              ) : Container(),

              isFileUploading ? Container(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        child: Image.memory(
                          fileThumbnail!,
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sending File", style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700),),
                            SizedBox(height: 5,),
                            LinearProgressIndicator(
                              minHeight: 2,
                              value: uploadingProgress,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      Icon(Icons.cancel, color: Colors.grey.shade700,),
                      //Expanded(child: LinearProgressIndicator()),
                    ],
                  ),
                ),
              ) : Container(),

              statusToWidget(requestStatus),

            ],
          ),
        ),
      ),
    );
  }

  scrollToBottom() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _lvScrollCtrl.animateTo(0.0,
          duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    });
  }

  void sendMessage(int type) async {
    print("method 3 continue");
    String msg = message;
    setState(() {
      message = "";
      showButton = false;
      isSeenStatusExist = false;
    });


    textEditingController = TextEditingController(text: "");
    await FirebaseFirestore.instance.collection("Chats")
        .doc(channelId).collection("All Chat")
        .add({
      "msg": msg,
      "time": DateTime.now().toString(),
      "uid": myUid,
      "type": type,
    }).then((value) {
      print("Message sent");
    });

    if (isFirstMessage) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(myUid!)
          .child("chatlist")
          .child(widget.uid!);

      await dbRef.set({
        "time": DateTime.now().toString(),
        "last_msg": msg,
        "type": type,
        "messageCount": 0,
        "status": 1,
        "channelId": channelId
      });

      DatabaseReference dbRef2 = FirebaseDatabase.instance.ref(widget.uid!)
          .child("chatlist")
          .child(myUid!);


      await dbRef2.once().then((value) {
        final snapshot = value.snapshot.value as Map;
        dbRef2.set({
          // "time": DateTime.now().subtract(timeDifference!).toString(),
          "time": DateTime.now().toString(),
          "last_msg": msg,
          "type": type,
          "messageCount": snapshot.isEmpty ? 1 : snapshot['messageCount'] == null ? 1 : snapshot['messageCount'] +
              1,
          "status": 0,
          "channelId": channelId
        });
      });
      setState(() {
        isFirstMessage = false;
      });
    }
    else {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(myUid!)
          .child("chatlist")
          .child(widget.uid!);

      await dbRef.update({
        "time": DateTime.now().toString(),
        "last_msg": msg,
        "type": type,
        "messageCount": 0,
        "channelId": channelId
      });


      DatabaseReference dbRef2 = FirebaseDatabase.instance.ref(widget.uid!)
          .child("chatlist")
          .child(myUid!);

      await dbRef2.once().then((data) {
        print(widget.uid);
        print(myUid);
        // print("1500${data.value}");
        print("method 3");

        final call = data.snapshot.value as Map;

        dbRef2.update({
          "time": DateTime.now().toString(),
          "last_msg": msg,
          "type": type,
          "messageCount": call.isEmpty ? 1 : call['messageCount'] == null
              ? 1
              : call['messageCount'] +
              1,
          "channelId": channelId
        });
      });
    }

    if (messageCount >= 0) {
      setState(() {
        globalMessage = globalMessage.isEmpty ? msg : globalMessage + "`" + msg;
      });
    }

    for (int i = 0; i < tokensList.length; i++) {
      sendNotification(senderName, msg, tokensList[i]);
    }
  }

  void sendTask(int type, String taskId) async {
    String msg = message;

    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection("Chats")
        .doc(channelId).collection("All Chat");
    await collectionReference.doc(taskId).set({
      "msg": msg,
      "time": DateTime.now().toString(),
      "uid": myUid,
      "type": type,
    });
  }

  void deleteTask(String taskId) async {
    await FirebaseFirestore.instance.collection("Chats").doc(channelId)
        .collection("All Chat").doc(taskId).delete();
  }

  void updateTaskToFile(int type, String taskId) async {
    //print(lastMessageUid);
    String msg = message;
    setState(() {
      message = "";
      showButton = false;
      //scrollToBottom();
      isSeenStatusExist = false;
    });


    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection("Chats")
        .doc(channelId).collection("All Chat");
    await collectionReference.doc(taskId).set({
      "msg": msg,
      "time": DateTime.now().toString(),
      "uid": myUid,
      "type": type,
    });

    if (isFirstMessage) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(myUid!)
          .child("chatlist")
          .child(widget.uid!);

      await dbRef.set({
        "time": DateTime.now().toString(),
        "last_msg": msg,
        "type": type,
        "messageCount": 0,
        "status": 1,
        "channelId": channelId
      });

      DatabaseReference dbRef2 = FirebaseDatabase.instance.ref(widget.uid!)
          .child("chatlist")
          .child(myUid!);

      await dbRef2.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot.value as Map;
        print("method 7");

        dbRef2.set({
          "time": DateTime.now().toString(),
          "last_msg": msg,
          "type": type,
          "messageCount": snapshot.isEmpty ? 1 : snapshot['messageCount'] + 1,
          "status": 0,
          "channelId": channelId
        });
      });
      setState(() {
        isFirstMessage = false;
      });
    }
    else {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref(myUid!)
          .child("chatlist")
          .child(widget.uid!);

      await dbRef.update({
        // "time": DateTime.now().subtract(timeDifference!).toString(),
        "time": DateTime.now().toString(),
        "last_msg": msg,
        "type": type,
        "messageCount": 0,
        "channelId": channelId
      });

      DatabaseReference dbRef2 = FirebaseDatabase.instance.ref(widget.uid!)
          .child("chatlist")
          .child(myUid!);


      await dbRef2.onValue.listen((DatabaseEvent event) {
        final snapshot = event.snapshot.value as Map;
        print("method 4");

        dbRef2.update({
          "time": DateTime.now().toString(),
          "last_msg": msg,
          "type": type,
          "messageCount": snapshot.isEmpty ? 1 : snapshot['messageCount'] + 1,
          "channelId": channelId
        });
      });
    }

    for (int i = 0; i < tokensList.length; i++) {
      sendNotification(senderName, msg, tokensList[i]);
    }
  }


  void markAsSeen() async {
    String x = "${widget.uid}";
    seenRef = FirebaseDatabase.instance.ref(myUid!)
        .child('chatlist').child(x);
    FirebaseDatabase.instance.ref(myUid!)
        .child('chatlist').child("x").set({
      "messageCount": 0,
    });
    // seenRefListner = seenRef!.once().then((value){
    //   seenRef!.update({
    //     "messageCount": 0,
    //   });
    // });
    seenRefListner = seenRef!.onValue.listen((event) {
      seenRef!.update({
        "messageCount": 0,
      });
    });
  }

  void getCurrentTime() {
    // DatabaseReference starCountRef =
    // FirebaseDatabase.instance.ref("currenttime").child('time');
    // starCountRef.onValue.listen((DatabaseEvent event) {
    //   final data = event.snapshot.value;
    // });
    ds = FirebaseDatabase.instance
        .ref("currenttime")
        .child('time')
        .onValue
        .listen((event) {
      if (mounted) {
        // print("currentTime============> ${currentTime}");

        setState(() {
          currentTime = DateTime.parse(event.snapshot.value.toString());
          // print(currentTime.toString());
          // print("Now : " + DateTime.now().toString());
          timeDifference = DateTime.now().difference(
              DateTime.parse(event.snapshot.value.toString()));
          // print("Difference : " + DateTime.now().difference(
          //     DateTime.parse(event.snapshot.value.toString())).toString());
          // print("Subtract : " +
          //     DateTime.now().subtract(timeDifference!).toString());
          getUserPreference();
        });
        //Timer(Duration(seconds: 60 - DateTime.parse(event.snapshot.value.toString()).second, callback)
      }
    });
  }

  checkSeenStatus() async {
    debugPrint('widget.uid ${widget.uid} myUid ${myUid}');
    checkSeenRefListner = FirebaseDatabase.instance
        .ref(widget.uid!)
        .child('chatlist')
        .child(myUid!)
        .child("messageCount")
        .onValue
        .listen((event) {
      final snapshot = event.snapshot.value as int;
      if (event.snapshot.value == 0) {
        setState(() {
          messageCount = snapshot;
          pendingMessagesList.clear();
          isSeenStatusExist = true;
          globalMessage = "";
        });
      } else {
        // print("messageCount=========== > ${messageCount}");
        // print("messageCount=========== > ${event.snapshot.value}");

        setState(() {
          messageCount = snapshot;
          isSeenStatusExist = false;
        });
      }
    });
  }

  void pickFile() async {
    FilePickerResult? f = await FilePicker.platform.pickFiles(
      allowCompression: true,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4'],
    );
    setState(() {
      file = f;
      print(f!.files[0].path);
      print("herreee ${file!.files[0].path}");
    });
    if (file!.files[0].path!.contains(".jpg") ||
        file!.files[0].path!.contains(".png") ||
        file!.files[0].path!.contains(".jpeg")) {
      uploadFileToServer(
          File(file!.files[0].path!).readAsBytesSync(), "jpg", "file",
          file!.files[0].path!);
    }
    if (Platform.isIOS) {
      if (file!.files[0].path!.contains(".MP4")) {
        print("now here${file!.files[0].path!}");
        // Navigator.push(context, MaterialPageRoute(builder: (context) =>
        //     MyVideoPlayer(
        //       type:1,
        //         url: file!.files[0].path!)));
        uploadFileToServer(
            File(file!.files[0].path!).readAsBytesSync(), "mp4", "file",
            file!.files[0].path!);
      }
    } else {
      if (file!.files[0].path!.contains(".mp4")) {
        print("now here${file!.files[0].path!}");
        // Navigator.push(context, MaterialPageRoute(builder: (context) =>
        //     MyVideoPlayer(
        //       type:1,
        //         url: file!.files[0].path!)));
        uploadFileToServer1(
            File(file!.files[0].path!).readAsBytesSync(), "mp4", "file",
            file!.files[0].path!);
      }
    }
  }

  Future<Uint8List> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 15,
    );
    print(file.lengthSync());
    print(result!.length);
    return result;
  }

  myDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Processing..."),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                Text("Please wait while processing video"),
              ],
            ),
          );
        }
    );
  }

  /// New
  uploadFileToServer1(Uint8List result, String extension, String type,
      path) async {
    await getExternalStorageDirectory().then((value) async {
      print(value);

      final uploader = FlutterUploader();

      File f2 = await File(value!.path + '/0.$extension').create();
      f2.writeAsBytesSync(result);

      List<FileItem> fItem = [
        // FileItem(field: "file", path: value.path),

        FileItem(path: path),
        // FileItem(savedDir: savedDir, filename: filename)

      ];

      final tag = "image upload ${Random().nextInt(9999)}";


      print('image path is $path');

      var taskId = await uploader.enqueue(
          MultipartFormDataUpload(
            url: "$SERVER_ADDRESS/api/mediaupload",
            files: fItem,
            method: UploadMethod.POST,
            tag: tag,
          )

      );

      setState(() {
        message = value.toString();
        sendTask(3, taskId);
      });

      //Toast.show("$taskId", context, duration: 5);

      _progressSubscription.putIfAbsent("$taskId", () {
        return uploader.progress.listen((progress) {
          final task = _tasks[progress.status];

          if (task == null) return;
          if (task.isCompleted()) return;
        });
      });

      print("_progressSubscription : " + _progressSubscription.toString());

      _resultSubscription.putIfAbsent("$taskId", () {
        return uploader.result.listen((result) {
          print('restfull t $result');
          print('resullllll t $result');
          if (taskId.toString() == result.taskId) {
            print('Update result if $result');
            uploadDataWithBackgroundService(result.taskId, result);
          }
          // uploadDataWithBackgroundService(result.taskId, result);

          final task = _tasks[result];
          if (task == null) return;
        }, onError: (ex, stacktrace) {
          print("exception: $ex");
          print("stacktrace: $stacktrace");
          final exp = ex;
          final task = _tasks[exp.tag];
          if (task == null) return;
        });
      });

      setState(() {
        _tasks.putIfAbsent(
            tag,
                () =>
                UploadItem(
                  id: taskId,
                  tag: tag,
                  type: MediaType.Video,
                  status: UploadTaskStatus.enqueued,
                ));
      });
    });
  }

  uploadFileToServer(Uint8List result, String extension, String type,
      path) async {
    final uploader = FlutterUploader();

    // File f2 = await File(path).create();
    // f2.writeAsBytesSync(result);

    List<FileItem> fItem = [
      // FileItem(field: "file", path: value.path),

      FileItem(path: path),
      // FileItem(savedDir: savedDir, filename: filename)

    ];

    final tag = "image upload ${Random().nextInt(9999)}";


    print('image path is $path');

    var taskId = await uploader.enqueue(
        MultipartFormDataUpload(
          url: "$SERVER_ADDRESS/api/mediaupload",
          files: fItem,
          method: UploadMethod.POST,
          tag: tag,
        )

    );

    setState(() {
      message = path;
      sendTask(3, taskId);
    });

    //Toast.show("$taskId", context, duration: 5);

    _progressSubscription.putIfAbsent("$taskId", () {
      return uploader.progress.listen((progress) {
        final task = _tasks[progress.status];

        if (task == null) return;
        if (task.isCompleted()) return;
      });
    });

    print("_progressSubscription : " + _progressSubscription.toString());

    _resultSubscription.putIfAbsent("$taskId", () {
      return uploader.result.listen((result) {
        print('restfull t $result');
        print('resullllll t $result');
        if (taskId.toString() == result.taskId) {
          print('Update result if $result');
          uploadDataWithBackgroundService(result.taskId, result);
        }
        // uploadDataWithBackgroundService(result.taskId, result);

        final task = _tasks[result];
        if (task == null) return;
      }, onError: (ex, stacktrace) {
        print("exception: $ex");
        print("stacktrace: $stacktrace");
        final exp = ex;
        final task = _tasks[exp.tag];
        if (task == null) return;
      });
    });

    setState(() {
      _tasks.putIfAbsent(
          tag,
              () =>
              UploadItem(
                id: taskId,
                tag: tag,
                type: MediaType.Video,
                status: UploadTaskStatus.enqueued,
              ));
    });
  }


  /// New typeToWidget
  Widget typeToWidget({String? message, int? type, String? uid}) {
    // print('type in type to widget $type');
    // print('message is : $message');
    if (type == 2 || type == 1) {
      // String ext = message.split('.').last;
      String ext = message!.split('.').last;
      // print('msg type $ext');
      return
        (ext == 'mp4' || ext == 'MP4') ? InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                MyVideoPlayer(
                    type: 2,
                    url: SERVER_ADDRESS + "/public/upload/chat/" + message)));
            // Get.to(()=> MyVideoPlayer(SERVER_ADDRESS + "/public/upload/chat/" + message));
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MyVideoThumbNail(
                    SERVER_ADDRESS + "/public/upload/chat/" + message),),
              Container(
                decoration: BoxDecoration(
                  color: BLACK
                      .withOpacity(0.7),
                  borderRadius:
                  BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: WHITE,
                ),
              )
            ],
          ),
          // child:

          // FutureBuilder(
          //     future: generateImage(
          //         SERVER_ADDRESS + "/public/upload/chat/" + message),
          //     builder: (context, snapshot) {
          //       if (snapshot.hasData) {
          //         return Stack(
          //           alignment: Alignment.center,
          //           children: [
          //             ClipRRect(
          //               borderRadius: BorderRadius.circular(10),
          //               child: Image.file(
          //                 File(snapshot.data.toString()),
          //                 fit: BoxFit.cover,
          //                 height: 300,
          //               ),
          //             ),
          //             Container(
          //               decoration: BoxDecoration(
          //                 color: BLACK
          //                     .withOpacity(0.7),
          //                 borderRadius:
          //                 BorderRadius.circular(5),
          //               ),
          //               child: Icon(
          //                 Icons.play_arrow,
          //                 color: WHITE,
          //               ),
          //             )
          //           ],
          //         );
          //       }
          //       return Container(
          //           height: 200,
          //           width: 200,
          //           alignment: Alignment.center,
          //           child: const CircularProgressIndicator());
          //     })
        )
            :
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                MyPhotoViewer(
                    url: SERVER_ADDRESS + "/public/upload/chat/" + message)));
          },
          child: Hero(
            tag: SERVER_ADDRESS + "/public/upload/chat/" + message,
            child: ClipRRect(
              child:
              CachedNetworkImage(
                imageUrl: SERVER_ADDRESS + "/public/upload/chat/" +
                    message,
                placeholder: (context, url) =>
                    Container(
                        child: Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Icon(Icons.error),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
    }
    else if (type == 3 && uid == myUid) {
      final uploader = FlutterUploader();
      return InkWell(
        onLongPress: () {

        },
        child: Container(
          height: 200,
          child: Stack(
            children: [
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(WHITE),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: //u == null
                //     ? Text("Upload Failed", style: TextStyle(color: Colors.white),)
                Text('Uploading File', style: TextStyle(color: WHITE),),
              ),
              Center(
                child: InkWell(
                    onTap: () {
                      // deleteTask(taskId);
                      // uploader.cancel(taskId: taskId);
                    },
                    child: Icon(Icons.upload_rounded, color: WHITE,)),
              ),
            ],
          ),
        ),
      );
    }
    else if (type == 0) {
      return InkWell(
        onTap: () async {
          if (isURL(message!)) {
            if (await canLaunch(message)) {
              await launch(message);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            message!,
            style: GoogleFonts.ubuntu(
                fontSize: isURL(message) ? 18 : 15,
                color: uid == myUid
                    ? Colors.white
                    : Colors.black,
                fontWeight: isURL(message) ? FontWeight.w300 : FontWeight.w400,
                decoration: isURL(message)
                    ? TextDecoration.underline
                    : TextDecoration.none
            ),
          ),
        ),
      );
    }
    else if (type == 3 && uid != myUid) {
      return Text("Uploading file...", style: TextStyle(fontSize: 10),);
    }
    // else if (type == 2) {
    //   return
    //       Container(
    //         height: 200,
    //         width: 200,
    //         child: FutureBuilder(
    //             future: generateImage(SERVER_ADDRESS + "/public/upload/chat/" +message),
    //             builder: (context, snapshot) {
    //               print('snapshot thumbain connection status');
    //               print(snapshot.connectionState);
    //               print(snapshot.hasData);
    //               // if (snapshot.hasData) {
    //               if (snapshot.connectionState == 'ConnectionState.done') {
    //                 return Stack(
    //                   alignment: Alignment.center,
    //                   children: [
    //                     Image.file(
    //                       File(snapshot.data.toString()),
    //                       fit: BoxFit.cover,
    //                       height: 90,
    //                     ),
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         color: Colors.black
    //                             .withOpacity(0.7),
    //                         borderRadius:
    //                         BorderRadius.circular(5),
    //                       ),
    //                       child: const Icon(
    //                         Icons.play_arrow,
    //                         color: Colors.grey,
    //                       ),
    //                     )
    //                   ],
    //                 );
    //               }
    //               return const CircularProgressIndicator();
    //             })
    //       );
    //     // Text("Videp file... $message ", style: TextStyle(fontSize: 10),);
    // }
    else {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () async {
            // if(Uri.parse(message.toString()).isAbsolute){
            //   if (await canLaunch(message))
            //     await launch(message);
            // }
          },
          child: Text(
            message!,
            style: GoogleFonts.ubuntu(
                fontSize: isURL(message) ? 18 : 15,
                color: uid == myUid
                    ? Colors.white
                    : Colors.black,
                fontWeight: isURL(message) ? FontWeight.w300 : FontWeight.w400,
                decoration: isURL(message)
                    ? TextDecoration.underline
                    : TextDecoration.none
            ),
          ),
        ),
      );
    }
  }

  Future<String> generateImage(path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      quality: 25,
    );
    return fileName.toString();
  }


  Widget statusToWidget(data) {
    if (data == 0) {
      return Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  //acceptChatRequest();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Reject",
                      style: TextStyle(
                          fontWeight: FontWeight.w900
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  acceptChatRequest();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor
                          .withOpacity(0.8)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Accept",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    else if (data == 1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: textField = TextField(
                minLines: 1,
                maxLines: 6,
                focusNode: myFocusNode,
                controller: textEditingController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintText: "Type a message here...",
                    filled: true,
                    hintStyle: TextStyle(
                        fontSize: 15
                    ),
                    prefixIcon: IconButton(
                      icon:
                      // Icon(Icons.emoji_emotions_outlined),
                      isEmojiKeybord ?
                      Icon(Icons.keyboard)
                          : Icon(Icons.emoji_emotions_outlined),
                      onPressed: () async {
                        print('emoji keybord is $isEmojiKeybord');
                        print('smiple keybord is $isKeybord');
                        if (isEmojiKeybord) {
                          myFocusNode.requestFocus();
                          // await Future.delayed(Duration(milliseconds:100));
                          setState(() {
                            isEmojiKeybord = !isEmojiKeybord;
                          });
                        } else {
                          myFocusNode.unfocus();
                          await SystemChannels.textInput.invokeMethod(
                              'TextInput.hide');
                          await Future.delayed(Duration(milliseconds: 100));

                          // FocusScopeNode currentFocus = FocusScope.of(context);
                          // if (!currentFocus.hasPrimaryFocus) {
                          //   currentFocus.unfocus();
                          //   currentFocus.requestFocus();
                          // }
                          setState(() {
                            isEmojiKeybord = !isEmojiKeybord;
                          });
                        }


                        // FocusScopeNode currentFocus = FocusScope.of(context);
                        //
                        // if (!currentFocus.hasPrimaryFocus) {
                        //   currentFocus.unfocus();
                        // }
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.file_present),
                      onPressed: () {
                        _showMyDialog();
                        // pickFile();
                      },
                    )
                ),
                onChanged: (val) {
                  markAsTyping();
                  setState(() {
                    message = val;
                    if (val.length == 0) {
                      showButton = false;
                    } else {
                      showButton = true;
                    }
                  });
                },
              ),
            ),
            SizedBox(width: 8,),
            showButton ? FloatingActionButton(
              shape: CircleBorder(
                  side: BorderSide(
                      width: 5,
                      color: Colors.white
                  )
              ),
              //color: Theme.of(context).primaryColor,
              onPressed: () {
                sendMessage(0);
              },
              elevation: 0.0,
              child: Transform.rotate(
                angle: 5.5,
                child: Icon(
                  Icons.send,
                ),
              ),
            ) : Container(),
          ],
        ),
      );
    }
    else {
      return Container();
    }
  }

  acceptChatRequest() async {
    await FirebaseDatabase.instance.ref(myUid!).child('chatlist')
        .child(widget.uid!).update({
      "status": 1,
    }).then((value) {
      setState(() {
        requestStatus = 1;
      });
    });
  }


  unsendDialog(AsyncSnapshot<QuerySnapshot> snapshot, index) {
    return showDialog(
        context: context,
        barrierColor: Colors.black87.withOpacity(0.7),
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text("Remove Message", style: TextStyle(
              color: Colors.black,
            ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //typeToUnsendDialogContent(snapshot.data.docs[index]['type'],snapshot.data.docs[index]['msg'].toString()),
                Text(
                  "Are you sure to remove this message ?",
                  style: TextStyle(fontSize: 13, color: Colors.red.shade800),),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          unsendMessage(snapshot.data!.docs[index].id, index,
                              snapshot.data!.docs.length, snapshot);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                          ),
                          child: Center(
                            child: Text(
                              "Remove",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }

  unsendMessage(String id, int index, int length,
      AsyncSnapshot<QuerySnapshot> snapshot) async {
    print("\n\n" + index.toString() + "  " + length.toString());
    if (index > 0) {
      await FirebaseFirestore.instance.collection("Chats").doc(channelId)
          .collection("All Chat")
          .doc(id).delete();
      Navigator.pop(context);
    }
    else if (length == 1) {
      await FirebaseFirestore.instance.collection("Chats").doc(channelId)
          .collection("All Chat")
          .doc(id).delete();
      await FirebaseDatabase.instance.ref(myUid!)
          .child("chatlist")
          .child(widget.uid!).remove();
      await FirebaseDatabase.instance.ref(widget.uid!)
          .child("chatlist")
          .child(myUid!).remove();
      Navigator.pop(context);
    } else {
      DatabaseReference documentReference = FirebaseDatabase.instance
          .ref(myUid!).child('chatlist')
          .child(widget.uid!);
      await documentReference.update({
        // "time": snapshot.data!.docs[1]['time'].toDate().toUtc().toString(),
        "time": snapshot.data!.docs[1]['time'].toString(),
        "last_msg": snapshot.data!.docs[1]['msg'],
        "type": snapshot.data!.docs[1]['type'],
      });

      DatabaseReference documentReference2 = FirebaseDatabase.instance
          .ref(widget.uid!).child('chatlist')
          .child(myUid!);
      await documentReference2.update({
        // "time": snapshot.data!.docs[1]['time'].toDate().toUtc().toString(),
        "time": snapshot.data!.docs[1]['time'].toString(),
        "last_msg": snapshot.data!.docs[1]['msg'],
        "type": snapshot.data!.docs[1]['type'],
      });
      Navigator.pop(context);

      await FirebaseFirestore.instance.collection("Chats").doc(channelId)
          .collection("All Chat")
          .doc(id).delete();
    }
  }

  typeToUnsendDialogContent(int type, String msg) {
    if (type == 1) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CachedNetworkImage(
            imageUrl: SERVER_ADDRESS + "/public/upload/chat/" + msg,
            fit: BoxFit.cover,
            placeholder: (context, s) =>
                Container(
                  child: Center(child: CircularProgressIndicator(),),),
            errorWidget: (context, s, y) =>
                Container(
                  child: Center(child: CircularProgressIndicator(),),),
          ),
        ),
      );
    }
    else if (type == 2) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                // MyVideoThumbNail(SERVER_ADDRESS + "/public/upload/chat/" + message),
                Container(
                  color: Colors.black38,
                ),
                Center(
                  child: Icon(
                    Icons.play_circle_fill, color: Colors.white, size: 70,),
                )
              ],
            ),
          ),
        ),
      );
    }
    else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade300,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            msg,
            style: TextStyle(fontSize: 15),),
        ),
      );
    }
  }


  Future<Map<String, dynamic>> sendNotification(String userName, String message,
      String token) async {
    await firebaseMessaging.requestPermission(
        sound: true, badge: true, alert: true, provisional: false);

    print('sent message to this token : $token');

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      // 'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'notification': <String, dynamic>{
            'android': <String, String>{
            },
            'title': userName,
            'body': message,
          },
          'data': <String, String>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'body': message,
            'title': userName,
            // 'channel' : channelId?.codeUnits[0].toString() + channelId.codeUnits[1].toString() + channelId.codeUnits.last.toString(),
            'channel': '${channelId?.codeUnits[0].toString()}${channelId
                ?.codeUnits[1].toString()}${channelId?.codeUnits.last
                .toString()}',
            'uid': myUid.toString(),
            'channelId': channelId!,
            'myName': myName,
            // 'ccId': oppConnectCubId.toString(),
            // 'ccId': myconnectCubId!,
            'myUserName': userName,
            // 'myid' : widget.uid!,
            'myid': myUid.toString(),
            'notificationType': 0.toString(),
            // 'oppUserId' :
          },
          'to': token,
        },
      ),
    ).then((value) {
      print("\n\nMessage sent : ${value.body}");
    });

    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();

    return completer.future;
  }


}

class UploadItem {
  final String? id;
  final String? tag;
  final MediaType? type;
  final int progress;
  final UploadTaskStatus status;

  UploadItem({
    this.id,
    this.tag,
    this.type,
    this.progress = 0,
    this.status = UploadTaskStatus.undefined,
  });

  UploadItem copyWith({UploadTaskStatus? status, int? progress}) =>
      UploadItem(
          id: this.id,
          tag: this.tag,
          type: this.type,
          status: status ?? this.status,
          progress: progress ?? this.progress);

  bool isCompleted() =>
      this.status == UploadTaskStatus.canceled ||
          this.status == UploadTaskStatus.complete ||
          this.status == UploadTaskStatus.failed;
}

enum MediaType { Image, Video }