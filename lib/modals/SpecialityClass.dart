class SpecialityClass {
  String? success;
  String? register;
  List<Speciality>? data;

  SpecialityClass({this.success, this.register, this.data});

  SpecialityClass.fromJson(Map<String, dynamic> json) {
    success = json['success'].toString();
    register = json['register'];
    if (json['data'] != null) {
      data = <Speciality>[];
      json['data'].forEach((v) {
        data!.add(new Speciality.fromJson(v));
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

class Speciality {
  int? id;
  String? name;
  String? icon;
  int? totalDoctors;

  Speciality({this.id, this.name, this.icon, this.totalDoctors});

  Speciality.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    totalDoctors = json['total_doctors'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['total_doctors'] = this.totalDoctors;
    return data;
  }
}




// class SpecialityClass {
//   String success;
//   String register;
//   Data data;
//
//   SpecialityClass({this.success, this.register, this.data});
//
//   SpecialityClass.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     register = json['register'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     data['register'] = this.register;
//     if (this.data != null) {
//       data['data'] = this.data.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   int currentPage;
//   List<SpecialityData> specialityData;
//   String firstPageUrl;
//   int from;
//   int lastPage;
//   String lastPageUrl;
//   List<Links> links;
//   String nextPageUrl;
//   String path;
//   int perPage;
//   String prevPageUrl;
//   int to;
//   int total;
//
//   Data(
//       {this.currentPage,
//         this.specialityData,
//         this.firstPageUrl,
//         this.from,
//         this.lastPage,
//         this.lastPageUrl,
//         this.links,
//         this.nextPageUrl,
//         this.path,
//         this.perPage,
//         this.prevPageUrl,
//         this.to,
//         this.total});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     currentPage = json['current_page'];
//     if (json['data'] != null) {
//       specialityData = new List<SpecialityData>();
//       json['data'].forEach((v) {
//         specialityData.add(new SpecialityData.fromJson(v));
//       });
//     }
//     firstPageUrl = json['first_page_url'];
//     from = json['from'];
//     lastPage = json['last_page'];
//     lastPageUrl = json['last_page_url'];
//     if (json['links'] != null) {
//       links = new List<Links>();
//       json['links'].forEach((v) {
//         links.add(new Links.fromJson(v));
//       });
//     }
//     nextPageUrl = json['next_page_url'].toString();
//     path = json['path'];
//     perPage = json['per_page'];
//     prevPageUrl = json['prev_page_url'].toString();
//     to = json['to'];
//     total = json['total'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['current_page'] = this.currentPage;
//     if (this.specialityData != null) {
//       data['data'] =
//           this.specialityData.map((v) => v.toJson()).toList();
//     }
//     data['first_page_url'] = this.firstPageUrl;
//     data['from'] = this.from;
//     data['last_page'] = this.lastPage;
//     data['last_page_url'] = this.lastPageUrl;
//     if (this.links != null) {
//       data['links'] = this.links.map((v) => v.toJson()).toList();
//     }
//     data['next_page_url'] = this.nextPageUrl;
//     data['path'] = this.path;
//     data['per_page'] = this.perPage;
//     data['prev_page_url'] = this.prevPageUrl;
//     data['to'] = this.to;
//     data['total'] = this.total;
//     return data;
//   }
// }
//
// class SpecialityData {
//   int id;
//   String name;
//   String icon;
//   int totalDoctors;
//
//   SpecialityData({this.id, this.name, this.icon, this.totalDoctors});
//
//   SpecialityData.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     icon = json['icon'];
//     totalDoctors = json['total_doctors'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['icon'] = this.icon;
//     data['total_doctors'] = this.totalDoctors;
//     return data;
//   }
// }
//
// class Links {
//   String url;
//   String label;
//   bool active;
//
//   Links({this.url, this.label, this.active});
//
//   Links.fromJson(Map<String, dynamic> json) {
//     url = json['url'];
//     label = json['label'].toString();
//     active = json['active'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['url'] = this.url;
//     data['label'] = this.label;
//     data['active'] = this.active;
//     return data;
//   }
// }
