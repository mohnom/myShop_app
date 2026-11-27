class PaymentModel {
  final int id;
  final int idConect;
  final double amount;
  final DateTime date;
  final String? note;

  const PaymentModel({
    required this.id,
    required this.idConect,
    required this.amount,
    required this.date,
    this.note,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      idConect: json['ID_Conect'] as int,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}
