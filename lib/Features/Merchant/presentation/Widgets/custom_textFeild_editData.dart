import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/Edit_userData/edit_user_data_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';
import 'package:myshop/core/Widgets/custom_loading_widget.dart';

class CustomTextFeildToEditData extends StatefulWidget {
  const CustomTextFeildToEditData({
    super.key,
    required this.hint,
    required this.icon,
    required this.lexayData,
    this.control,
    this.table = 'merchont',
    this.idColumn = 'maerchont_id_fkey',
  });

  final String hint;
  final IconData icon;
  final String lexayData;
  final TextEditingController? control;
  final String table;
  final String idColumn;

  @override
  State<CustomTextFeildToEditData> createState() =>
      _CustomTextFeildToEditDataState();
}

class _CustomTextFeildToEditDataState extends State<CustomTextFeildToEditData> {
  late final TextEditingController _controller;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.lexayData);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeLoadingIfOpen() {
    if (_dialogShown && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _dialogShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditUserDataCubit, EditUserDataState>(
      listener: (context, state) {
        if (state is EditUserDataLoading) {
          _dialogShown = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomLoadingWidget()),
          );
        } else if (state is EditUserDataSucesses) {
          _closeLoadingIfOpen();
          showSnackBar(
            context,
            'نجحت العملية',
            state.message,
            ContentType.success,
          );
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else if (state is EditUserDataFalied) {
          _closeLoadingIfOpen();
          showSnackBar(
            context,
            'تنبيه',
            state.error,
            ContentType.failure,
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF9F9F9),
            elevation: 0,
            title: Text(
              widget.hint,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    prefixIcon: Icon(widget.icon, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF37ec13)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF37ec13),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final trimmed = _controller.text.trim();
                      if (trimmed == widget.lexayData.trim()) {
                        Navigator.of(context).pop();
                        return;
                      }
                      context.read<EditUserDataCubit>().editUserDataMethod(
                        trimmed,
                        table: widget.table,
                        idColumn: widget.idColumn,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF37ec13),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'حفظ التغييرات',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
