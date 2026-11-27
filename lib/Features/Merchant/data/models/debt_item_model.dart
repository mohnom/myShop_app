class DebtItemModel {
  final int id;
  final String nameProduct;
  final double price;
  final int quantity;
  final int idConect;
  final DateTime date;
  final String? note;

  const DebtItemModel({
    required this.id,
    required this.nameProduct,
    required this.price,
    required this.quantity,
    required this.idConect,
    required this.date,
    this.note,
  });

  /// إجمالي سعر هذا المنتج = السعر × الكمية
  double get totalPrice => price * quantity;

  factory DebtItemModel.fromJson(Map<String, dynamic> json) {
    return DebtItemModel(
      id: json['id'] as int,
      nameProduct: json['NameProduct'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['Quantity'] as int,
      idConect: json['ID_Conect'] as int,
      date: DateTime.parse(json['Date'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NameProduct': nameProduct,
      'price': price,
      'Quantity': quantity,
      'ID_Conect': idConect,
      'Date': date.toIso8601String(),
      if (note != null) 'note': note,
    };
  }
}
