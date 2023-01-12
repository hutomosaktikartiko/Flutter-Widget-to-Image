import 'package:flutter/material.dart';

class CustomSnackbar {
  static success({
    required BuildContext context,
    required String label,
  }) {
    showSnackbar(
      context: context,
      snackBar: SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.startToEnd,
        content: Text(label),
        backgroundColor: Colors.green,
      ),
    );
  }

  static error({
    required BuildContext context,
    required String label,
  }) {
    showSnackbar(
      context: context,
      snackBar: SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.startToEnd,
        content: Text(label),
        backgroundColor: Colors.red,
      ),
    );
  }

  static warning({
    required BuildContext context,
    required String label,
  }) {
    showSnackbar(
      context: context,
      snackBar: SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.startToEnd,
        content: Text(label),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static showSnackbar({
    required BuildContext context,
    required SnackBar snackBar,
  }) {
    // Remove queue snackbar
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}