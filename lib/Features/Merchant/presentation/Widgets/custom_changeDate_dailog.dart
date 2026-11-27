import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_textFeild_editData.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/setting_section_tile_widget.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/Edit_userData/edit_user_data_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';
import 'package:myshop/core/Widgets/Cutom_Loading_void.dart';

class CustomChangedateDailog extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final String passingdata;
  final int id;

  const CustomChangedateDailog({
    super.key,
    required this.hintText,
    required this.icon,
    required this.passingdata,
    required this.id,
  });

  @override
  State<CustomChangedateDailog> createState() => _CustomChangedateDailogState();
}

class _CustomChangedateDailogState extends State<CustomChangedateDailog> {
  late final TextEditingController dataController;

  @override
  void initState() {
    super.initState();
    dataController = TextEditingController(text: widget.passingdata);
  }

  @override
  void dispose() {
    dataController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final newValue = dataController.text.trim();
    if (newValue.isNotEmpty) {
      context.read<EditUserDataCubit>().editUserDataMethod(newValue);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditUserDataCubit(),
      child: BlocListener<EditUserDataCubit, EditUserDataState>(
        listener: (context, state) {
          if (state is EditUserDataLoading) {
            showLoadingDialog(context);
          } else if (state is EditUserDataSucesses) {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
            showSnackBar(context, 'نجاح', state.message, ContentType.success);
          } else if (state is EditUserDataFalied) {
            context.pop();
            showSnackBar(context, 'خطأ', state.error, ContentType.failure);
          }
        },
        child: Builder(
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxHeight: 250),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SettingSectionTileWidget(title: widget.hintText),
                      const SizedBox(height: 15),
                      CustomTextFeildToEditData(
                        lexayData: widget.passingdata,
                        hint: widget.hintText,
                        icon: widget.icon,
                        control: dataController,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF37ec13),
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        onPressed: () => _submit(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.solidFloppyDisk,
                              color: Colors.black,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'حفظ',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
