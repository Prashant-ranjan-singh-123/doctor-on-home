import 'package:appcode3/notificationHelper.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';

import '../views/incoming_call_image_name.dart';
import 'managers/call_manager.dart';

class IncomingCallScreen extends StatelessWidget {
  static const String TAG = "IncomingCallScreen";
  final P2PSession _callSession;

  IncomingManageController incomingScreenManager = Get.find();

  IncomingCallScreen(this._callSession);

  NotificationHelper notificationHelper = NotificationHelper();



  @override
  Widget build(BuildContext context) {
    FlutterRingtonePlayer.playRingtone(
      looping: true, // Android only - API >= 28
      volume: 0.1, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
    _callSession.onSessionClosed = (callSession) {
      log("_onSessionClosed", TAG);
      incomingScreenManager.removeValue();
      incomingScreenManager.removecallingImageValue();
      FlutterRingtonePlayer.stop();
      // Get.back();
      Navigator.pop(context);
    };

    // _callSession.

    print('session build ${_callSession}');
    // print('session build ${_callSession.cubeSdp.userInfo}');

    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            body: GetBuilder<IncomingManageController>(builder: (value) {
          return Container(
            decoration: BoxDecoration(
                image: (value.image == 'Default')
                    ? null
                    : DecorationImage(
                        image: NetworkImage(value.image), fit: BoxFit.cover)),
            child: Container(
              color: value.image == 'Default'
                  ? null
                  : Colors.black.withOpacity(0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(36),
                      child: Text(_getCallTitle(),
                          style: TextStyle(
                              fontSize: 20,
                              color: value.image == 'Default'
                                  ? Colors.black
                                  : Colors.white)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 36, bottom: 8),
                      child: Text(value.name,
                          style: TextStyle(
                              fontSize: 28,
                              color: value.image == 'Default'
                                  ? Colors.black
                                  : Colors.white)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 36, bottom: 8),
                      child: Text("Members:",
                          style: TextStyle(
                              fontSize: 20,
                              color: value.image == 'Default'
                                  ? Colors.black
                                  : Colors.white)),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(bottom: 86),
                    //   child: Text(_callSession.opponentsIds.join(", "),
                    //       style: TextStyle(fontSize: 18)),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.only(bottom: 86),
                    //   child: Text(_callSession.userInfo.keys.first,
                    //       style: TextStyle(fontSize: 18)),
                    // ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 86),
                      child: Text(_callSession.callerId.toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: value.image == 'Default'
                                  ? Colors.black
                                  : Colors.white)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 36),
                          child: FloatingActionButton(
                              heroTag: "RejectCall",
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.red,
                              onPressed: () {
                                print("on press red button");
                                notificationHelper.checkNotificationStatus("124");
                                _rejectCall(context, _callSession);
                              }),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: FloatingActionButton(
                            heroTag: "AcceptCall",
                            child: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.green,
                            onPressed: () {
                              print("on press green button");
                              notificationHelper.checkNotificationStatus("124");
                              _acceptCall(context, _callSession);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        })));
  }

  _getCallTitle() {
    var callType;

    switch (_callSession.callType) {
      case CallType.VIDEO_CALL:
        callType = "Video";
        break;
      case CallType.AUDIO_CALL:
        callType = "Audio";
        break;
    }

    return "Incoming $callType call";
  }

  void _acceptCall(BuildContext context, P2PSession callSession) {
    FlutterRingtonePlayer.stop();
    CallManager.instance.acceptCall(callSession.sessionId);
  }

  void _rejectCall(BuildContext context, P2PSession callSession) {
    FlutterRingtonePlayer.stop();
    CallManager.instance.reject(callSession.sessionId);
  }

  Future<bool> _onBackPressed(BuildContext context) {
    return Future.value(false);
  }
}
