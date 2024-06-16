import 'package:flutter_background/flutter_background.dart';
import 'package:universal_io/io.dart';

Future<bool> initForegroundService() async {

  if (Platform.isAndroid) {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Doctor Finder',
      notificationText: 'Screen sharing in in progress',
      notificationImportance: AndroidNotificationImportance.Default,
      // notificationIcon:
      //     AndroidResource(name: 'launcher_icon.png', defType: 'drawable'),
      notificationIcon:
          AndroidResource(name: 'launcher_icon', defType: 'mipmap'),
    );
    return FlutterBackground.initialize(androidConfig: androidConfig);
  } else {
    return Future.value(true);
  }

}

Future<bool> startBackgroundExecution() async {
  if (Platform.isAndroid) {
    return initForegroundService().then((_) {
      return FlutterBackground.enableBackgroundExecution();
    });
  } else {
    return Future.value(true);
  }
}

Future<bool> stopBackgroundExecution() async {
  if (Platform.isAndroid && FlutterBackground.isBackgroundExecutionEnabled) {
    return FlutterBackground.disableBackgroundExecution();
  } else {
    return Future.value(true);
  }
}

Future<bool> hasBackgroundExecutionPermissions() async {
  if (Platform.isAndroid) {
    return FlutterBackground.hasPermissions;
  } else {
    return Future.value(true);
  }
}
