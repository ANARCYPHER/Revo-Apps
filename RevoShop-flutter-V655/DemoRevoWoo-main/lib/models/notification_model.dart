class NotificationModel {
  // int? userId, orderId;
  // String? status, createdAt, image;

  // Map<String, dynamic>? description;
  // String? type, title, payload;
  String? id, type, createdAt;
  int? userId, isRead;
  Map<String, dynamic>? description;

  NotificationModel({
    this.id,
    this.userId,
    this.isRead,
    // this.orderId,
    // this.status,
    this.createdAt,
    // this.image,
    this.type,
    // this.title,
    this.description,
    // this.payload
  });

  Map toJson() => {
        'id': id,
        'user_id': userId,
        'is_read': isRead,
        // 'order_id': orderId,
        // 'status': status,
        'created_at': createdAt,
        // 'image': image,
        'type': type,
        // 'title': title,
        'description': description,
        // 'payload': payload
      };

  NotificationModel.fromJson(Map json) {
    id = json['id'];
    userId = json['user_id'];
    isRead = json['is_read'];
    // orderId = json['order_id'];
    // status = json['status'];
    createdAt = json['created_at'];
    // image = json['image'];
    type = json['type'] ?? 'order';
    // title = json['title'];
    description = json['description'];
    // payload = json['payload'];
  }
}
