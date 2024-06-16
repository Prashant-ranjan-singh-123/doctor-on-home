class UpdatedDetails {
  int? success;
  String? register;
  Data? data;

  UpdatedDetails({this.success, this.register, this.data});

  UpdatedDetails.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? loginType;
  String? profilePic;
  String? name;
  String? email;
  int? password;
  int? phone;
  String? createdAt;
  String? updatedAt;
  int? isDeleted;

  Data(
      {this.id,
        this.loginType,
        this.profilePic,
        this.name,
        this.email,
        this.password,
        this.phone,
        this.createdAt,
        this.updatedAt,
        this.isDeleted});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    loginType = json['login_type'];
    profilePic = json['profile_pic'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isDeleted = json['is_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['login_type'] = this.loginType;
    data['profile_pic'] = this.profilePic;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_deleted'] = this.isDeleted;
    return data;
  }
}
