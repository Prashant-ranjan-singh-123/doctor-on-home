class DoctorProfileWithRating {
  String? success;
  String? register;
  Data? data;

  DoctorProfileWithRating({this.success, this.register, this.data});

  DoctorProfileWithRating.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['register'] = this.register;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? image;
  String? address;
  String? departmentName;
  int? avgratting;
  dynamic isSubscription;

  Data(
      {this.id,
        this.name,
        this.image,
        this.address,
        this.departmentName,
        this.isSubscription,
        this.avgratting});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'].toString();
    address = json['address'];
    departmentName = json['department_name'];
    avgratting = json['avgratting'];
    isSubscription = json['is_subscription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['address'] = this.address;
    data['department_name'] = this.departmentName;
    data['avgratting'] = this.avgratting;
    data['is_subscription'] = this.isSubscription;
    return data;
  }
}
