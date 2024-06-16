class Call_All_Api {
  int? status;
  String? msg;
  Data? data;

  Call_All_Api({this.status, this.msg, this.data});

  Call_All_Api.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<BannerList>? banner;
  List<Speciality>? speciality;
  List<Appointment>? appointment;

  Data({this.banner, this.speciality, this.appointment});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['banner'] != null) {
      banner = <BannerList>[];
      json['banner'].forEach((v) {
        banner!.add(new BannerList.fromJson(v));
      });
    }
    if (json['speciality'] != null) {
      speciality = <Speciality>[];
      json['speciality'].forEach((v) {
        speciality!.add(new Speciality.fromJson(v));
      });
    }
    if (json['appointment'] != null) {
      appointment = <Appointment>[];
      json['appointment'].forEach((v) {
        appointment!.add(new Appointment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.banner != null) {
      data['banner'] = this.banner!.map((v) => v.toJson()).toList();
    }
    if (this.speciality != null) {
      data['speciality'] = this.speciality!.map((v) => v.toJson()).toList();
    }
    if (this.appointment != null) {
      data['appointment'] = this.appointment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BannerList {
  int? id;
  String? image;

  BannerList({this.id, this.image});

  BannerList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    return data;
  }
}

class Speciality {
  int? id;
  String? name;
  String? icon;

  Speciality({this.id, this.name, this.icon});

  Speciality.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    return data;
  }
}

class Appointment {
  int? id;
  int? doctorId;
  String? date;
  String? slot;
  String? phone;
  String? departmentName;
  Doctorls? doctorls;

  Appointment(
      {this.id,
        this.doctorId,
        this.date,
        this.slot,
        this.phone,
        this.departmentName,
        this.doctorls});

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    date = json['date'];
    slot = json['slot'];
    phone = json['phone'];
    departmentName = json['department_name'];
    doctorls = json['doctorls'] != null
        ? new Doctorls.fromJson(json['doctorls'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_id'] = this.doctorId;
    data['date'] = this.date;
    data['slot'] = this.slot;
    data['phone'] = this.phone;
    data['department_name'] = this.departmentName;
    if (this.doctorls != null) {
      data['doctorls'] = this.doctorls!.toJson();
    }
    return data;
  }
}

class Doctorls {
  String? name;
  String? email;
  String? workingTime;
  String? address;
  String? lat;
  String? lon;
  String? phoneno;
  String? image;
  String? password;
  String? consultationFees;

  Doctorls(
      {this.name,
        this.email,
        this.workingTime,
        this.address,
        this.lat,
        this.lon,
        this.phoneno,
        this.image,
        this.password,
        this.consultationFees});

  Doctorls.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    workingTime = json['working_time'];
    address = json['address'];
    lat = json['lat'];
    lon = json['lon'];
    phoneno = json['phoneno'];
    image = json['image'];
    password = json['password'];
    consultationFees = json['consultation_fees'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['working_time'] = this.workingTime;
    data['address'] = this.address;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['phoneno'] = this.phoneno;
    data['image'] = this.image;
    data['password'] = this.password;
    data['consultation_fees'] = this.consultationFees;
    return data;
  }
}