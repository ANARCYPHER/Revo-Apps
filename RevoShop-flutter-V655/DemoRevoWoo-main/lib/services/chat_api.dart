import 'dart:convert';

import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class ChatAPI {
  fetchDetailChat() async {
    Map data = {'cookie': Session.data.getString('cookie')};
    var response = await baseAPI.postAsync('$detailChat', data, isCustom: true);
    return response;
  }

  sendChat({String? message, String? type, int? postId, String? image}) async {
    Map data = {
      'cookie': Session.data.getString('cookie'),
      'message': message,
      'type': type,
      'post_id': postId,
      'image': image
    };
    printLog("Data Send Chat : ${json.encode(data)}");
    var response = await baseAPI.postAsync('$insertChat', data, isCustom: true);
    printLog("Response send chat : $response");
    return response;
  }

  checkUnreadMessage() async {
    Map data = {
      'cookie': Session.data.getString('cookie'),
      'incoming_chat': true
    };
    var response =
        await baseAPI.postAsync('$listUserChat', data, isCustom: true);
    return response;
  }

  uploadImage({String? title, String? mediaAttachment}) async {
    Map data = {'title': title, 'media_attachment': mediaAttachment};
    var response = await baseAPI.postAsync('$inputImage', data, isCustom: true);
    printLog("Response image : $response");
    return response;
  }
}
