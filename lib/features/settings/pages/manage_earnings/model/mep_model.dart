// To parse this JSON data, do
//
//     final mepModel = mepModelFromJson(jsonString);

import 'dart:convert';

MepModel mepModelFromJson(String str) => MepModel.fromJson(json.decode(str));

String mepModelToJson(MepModel data) => json.encode(data.toJson());

class MepModel {
  bool? status;
  int? totalCoins;
  int? withdrawn;
  int? withdrawable;
  List<Referral>? referrals;
  List<Payout>? payouts;
  List<Payout>? transactions;

  MepModel({
    this.status,
    this.totalCoins,
    this.withdrawn,
    this.withdrawable,
    this.referrals,
    this.payouts,
    this.transactions,
  });

  factory MepModel.fromJson(Map<String, dynamic> json) => MepModel(
        status: json["status"],
        totalCoins: json["total_coins"]??0,
        withdrawn: json["withdrawn"]??0,
        withdrawable: json["withdrawable"]??0,
        referrals: json["referrals"] == null
            ? []
            : List<Referral>.from(
                json["referrals"]!.map((x) => Referral.fromJson(x))),
        payouts: json["payouts"] == null
            ? []
            : List<Payout>.from(
                json["payouts"]!.map((x) => Payout.fromJson(x))),
        transactions: json["transactions"] == null
            ? []
            : List<Payout>.from(
                json["transactions"]!.map((x) => Payout.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "total_coins": totalCoins,
        "withdrawn": withdrawn,
        "withdrawable": withdrawable,
        "referrals": referrals == null
            ? []
            : List<dynamic>.from(referrals!.map((x) => x.toJson())),
        "payouts": payouts == null
            ? []
            : List<dynamic>.from(payouts!.map((x) => x.toJson())),
        "transactions": transactions == null
            ? []
            : List<dynamic>.from(transactions!.map((x) => x.toJson())),
      };
}

class Payout {
  int? id;
  int? paymentMethod;
  int? amount;
  String? created;
  int? trnType;

  Payout({
    this.id,
    this.paymentMethod,
    this.amount,
    this.created,
    this.trnType,
  });

  factory Payout.fromJson(Map<String, dynamic> json) => Payout(
        id: json["id"],
        paymentMethod: json["payment_method"],
        amount: json["amount"],
        created: json["created"],
        trnType: json["trn_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "payment_method": paymentMethod,
        "amount": amount,
        "created": created,
        "trn_type": trnType,
      };
}

class Referral {
  int? id;
  String? name;
  String? displayImage;

  Referral({
    this.id,
    this.name,
    this.displayImage,
  });

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
        id: json["id"],
        name: json["name"],
        displayImage: json["display_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "display_image": displayImage,
      };
}
