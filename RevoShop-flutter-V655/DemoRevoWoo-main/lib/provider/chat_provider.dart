import 'package:flutter/cupertino.dart';
import 'package:nyoba/models/chat_detail_model.dart';
import 'package:nyoba/services/chat_api.dart';
import 'package:nyoba/utils/utility.dart';

class ChatProvider with ChangeNotifier {
  bool loadingSend = false;
  bool loadingDetailChat = false;
  bool checkUnread = false;
  int unreadMessage = 0;
  String lastMessage = "";
  List<ChatDetailModel>? listDetailChat;

  sendChat({String? message, String? type, int? postId, String? image}) async {
    var data;
    loadingSend = true;
    notifyListeners();
    try {
      await ChatAPI()
          .sendChat(message: message, type: type, postId: postId, image: image)
          .then((value) {
        data = value;
        loadingSend = false;
        notifyListeners();
      });
      return data;
    } catch (e) {
      print(e);
      loadingSend = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetailChat() async {
    loadingDetailChat = true;
    notifyListeners();

    try {
      await ChatAPI().fetchDetailChat().then((value) {
        listDetailChat = [];
        notifyListeners();
        if (value != null) {
          printLog("Detail chat : $value");
          for (var item in value) {
            listDetailChat!.add(ChatDetailModel.fromJson(item));
          }
        }
      });
      loadingDetailChat = false;
      notifyListeners();
    } catch (e) {
      print(e);
      loadingDetailChat = false;
      notifyListeners();
    }
  }

  Future<ChatImage> uploadImage({String? title, String? media}) async {
    ChatImage image = new ChatImage();
    try {
      await ChatAPI()
          .uploadImage(title: title, mediaAttachment: media)
          .then((data) {
        if (data != null) image = ChatImage.fromJson(data);
      });
      notifyListeners();
      return image;
    } catch (e) {
      printLog("error upload : $e");
      return image;
    }
  }

  Future<bool> checkUnreadMessage() async {
    try {
      await ChatAPI().checkUnreadMessage().then((value) {
        if (value.isNotEmpty) {
          checkUnread = true;
          unreadMessage = int.parse(value["unread"]);
          lastMessage = value["last_message"];
          notifyListeners();
          printLog("unreadMessage : $unreadMessage");
        } else {
          checkUnread = false;
          unreadMessage = 0;
          notifyListeners();
        }
      });
      return checkUnread;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
