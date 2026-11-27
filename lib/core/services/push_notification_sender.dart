import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة إرسال الإشعارات للزبون عند تسجيل عملية بيع أو تسديد دفعة
class PushNotificationSender {
  PushNotificationSender._();
  static final PushNotificationSender _instance = PushNotificationSender._();
  static PushNotificationSender get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _sendBroadcastOnce({
    required String channelName,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    final channel = _supabase.channel(channelName);
    final completer = Completer<void>();

    channel.subscribe((status, [_]) async {
      if (status == RealtimeSubscribeStatus.subscribed &&
          !completer.isCompleted) {
        try {
          await channel.sendBroadcastMessage(event: event, payload: payload);
        } catch (e) {
          debugPrint('Broadcast send warning: $e');
        } finally {
          completer.complete();
        }
      } else if ((status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) &&
          !completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      await completer.future.timeout(const Duration(seconds: 4));
    } catch (_) {
    } finally {
      try {
        await _supabase.removeChannel(channel);
      } catch (_) {}
    }
  }

  Future<void> _sendFcmViaEdgeFunction({
    required int customerId,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    final customerRow = await _supabase
        .from('cutomers')
        .select('customers_id_fkey')
        .eq('id', customerId)
        .maybeSingle();

    final String? customerAuthId =
        customerRow?['customers_id_fkey'] as String?;
    if (customerAuthId == null || customerAuthId.isEmpty) return;

    final deviceRow = await _supabase
        .from('user_devices')
        .select('fcm_token')
        .eq('user_id', customerAuthId)
        .maybeSingle();

    final String? token = deviceRow?['fcm_token'] as String?;
    if (token == null || token.isEmpty) return;

    try {
      await _supabase.functions.invoke(
        'send-notification',
        body: {
          'token': token,
          'title': title,
          'body': body,
          'data': data,
        },
      );
    } catch (_) {
      // في حال عدم تفعيل الدالة السحابية، يصل الإشعار عبر Supabase Realtime
    }
  }

  /// إرسال إشعار فوري للزبون عند تسجيل عملية بيع جديدة
  Future<void> notifyCustomerOfNewSale({
    required int conectId,
    required String productName,
    required double price,
    required int quantity,
  }) async {
    try {
      final connectRow = await _supabase
          .from('connects')
          .select('ID_customer, Name_merchont')
          .eq('id', conectId)
          .maybeSingle();

      if (connectRow == null) return;

      final int customerId = (connectRow['ID_customer'] as num).toInt();
      final String merchantName =
          (connectRow['Name_merchont'] as String?) ?? 'التاجر';
      final double total = price * quantity;
      final formattedTotal = total.toStringAsFixed(
        total.truncateToDouble() == total ? 0 : 2,
      );

      await _sendBroadcastOnce(
        channelName: 'customer_notifications_$customerId',
        event: 'new_sale',
        payload: {
          'merchant_name': merchantName,
          'product_name': productName,
          'price': price,
          'quantity': quantity,
          'total': total,
          'connect_id': conectId,
        },
      );

      await _sendFcmViaEdgeFunction(
        customerId: customerId,
        title: '🛒 عملية بيع جديدة من $merchantName',
        body:
            'تم إضافة $productName بقيمة $formattedTotal ر.ي (الكمية: $quantity)',
        data: {
          'type': 'new_sale',
          'conect_id': conectId.toString(),
          'merchant_name': merchantName,
        },
      );
    } catch (e) {
      debugPrint('تعذر إرسال إشعار البيع للزبون: $e');
    }
  }

  /// إرسال إشعار فوري للزبون عند تسجيل دفعة تسديد
  Future<void> notifyCustomerOfPayment({
    required int conectId,
    required double amount,
    required double remainingDebt,
  }) async {
    try {
      final connectRow = await _supabase
          .from('connects')
          .select('ID_customer, Name_merchont')
          .eq('id', conectId)
          .maybeSingle();

      if (connectRow == null) return;

      final int customerId = (connectRow['ID_customer'] as num).toInt();
      final String merchantName =
          (connectRow['Name_merchont'] as String?) ?? 'التاجر';

      final formattedAmount = amount.toStringAsFixed(
        amount.truncateToDouble() == amount ? 0 : 2,
      );
      final formattedRemaining = remainingDebt.toStringAsFixed(
        remainingDebt.truncateToDouble() == remainingDebt ? 0 : 2,
      );

      await _sendBroadcastOnce(
        channelName: 'customer_notifications_$customerId',
        event: 'new_payment',
        payload: {
          'merchant_name': merchantName,
          'amount': amount,
          'remaining_debt': remainingDebt,
          'connect_id': conectId,
        },
      );

      await _sendFcmViaEdgeFunction(
        customerId: customerId,
        title: '✅ تم تسجيل دفعة تسديد لدى $merchantName',
        body:
            'تم خصم $formattedAmount ر.ي من حسابك. المتبقي: $formattedRemaining ر.ي',
        data: {
          'type': 'new_payment',
          'conect_id': conectId.toString(),
          'merchant_name': merchantName,
        },
      );
    } catch (e) {
      debugPrint('تعذر إرسال إشعار التسديد للزبون: $e');
    }
  }
}
