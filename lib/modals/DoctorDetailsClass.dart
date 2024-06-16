class DoctorDetailsClass {
  String? success;
  String? register;
  Data? data;

  DoctorDetailsClass({this.success, this.register, this.data});

  DoctorDetailsClass.fromJson(Map<String, dynamic> json) {
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
  String? email;
  dynamic aboutus;
  String? address;
  String? lat;
  String? lon;
  String? phoneno;
  dynamic services;
  dynamic healthcare;
  String? image;
  int? departmentId;
  String? workingTime;
  String? password;
  dynamic facebookUrl;
  dynamic twitterUrl;
  String? createdAt;
  String? updatedAt;
  String? departmentName;
  double? avgratting;
  int? totalReview;
  String? consultationFee;

  Data(
      {this.id,
        this.name,
        this.email,
        this.aboutus,
        this.address,
        this.lat,
        this.lon,
        this.phoneno,
        this.services,
        this.healthcare,
        this.image,
        this.departmentId,
        this.workingTime,
        this.password,
        this.facebookUrl,
        this.twitterUrl,
        this.createdAt,
        this.updatedAt,
        this.departmentName,
        this.avgratting,
        this.totalReview,
        this.consultationFee,
      });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    aboutus = json['aboutus'];
    address = json['address'];
    lat = json['lat'].toString();
    lon = json['lon'].toString();
    phoneno = json['phoneno'].toString();
    services = json['services'];
    healthcare = json['healthcare'];
    image = json['image'];
    departmentId = json['department_id'] is String ? 0 : json['department_id'] ;
    workingTime = json['working_time'].toString();
    password = json['password'].toString();
    facebookUrl = json['facebook_url'];
    twitterUrl = json['twitter_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    departmentName = json['department_name'];
    avgratting = json['avgratting'] != null ? double.parse(json['avgratting'].toString()) : 0;
    totalReview = json['total_review'];
    consultationFee = json['consultation_fees'].toString();
  }

  Map<String, dynamic> toJson() {
    
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['aboutus'] = this.aboutus;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['phoneno'] = this.phoneno;
    data['services'] = this.services;
    data['healthcare'] = this.healthcare;
    data['image'] = this.image;
    //data['department_id'] = this.departmentId.toString();
    data['working_time'] = this.workingTime;
    data['password'] = this.password;
    data['facebook_url'] = this.facebookUrl;
    data['twitter_url'] = this.twitterUrl;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['department_name'] = this.departmentName;
    data['avgratting'] = this.avgratting;
    data['total_review'] = this.totalReview;
    return data;
  }
}
