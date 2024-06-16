class UserLoginResponse {
  int? success;
  Register? register;
  Headers? headers;

  UserLoginResponse({this.success, this.register, this.headers});

  UserLoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    register = json['register'] != null
        ? new Register.fromJson(json['register'])
        : null;
    headers =
    json['headers'] != null ? new Headers.fromJson(json['headers']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.register != null) {
      data['register'] = this.register!.toJson();
    }
    if (this.headers != null) {
      data['headers'] = this.headers!.toJson();
    }
    return data;
  }
}

class Register {
  int? userId;
  String? name;
  int? phone;
  String? email;
  String? profilePic;
  int? connectycubeUserId;
  String? loginId;
  dynamic connectycubePassword;

  Register(
      {this.userId,
        this.name,
        this.phone,
        this.email,
        this.profilePic,
        this.connectycubeUserId,
        this.loginId,
        this.connectycubePassword});

  Register.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    profilePic = json['profile_pic'];
    connectycubeUserId = json['connectycube_user_id'];
    loginId = json['login_id'];
    connectycubePassword = json['connectycube_password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['profile_pic'] = this.profilePic;
    data['connectycube_user_id'] = this.connectycubeUserId;
    data['login_id'] = this.loginId;
    data['connectycube_password'] = this.connectycubePassword;
    return data;
  }
}

class Headers {
  String? accessControlAllowOrigin;

  Headers({this.accessControlAllowOrigin});

  Headers.fromJson(Map<String, dynamic> json) {
    // Check for the key with different casings
    accessControlAllowOrigin = json['Access-Control-Allow-Origin'] ??
        json['access-control-allow-origin'] ??
        json['accessControlAllowOrigin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Access-Control-Allow-Origin'] = this.accessControlAllowOrigin;
    return data;
  }
}
