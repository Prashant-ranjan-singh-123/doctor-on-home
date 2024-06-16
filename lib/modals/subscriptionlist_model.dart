// To parse this JSON data, do
//
//     final subscriptionListModel = subscriptionListModelFromJson(jsonString);

import 'dart:convert';

SubscriptionListModel subscriptionListModelFromJson(String str) => SubscriptionListModel.fromJson(json.decode(str));

String subscriptionListModelToJson(SubscriptionListModel data) => json.encode(data.toJson());

class SubscriptionListModel {
  SubscriptionListModel({
    this.status,
    this.register,
    this.success,
    this.data,
  });

  String? status;
  String? register;
  String? success;
  Data? data;

  factory SubscriptionListModel.fromJson(Map<String, dynamic> json) => SubscriptionListModel(
    status: json["status"],
    register: json["register"],
    success: json["success"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "register": register,
    "success": success,
    "data": data!.toJson(),
  };
}

class Data {
  Data({
    this.doctorsSubscription,
  });

  List<DoctorsSubscription>? doctorsSubscription;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    doctorsSubscription: List<DoctorsSubscription>.from(json["doctors_subscription"].map((x) => DoctorsSubscription.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "doctors_subscription": List<dynamic>.from(doctorsSubscription!.map((x) => x.toJson())),
  };
}

class DoctorsSubscription {
  DoctorsSubscription({
    this.status,
    this.month,
    this.price,
    this.date,
  });

  int? status;
  String? month;
  int? price;
  DateTime? date;

  factory DoctorsSubscription.fromJson(Map<String, dynamic> json) => DoctorsSubscription(
    status: json["status"],
    month: json["month"],
    price: json["price"],
    date: DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "month": month,
    "price": price,
    "date": date == null ? DateTime.now() : date!.toIso8601String(),
  };
}
