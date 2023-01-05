import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nyoba/models/notification_model.dart';
import 'package:nyoba/models/user_model.dart';
import 'package:nyoba/services/notification_api.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

String? selectedNotificationPayload;

class Session {
  static late SharedPreferences data;
  static late FirebaseMessaging messaging;

  static Future initLocalStorage() async {
    data = await SharedPreferences.getInstance();
  }

  static Future init() async {
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      printLog(value!, name: 'Device Token');
      data.setString('device_token', value);
    });

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      description:
          'This channel is used for important notifications.', // description
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (
              int id,
              String? title,
              String? body,
              String? payload,
            ) async {
              didReceiveLocalNotificationSubject.add(
                ReceivedNotification(
                  id: id,
                  title: title,
                  body: body,
                  payload: payload,
                ),
              );
            });

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectedNotificationPayload = payload;
      selectNotificationSubject.add(payload);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print("message recieved");
      debugPrint("Notif Body ${event.notification!.body}");
      debugPrint("Notif Title ${event.notification!.title}");
      debugPrint("Notif Data ${event.data}");

      RemoteNotification? notification = event.notification;
      AppleNotification? apple = event.notification?.apple;
      AndroidNotification? android = event.notification?.android;

      var _imageUrl = '';

      print(android);

      if (Platform.isAndroid && android != null) {
        if (android.imageUrl != null) {
          _imageUrl = android.imageUrl!;
        }
      } else if (Platform.isIOS && apple != null) {
        if (apple.imageUrl != null) {
          _imageUrl = apple.imageUrl!;
        }
      }

      if (notification != null) {
        // if (event.data.isNotEmpty && event.data["type"] == "all") {
        //   print("masuk notif cek - ${event.data["type"]}");
        //   savePushNotificationData(
        //       image: _imageUrl,
        //       description: notification.body,
        //       title: notification.title,
        //       payload: json.encode(event.data));
        // }

        if (_imageUrl.isNotEmpty) {
          String? _bigPicturePath = '';
          DateTime _dateNow = DateTime.now();
          if (Platform.isIOS) {
            _bigPicturePath = await _downloadAndSaveFile(
                _imageUrl, 'notificationimg$_dateNow.jpg');
          }
          final IOSNotificationDetails iOSPlatformChannelSpecifics =
              IOSNotificationDetails(attachments: <IOSNotificationAttachment>[
            IOSNotificationAttachment(_bigPicturePath)
          ]);
          await showBigPictureNotificationURL(_imageUrl).then((value) {
            flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                notification.title,
                notification.body,
                NotificationDetails(
                    android: AndroidNotificationDetails(
                      channel.id,
                      channel.name,
                      icon: 'transparent',
                      channelDescription: channel.description,
                      styleInformation: value,
                      fullScreenIntent: true,
                    ),
                    iOS: iOSPlatformChannelSpecifics),
                payload: json.encode(event.data));
          });
        } else {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  icon: 'transparent',
                  channelDescription: channel.description,
                ),
              ),
              payload: json.encode(event.data));
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('Init onMessageOpenedApp!');
      debugPrint('onMessageOpenedApp Click ' + message.data.toString());
    });
  }

  static Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  static Future<BigPictureStyleInformation> showBigPictureNotificationURL(
      String url) async {
    final ByteArrayAndroidBitmap largeIcon =
        ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));
    final ByteArrayAndroidBitmap bigPicture =
        ByteArrayAndroidBitmap(await _getByteArrayFromUrl(url));

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(bigPicture, largeIcon: largeIcon);

    return bigPictureStyleInformation;
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future saveUser(UserModel user, String cookie) async {
    data.setBool('isLogin', true);
    data.setInt("id", user.id!);
    data.setString("username", user.username!);
    data.setString("avatar", user.avatar ?? '');
    data.setString("firstname", user.firstname!);
    data.setString("lastname", user.lastname!);
    data.setString("displayname", user.displayName!);
    data.setString("nickname", user.nickname!);
    data.setString("nicename", user.niceName!);
    data.setString("description", user.description!);
    data.setString("email", user.email!);
    data.setString("cookie", cookie);
    data.setString("role", user.role!.isNotEmpty ? user.role!.first : "");
  }

  void removeUser() async {
    data.setBool('isLogin', false);
    data.remove("id");
    data.remove("username");
    data.remove("avatar");
    data.remove("firstname");
    data.remove("lastname");
    data.remove("displayname");
    data.remove("nickname");
    data.remove("nicename");
    data.remove("description");
    data.remove("email");
    data.remove("cookie");
    data.remove("role");
  }

  Future<String?> getToken(args) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token;
  }

  // static Future savePushNotificationData(
  //     {String? image, title, description, payload}) async {
  //   printLog('Creating Local Notif');
  //   printLog(
  //       "Image : $image, Title: $title, Desc: $description, Payload: $payload");
  //   List<NotificationModel> _notificationsLocal = [];

  //   NotificationModel? _notification = new NotificationModel(
  //       userId: data.getInt('id') ?? 0,
  //       createdAt: DateTime.now().toString(),
  //       image: image,
  //       description: description,
  //       title: title,
  //       type: 'promo',
  //       payload: payload);
  //   if (data.containsKey('local_notif')) {
  //     final List<dynamic> jsonData =
  //         jsonDecode(data.getString('local_notif') ?? '[]');
  //     _notificationsLocal = jsonData.map<NotificationModel>((jsonItem) {
  //       return NotificationModel.fromJson(jsonItem);
  //     }).toList();
  //   }
  //   _notificationsLocal.add(_notification);
  //   data.setString('local_notif', jsonEncode(_notificationsLocal));

  //   printLog(data.getString('local_notif')!, name: 'Local Notif');
  // }
}
