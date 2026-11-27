import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareHelper {
  /// مشاركة كشف الحساب المفصل عبر WhatsApp أو نسخ إلى الحافظة
  static Future<void> shareStatement({
    required BuildContext context,
    required String title,
    required double totalDebt,
    required List<DebtItemModel> purchases,
    List<PaymentModel> payments = const [],
    double? grossPurchases,
    double? totalPaid,
  }) async {
    final computedGross =
        grossPurchases ??
        purchases.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    final computedPaid =
        totalPaid ??
        payments.fold<double>(0.0, (sum, item) => sum + item.amount);

    final buffer = StringBuffer();
    buffer.writeln('السلام عليكم ورحمة الله،');
    buffer.writeln('📋 *كشف حساب — $title*');
    buffer.writeln('──────────────────────────────');

    if (purchases.isEmpty) {
      buffer.writeln('• لا توجد مشتريات مسجلة حالياً.');
    } else {
      buffer.writeln('🛒 *المشتريات (${purchases.length}):*');
      for (final item in purchases) {
        final noteStr = (item.note != null && item.note!.isNotEmpty)
            ? ' (${item.note})'
            : '';
        final dateStr = '${item.date.day}/${item.date.month}/${item.date.year}';
        buffer.writeln(
          '• ${item.nameProduct}$noteStr [$dateStr]: ${item.price.toStringAsFixed(2)} × ${item.quantity} = ${item.totalPrice.toStringAsFixed(2)} ر.ي',
        );
      }
    }

    if (payments.isNotEmpty) {
      buffer.writeln('──────────────────────────────');
      buffer.writeln('✅ *الدفعات المسددة (${payments.length}):*');
      for (final p in payments) {
        final noteStr = (p.note != null && p.note!.isNotEmpty)
            ? ' (${p.note})'
            : '';
        final dateStr = '${p.date.day}/${p.date.month}/${p.date.year}';
        buffer.writeln(
          '• دفعة بتاريخ $dateStr$noteStr: -${p.amount.toStringAsFixed(2)} ر.ي',
        );
      }
    }

    buffer.writeln('──────────────────────────────');
    buffer.writeln('إجمالي المشتريات: ${computedGross.toStringAsFixed(2)} ر.ي');
    if (computedPaid > 0) {
      buffer.writeln('إجمالي المسدد: ${computedPaid.toStringAsFixed(2)} ر.ي');
    }
    buffer.writeln(
      '📌 *صافي المبلغ المتبقي: ${totalDebt.toStringAsFixed(2)} ر.ي*',
    );
    final now = DateTime.now();
    buffer.writeln('تاريخ الكشف: ${now.year}-${now.month}-${now.day}');
    buffer.writeln('تم الإصدار عبر تطبيق بقالتي 🙏');

    await shareRawText(context: context, message: buffer.toString());
  }

  /// مشاركة نص عام عبر واتساب أو الحافظة (مثل مشاركة الرقم التعريفي للتاجر)
  static Future<void> shareRawText({
    required BuildContext context,
    required String message,
  }) async {
    final whatsappUrl = Uri.parse(
      'whatsapp://send?text=${Uri.encodeComponent(message)}',
    );
    final webWhatsappUrl = Uri.parse(
      'https://api.whatsapp.com/send?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        return;
      } else if (await canLaunchUrl(webWhatsappUrl)) {
        await launchUrl(webWhatsappUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    await Clipboard.setData(ClipboardData(text: message));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم نسخ النص إلى الحافظة بنجاح!',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Color(0xFF0fa30f),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
