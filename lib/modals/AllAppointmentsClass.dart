class AllAppointmentsClass {
  String? success;
  String? register;
  List<Data>? data;

  AllAppointmentsClass({this.success, this.register, this.data});

  AllAppointmentsClass.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  String? date;
  int? id;
  String? slot;
  String? name;
  String? image;
  String? departmentName;
  String? address;
  String? status;

  Data(
      {this.date,
        this.id,
        this.slot,
        this.name,
        this.image,
        this.departmentName,
        this.address,
        this.status});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    id = json['id'];
    slot = json['slot'];
    name = json['name'];
    image = json['image'];
    departmentName = json['department_name'];
    address = json['address'];
    status = json['status'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['id'] = this.id;
    data['slot'] = this.slot;
    data['name'] = this.name;
    data['image'] = this.image;
    data['department_name'] = this.departmentName;
    data['address'] = this.address;
    data['status'] = this.status;
    return data;
  }
}
