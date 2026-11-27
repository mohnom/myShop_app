import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/Custom_textfeild_addProduct_widget.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/Add_Debt/add_debt_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_purchases/show_purchases_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';

class AddProductBottomSheet extends StatefulWidget {
  const AddProductBottomSheet({
    super.key,
    required this.connectId,
    this.existingItem,
  });

  final int connectId;
  final DebtItemModel? existingItem;

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  bool _isLoading = false;
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController quantityController;
  late final TextEditingController noteController;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    nameController = TextEditingController(text: item?.nameProduct ?? '');
    priceController = TextEditingController(
      text: item != null ? item.price.toString() : '',
    );
    quantityController = TextEditingController(
      text: item != null ? item.quantity.toString() : '',
    );
    noteController = TextEditingController(text: item?.note ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final rawQty = quantityController.text.trim();
    final quantity = rawQty.isEmpty ? 1 : int.tryParse(rawQty);

    if (name.isEmpty) {
      showSnackBar(
        context,
        'تنبيه',
        'يرجى إدخال اسم المنتج',
        ContentType.warning,
      );
      return;
    }
    if (price == null || price <= 0) {
      showSnackBar(
        context,
        'تنبيه',
        'يرجى إدخال سعر صحيح أكبر من صفر',
        ContentType.warning,
      );
      return;
    }
    if (quantity == null || quantity <= 0) {
      showSnackBar(
        context,
        'تنبيه',
        'يرجى إدخال كمية صحيحة لا تقل عن 1',
        ContentType.warning,
      );
      return;
    }

    final cleanNote = noteController.text.trim().isEmpty
        ? null
        : noteController.text.trim();

    if (_isEditing) {
      context.read<AddDebtCubit>().updateDebt(
        purchaseId: widget.existingItem!.id,
        nameProduct: name,
        price: price,
        quantity: quantity,
        note: cleanNote,
      );
    } else {
      context.read<AddDebtCubit>().addDebt(
        name,
        price,
        widget.connectId,
        quantity,
        note: cleanNote,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocListener<AddDebtCubit, AddDebtState>(
          listener: (context, state) {
            if (state is AddDebtSuccess) {
              context.read<ShowPurchasesCubit>().fetchPurchases(
                widget.connectId,
              );
              Navigator.of(context).pop();
              showSnackBar(
                context,
                _isEditing ? 'تم التعديل' : 'تمت الإضافة',
                _isEditing
                    ? 'تم تحديث بيانات المنتج بنجاح'
                    : 'تم إضافة المنتج بنجاح',
                ContentType.success,
              );
            } else if (state is AddDebtFailed) {
              setState(() => _isLoading = false);
              showSnackBar(
                context,
                'حدث خطأ',
                state.error,
                ContentType.failure,
              );
            } else if (state is AddDebtLoading) {
              setState(() => _isLoading = true);
            }
          },
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 8),
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEditing ? 'تعديل عملية البيع' : 'إضافة منتج جديد',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0fa30f),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: const Color(0xFF0fa30f),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('اسم المنتج'),
                        CustomTextFeildAddProduct(
                          hintText: 'مثال: خبز، حليب، أرز',
                          data: nameController,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('السعر للوحدة (ر.ي)'),
                                  CustomTextFeildAddProduct(
                                    hintText: '0.00',
                                    icon: Icons.payments_outlined,
                                    isNumber: true,
                                    textDirection: TextDirection.ltr,
                                    data: priceController,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('الكمية'),
                                  CustomTextFeildAddProduct(
                                    hintText: '1',
                                    icon: Icons.inventory_2_outlined,
                                    isNumber: true,
                                    textDirection: TextDirection.ltr,
                                    data: quantityController,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('ملاحظة (اختياري)'),
                        CustomTextFeildAddProduct(
                          hintText: 'أضف تفاصيل إضافية عن المنتج...',
                          maxLines: 3,
                          data: noteController,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F3F3),
                            foregroundColor: const Color(0xFF1A1C1C),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF19e619),
                            foregroundColor: const Color(0xFFFFFFFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isEditing
                                          ? Icons.save_outlined
                                          : Icons.add_circle_outline,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isEditing
                                          ? 'حفظ التعديلات'
                                          : 'إضافة المنتج',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1C1C),
        fontFamily: 'Cairo',
      ),
    ),
  );
}
