// To parse this JSON data, do
//
//     final banner = bannerFromJson(jsonString);

import 'dart:convert';

Banners bannerFromJson(String str) => Banners.fromJson(json.decode(str));

String bannerToJson(Banners data) => json.encode(data.toJson());

class Banners {
  Banners({
    required this.status,
    required this.msg,
    required this.data,
  });

  int status;
  String msg;
  List<BannerList> data;

  factory Banners.fromJson(Map<String, dynamic> json) => Banners(
    status: json["status"],
    msg: json["msg"],
    data: List<BannerList>.from(json["data"].map((x) => BannerList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "msg": msg,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class BannerList {
  BannerList({
    required this.id,
    required this.image,
  });

  int id;
  String image;

  factory BannerList.fromJson(Map<String, dynamic> json) => BannerList(
    id: json["id"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
  };
}
