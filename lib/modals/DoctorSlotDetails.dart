class DoctorSlotsDetails {
  String? success;
  String? register;
  List<SlotsData>? data;

  DoctorSlotsDetails({this.success, this.register, this.data});

  DoctorSlotsDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    if (json['data'] != null) {
      data = <SlotsData>[];
      json['data'].forEach((v) {
        data!.add(new SlotsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['register'] = this.register;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SlotsData {
  int? id;
  int? doctorId;
  int? dayId;
  String? startTime;
  String? endTime;
  String? duration;
  String? createdAt;
  String? updatedAt;
  List<Getslotls>? getslotls;

  SlotsData(
      {this.id,
        this.doctorId,
        this.dayId,
        this.startTime,
        this.endTime,
        this.duration,
        this.createdAt,
        this.updatedAt,
        this.getslotls});

  SlotsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = int.parse(json['doctor_id'].toString());
    dayId = int.parse(json['day_id'].toString());
    startTime = json['start_time'].toString();
    endTime = json['end_time'].toString();
    duration = json['duration'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['getslotls'] != null) {
      getslotls = <Getslotls>[];
      json['getslotls'].forEach((v) {
        getslotls!.add(new Getslotls.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doctor_id'] = this.doctorId;
    data['day_id'] = this.dayId;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['duration'] = this.duration;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.getslotls != null) {
      data['getslotls'] = this.getslotls!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Getslotls {
  int? id;
  int? scheduleId;
  String? slot;
  String? createdAt;
  String? updatedAt;

  Getslotls(
      {this.id, this.scheduleId, this.slot, this.createdAt, this.updatedAt});

  Getslotls.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    scheduleId = int.parse(json['schedule_id'].toString());
    slot = json['slot'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['schedule_id'] = this.scheduleId;
    data['slot'] = this.slot;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
