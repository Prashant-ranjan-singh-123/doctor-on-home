class DoctorAppointmentDetailsClass {
  int? success;
  String? register;
  Data? data;

  DoctorAppointmentDetailsClass({this.success, this.register, this.data});

  DoctorAppointmentDetailsClass.fromJson(Map<String, dynamic> json) {
    success = json['success'];
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
  String? doctorImage;
  String? doctorName;
  String? userImage;
  String? userName;
  int? status;
  int? doctorId;
  int? userId;
  String? date;
  String? slot;
  dynamic phone;
  String? email;
  String? description;
  dynamic connectycubeUserId;
  dynamic id;
  String? prescription;
  List<DeviceToken>? deviceToken;
  String? remainTime;
  int? isAppointmentTime;

  Data(
      {this.doctorImage,
        this.doctorName,
        this.userImage,
        this.userName,
        this.status,
        this.doctorId,
        this.userId,
        this.date,
        this.slot,
        this.phone,
        this.email,
        this.description,
        this.connectycubeUserId,
        this.id,
        this.prescription,
        this.deviceToken,
        this.remainTime,
        this.isAppointmentTime});

  Data.fromJson(Map<String, dynamic> json) {
    doctorImage = json['doctor_image'];
    doctorName = json['doctor_name'];
    userImage = json['user_image'];
    userName = json['user_name'];
    status = json['status'];
    doctorId = json['doctor_id'];
    userId = json['user_id'];
    date = json['date'];
    slot = json['slot'];
    phone = json['phone'];
    email = json['email'];
    description = json['description'];
    connectycubeUserId = json['connectycube_user_id'];
    id = json['id'];
    prescription = json['prescription'];
    if (json['device_token'] != null) {
      deviceToken = <DeviceToken>[];
      json['device_token'].forEach((v) {
        deviceToken!.add(new DeviceToken.fromJson(v));
      });
    }
    remainTime = json['remain_time'];
    isAppointmentTime = json['is_appointment_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['doctor_image'] = this.doctorImage;
    data['doctor_name'] = this.doctorName;
    data['user_image'] = this.userImage;
    data['user_name'] = this.userName;
    data['status'] = this.status;
    data['doctor_id'] = this.doctorId;
    data['user_id'] = this.userId;
    data['date'] = this.date;
    data['slot'] = this.slot;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['description'] = this.description;
    data['connectycube_user_id'] = this.connectycubeUserId;
    data['id'] = this.id;
    data['prescription'] = this.prescription;
    if (this.deviceToken != null) {
      data['device_token'] = this.deviceToken!.map((v) => v.toJson()).toList();
    }
    data['remain_time'] = this.remainTime;
    data['is_appointment_time'] = this.isAppointmentTime;
    return data;
  }
}

class DeviceToken {
  String? token;
  int? type;

  DeviceToken({this.token, this.type});

  DeviceToken.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['type'] = this.type;
    return data;
  }
}
