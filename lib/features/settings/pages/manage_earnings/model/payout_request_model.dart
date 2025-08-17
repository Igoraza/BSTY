class PayoutRequestModel {
  final String transactionId;
  final String transactionDate;
  final String transactionAmount;
  final String transactionType;
  bool transactionStatus;

  PayoutRequestModel({
    required this.transactionId,
    required this.transactionDate,
    required this.transactionAmount,
    required this.transactionType,
    this.transactionStatus = false,
  });
}
