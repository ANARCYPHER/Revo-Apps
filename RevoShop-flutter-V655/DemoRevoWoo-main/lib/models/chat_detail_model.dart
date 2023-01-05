class ChatDetailModel {
  String? date;
  List<ChatModel>? chatDetail;

  ChatDetailModel({this.date, this.chatDetail});

  Map toJson() => {'date': date, 'chat': chatDetail};

  ChatDetailModel.fromJson(Map json) {
    date = json["date"];
    if (json["chat"] != null) {
      chatDetail = [];
      json["chat"].forEach((v) {
        chatDetail!.add(new ChatModel.fromJson(v));
      });
    }
  }
}

class ChatModel {
  String? chatId;
  String? senderId;
  String? receiverId;
  String? message;
  String? type;
  String? image;
  String? postId;
  String? typeMessage;
  String? status;
  String? potition;
  String? createdAt;
  String? time;
  Subject? subject;

  ChatModel(
      {this.chatId,
      this.senderId,
      this.receiverId,
      this.message,
      this.createdAt,
      this.image,
      this.postId,
      this.potition,
      this.status,
      this.subject,
      this.time,
      this.type,
      this.typeMessage});

  Map toJson() => {
        'chat_id': chatId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
        'created_at': createdAt,
        'type': type,
        'image': image,
        'post_id': postId,
        'type_message': typeMessage,
        'status': status,
        'potition': potition,
        'time': time,
        'subject': subject
      };

  ChatModel.fromJson(Map json) {
    chatId = json['chat_id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    message = json['message'];
    type = json['type'];
    image = json['image'];
    postId = json['post_id'];
    typeMessage = json['type_message'];
    status = json['status'];
    potition = json['potition'];
    createdAt = json['created_at'];
    time = json['time'];
    subject =
        json['subject'] != null ? Subject.fromJson(json['subject']) : null;
  }
}

class Subject {
  int? id;
  String? name;
  String? status;
  String? price;
  String? imageFirst;

  Subject({this.id, this.name, this.status, this.price, this.imageFirst});

  Map toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'price': price,
        'image_first': imageFirst
      };

  Subject.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    price = json['price'].toString();
    imageFirst = json['image_first'];
  }
}

class ChatImage {
  int? id;
  String? image;

  ChatImage({this.id, this.image});
  Map toJson() => {'id': id, 'image': image};
  ChatImage.fromJson(Map json) {
    id = json['id'];
    image = json['image'];
  }
}
