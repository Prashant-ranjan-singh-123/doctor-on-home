class ReviewsClass {
  String? success;
  String? register;
  List<Data>? data;

  ReviewsClass({this.success, this.register, this.data});

  ReviewsClass.fromJson(Map<String, dynamic> json) {
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
  String? name;
  String? rating;
  String? description;
  String? image;

  Data({this.name, this.rating, this.description, this.image});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    rating = json['rating'].toString();
    description = json['description'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['rating'] = this.rating;
    data['description'] = this.description;
    data['image'] = this.image;
    return data;
  }
}
