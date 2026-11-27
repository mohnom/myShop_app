import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/input_feild_widget.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/total_debt_Card_widget.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/Debt_Summary_Widget.dart';

void main() {
  group('Models & Financial Calculations', () {
    test('DebtItemModel parses JSON and computes totalPrice accurately', () {
      final json = {
        'id': 101,
        'NameProduct': 'كيس أرز بسمتي',
        'price': 4500.5,
        'Quantity': 2,
        'ID_Conect': 7,
        'Date': '2026-11-26T10:30:00.000Z',
        'note': 'درجة أولى',
      };

      final item = DebtItemModel.fromJson(json);
      expect(item.id, 101);
      expect(item.nameProduct, 'كيس أرز بسمتي');
      expect(item.price, 4500.5);
      expect(item.quantity, 2);
      expect(item.totalPrice, 9001.0);
      expect(item.note, 'درجة أولى');
    });

    test('PaymentModel parses JSON accurately', () {
      final json = {
        'id': 55,
        'ID_Conect': 7,
        'amount': 3000,
        'date': '2026-11-26T12:00:00.000Z',
        'note': 'دفعة نقدية',
      };

      final payment = PaymentModel.fromJson(json);
      expect(payment.id, 55);
      expect(payment.idConect, 7);
      expect(payment.amount, 3000.0);
      expect(payment.note, 'دفعة نقدية');
    });
  });

  group('Core UI Widgets', () {
    testWidgets('DebtSummaryWidget displays net debt, gross, and paid totals', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DebtSummaryWidget(
              primaryGreen: Color(0xFF19e619),
              totalDebt: 1500.00,
              grossPurchases: 2500.00,
              totalPaid: 1000.00,
            ),
          ),
        ),
      );

      expect(find.text('1500.00'), findsOneWidget);
      expect(find.text('2500.00 ر.ي'), findsOneWidget);
      expect(find.text('1000.00 ر.ي'), findsOneWidget);
    });

    testWidgets('TotalDebtWdget displays customer balance and store count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TotalDebtWdget(totalDebt: 750.50, merchantsCount: 3),
          ),
        ),
      );

      expect(find.text('750.50'), findsOneWidget);
      expect(find.text('3 متجر'), findsOneWidget);
    });

    testWidgets('InputField validates email and toggles password visibility', (
      WidgetTester tester,
    ) async {
      final emailCtrl = TextEditingController();
      final passCtrl = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  InputField(
                    label: 'البريد الإلكتروني',
                    hint: 'example@mail.com',
                    icon: Icons.mail_outline,
                    validatorid: 1,
                    control: emailCtrl,
                  ),
                  InputField(
                    label: 'كلمة المرور',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    isPass: true,
                    validatorid: 0,
                    control: passCtrl,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // التحقق من رفض الحقول الفارغة
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('الرجاء إدخال البريد الإلكتروني'), findsOneWidget);

      // التحقق من قبول البيانات الصحيحة
      emailCtrl.text = 'user@baqalati.com';
      passCtrl.text = 'password123';
      expect(formKey.currentState!.validate(), isTrue);

      // تبديل إظهار/إخفاء كلمة المرور
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
