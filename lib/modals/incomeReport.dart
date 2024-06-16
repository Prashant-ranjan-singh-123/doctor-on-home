class IncomeReportRes {
  int? success;
  String? register;
  Data? data;

  IncomeReportRes({this.success, this.register, this.data});

  IncomeReportRes.fromJson(Map<String, dynamic> json) {
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
  List<IncomeRecord>? incomeRecord;
  int? totalIncome;

  Data({this.incomeRecord, this.totalIncome});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['income_record'] != null) {
      incomeRecord = <IncomeRecord>[];
      json['income_record'].forEach((v) {
        incomeRecord!.add(new IncomeRecord.fromJson(v));
      });
    }
    totalIncome = json['total_income'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.incomeRecord != null) {
      data['income_record'] =
          this.incomeRecord!.map((v) => v.toJson()).toList();
    }
    data['total_income'] = this.totalIncome;
    return data;
  }
}

class IncomeRecord {
  String? date;
  int? amount;

  IncomeRecord({this.date, this.amount});

  IncomeRecord.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['amount'] = this.amount;
    return data;
  }
}
