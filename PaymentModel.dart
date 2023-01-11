
class PaymentModel {

  int id;
  int days;
  int endMonth;
  int paymentId;
  dynamic percentage;
  String date;
  int walletId;
  String walletType;
  String coOrd;
  int modeId;
  String mode;
  String refPG;
  String amount;
  bool isPaid = false;

  PaymentModel({
    required this.id,
    required this.days,
    required this.endMonth,
    required this.paymentId,
    required this.percentage,
    required this.date,
    required this.walletId,
    required this.walletType,
    required this.coOrd,
    required this.modeId,
    required this.mode,
    required this.refPG,
    required this.amount,
    required this.isPaid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'days': days,
      'endMonth': endMonth,
      'paymentId': paymentId,
      'percentage': percentage,
      'date': date,
      'walletId': walletId,
      'walletType': walletType,
      'coord': coOrd,
      'modeId': modeId,
      'mode': mode,
      'refPG': refPG,
      'amount': amount,
      'isPaid': isPaid,
    };
  }
}