import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:myshop/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// حدث وصول عملية بيع أو دفعة تسديد جديدة لتحديث شاشات الزبون لحظياً
class NewSaleEvent {
  final int connectId;
  final String merchantName;
  final String productName;
  final double price;
  final int quantity;
  final double total;
  final bool isPayment;

  const NewSaleEvent({
    required this.connectId,
    required this.merchantName,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
    this.isPayment = false,
  });
}

/// خدمة الاستماع الفوري لإشعارات الزبون عبر Supabase Realtime
class CustomerNotificationListener {
  CustomerNotificationListener._();
  static final CustomerNotificationListener instance =
      CustomerNotificationListener._();

  final SupabaseClient _supabase = Supabase.instance.client;

  RealtimeChannel? _broadcastChannel;
  RealtimeChannel? _postgresChannel;
  int? _activeCustomerId;

  final StreamController<NewSaleEvent> _saleEventsController =
      StreamController<NewSaleEvent>.broadcast();

  Stream<NewSaleEvent> get onNewSaleReceived => _saleEventsController.stream;

  final Set<String> _processedSignatures = <String>{};

  Future<void> startListening({required String authUserId}) async {
    try {
      final customerData = await _supabase
          .from('cutomers')
          .select('id')
          .eq('customers_id_fkey', authUserId)
          .maybeSingle();

      if (customerData == null) return;

      final int customerId = (customerData['id'] as num).toInt();

      if (_activeCustomerId == customerId && _broadcastChannel != null) {
        return;
      }

      await stopListening();
      _activeCustomerId = customerId;

      // 1. قناة البث الفوري للمبيعات والدفعات
      final broadcastChannelName = 'customer_notifications_$customerId';
      _broadcastChannel = _supabase.channel(broadcastChannelName);

      _broadcastChannel!
          .onBroadcast(
            event: 'new_sale',
            callback: (payload) {
              _processSaleNotification(
                connectId: (payload['connect_id'] as num?)?.toInt() ?? 0,
                merchantName:
                    (payload['merchant_name'] as String?) ?? 'التاجر',
                productName:
                    (payload['product_name'] as String?) ?? 'منتج جديد',
                price: (payload['price'] as num?)?.toDouble() ?? 0.0,
                quantity: (payload['quantity'] as num?)?.toInt() ?? 1,
                total: (payload['total'] as num?)?.toDouble() ?? 0.0,
              );
            },
          )
          .onBroadcast(
            event: 'new_payment',
            callback: (payload) {
              _processPaymentNotification(
                connectId: (payload['connect_id'] as num?)?.toInt() ?? 0,
                merchantName:
                    (payload['merchant_name'] as String?) ?? 'التاجر',
                amount: (payload['amount'] as num?)?.toDouble() ?? 0.0,
                remainingDebt:
                    (payload['remaining_debt'] as num?)?.toDouble() ?? 0.0,
              );
            },
          )
          .subscribe();

      // 2. مراقبة قاعدة البيانات كخط حماية ثانٍ
      _postgresChannel = _supabase.channel('customer_db_content_$customerId');
      _postgresChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'Content',
            callback: (payload) async {
              final record = payload.newRecord;
              final int connectId =
                  (record['ID_Conect'] as num?)?.toInt() ?? 0;
              if (connectId == 0) return;

              try {
                final connect = await _supabase
                    .from('connects')
                    .select('Name_merchont')
                    .eq('id', connectId)
                    .eq('ID_customer', customerId)
                    .maybeSingle();

                if (connect != null) {
                  final merchantName =
                      (connect['Name_merchont'] as String?) ?? 'التاجر';
                  final productName =
                      (record['NameProduct'] as String?) ?? 'منتج جديد';
                  final price = (record['price'] as num?)?.toDouble() ?? 0.0;
                  final quantity = (record['Quantity'] as num?)?.toInt() ?? 1;

                  _processSaleNotification(
                    connectId: connectId,
                    merchantName: merchantName,
                    productName: productName,
                    price: price,
                    quantity: quantity,
                    total: price * quantity,
                  );
                }
              } catch (_) {}
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('CustomerNotificationListener error: $e');
    }
  }

  void _processSaleNotification({
    required int connectId,
    required String merchantName,
    required String productName,
    required double price,
    required int quantity,
    required double total,
  }) {
    final effectiveTotal = total > 0 ? total : (price * quantity);
    final signature =
        'sale_${connectId}_${productName}_${price.toStringAsFixed(2)}_$quantity';

    if (_processedSignatures.contains(signature)) return;
    _processedSignatures.add(signature);
    Future.delayed(const Duration(seconds: 15), () {
      _processedSignatures.remove(signature);
    });

    final formattedTotal = effectiveTotal.toStringAsFixed(
      effectiveTotal.truncateToDouble() == effectiveTotal ? 0 : 2,
    );

    NotificationService.instance.showLocalNotification(
      title: '🛒 عملية بيع جديدة من $merchantName',
      body:
          'تم إضافة $productName بقيمة $formattedTotal ر.ي (الكمية: $quantity)',
      payload: jsonEncode({
        'conectId': connectId,
        'merchantName': merchantName,
      }),
    );

    _saleEventsController.add(
      NewSaleEvent(
        connectId: connectId,
        merchantName: merchantName,
        productName: productName,
        price: price,
        quantity: quantity,
        total: effectiveTotal,
      ),
    );
  }

  void _processPaymentNotification({
    required int connectId,
    required String merchantName,
    required double amount,
    required double remainingDebt,
  }) {
    final signature = 'pay_${connectId}_${amount.toStringAsFixed(2)}';
    if (_processedSignatures.contains(signature)) return;
    _processedSignatures.add(signature);
    Future.delayed(const Duration(seconds: 15), () {
      _processedSignatures.remove(signature);
    });

    final formattedAmt = amount.toStringAsFixed(
      amount.truncateToDouble() == amount ? 0 : 2,
    );
    final formattedRem = remainingDebt.toStringAsFixed(
      remainingDebt.truncateToDouble() == remainingDebt ? 0 : 2,
    );

    NotificationService.instance.showLocalNotification(
      title: '✅ دفعة تسديد لدى $merchantName',
      body: 'تم خصم $formattedAmt ر.ي من حسابك. المتبقي: $formattedRem ر.ي',
      payload: jsonEncode({
        'conectId': connectId,
        'merchantName': merchantName,
      }),
    );

    _saleEventsController.add(
      NewSaleEvent(
        connectId: connectId,
        merchantName: merchantName,
        productName: 'دفعة تسديد',
        price: amount,
        quantity: 1,
        total: amount,
        isPayment: true,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_broadcastChannel != null) {
      await _supabase.removeChannel(_broadcastChannel!);
      _broadcastChannel = null;
    }
    if (_postgresChannel != null) {
      await _supabase.removeChannel(_postgresChannel!);
      _postgresChannel = null;
    }
    _activeCustomerId = null;
    _processedSignatures.clear();
  }
}
