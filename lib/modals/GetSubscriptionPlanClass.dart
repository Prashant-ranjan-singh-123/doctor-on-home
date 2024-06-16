// To parse this JSON data, do
//
//     final getSubscriptionPlanClass = getSubscriptionPlanClassFromJson(jsonString);

import 'dart:convert';

GetSubscriptionPlanClass getSubscriptionPlanClassFromJson(String str) => GetSubscriptionPlanClass.fromJson(json.decode(str));

String getSubscriptionPlanClassToJson(GetSubscriptionPlanClass data) => json.encode(data.toJson());

class GetSubscriptionPlanClass {
  GetSubscriptionPlanClass({
    this.status,
    this.msg,
    this.data,
  });

  int? status;
  String? msg;
  Data? data;

  factory GetSubscriptionPlanClass.fromJson(Map<String, dynamic> json) => GetSubscriptionPlanClass(
    status: json["status"],
    msg: json["msg"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "msg": msg,
    "data": data!.toJson(),
  };
}

class Data {
  Data({
    this.data,
    this.currency,
  });

  List<Datum>? data;
  String? currency;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "currency": currency,
  };
}

class Datum {
  Datum({
    this.id,
    this.month,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  int? month;
  int? price;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    month: json["month"],
    price: json["price"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "month": month,
    "price": price,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
