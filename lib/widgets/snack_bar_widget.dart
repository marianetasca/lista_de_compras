import 'package:flutter/material.dart';

SnackBarWidget({context, required String title, required isError}) {
  SnackBar snackBar = SnackBar(content: Text(title),
  backgroundColor: isError ? Colors.red : Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}