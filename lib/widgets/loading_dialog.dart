import 'package:flutter/material.dart';
import 'package:ifood/widgets/progress_bar.dart';

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circularProgress(),
          const SizedBox(height: 10),
          Text("$message, Please Wait ..."),
        ],
      ),
    );
  }
}
