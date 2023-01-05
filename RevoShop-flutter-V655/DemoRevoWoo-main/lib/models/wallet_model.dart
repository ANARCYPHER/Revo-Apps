class WalletModel {
  String? id, detail, amount, type, date;

  WalletModel({this.id, this.detail, this.amount, this.type, this.date});

  Map toJson() => {
    'transaction_id' : id,
    'details': detail,
    'amount': amount,
    'type': type,
    'date': date
  };

  WalletModel.fromJson(Map json){
    id = json['transaction_id'];
    detail = json['details'];
    amount = json['amount'];
    type = json['type'];
    date = json['date'];
  }
}