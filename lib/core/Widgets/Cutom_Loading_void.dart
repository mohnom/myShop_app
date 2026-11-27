import 'package:flutter/material.dart';
import 'package:myshop/core/Widgets/custom_loading_widget.dart';

void showLoadingDialog(BuildContext context) {
   showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CustomLoadingWidget()
  );
  }