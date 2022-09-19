import 'package:flutter/material.dart';

Future showResultDialog(BuildContext context, {required Widget child}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: IntrinsicHeight(child: child),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
