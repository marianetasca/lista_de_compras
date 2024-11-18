import 'package:flutter/material.dart';
InputDecoration decoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
  );
}
String? requiredValidator(String? value, String fieldName){
  if( value == null||value.isEmpty) {
    return'por favor, insira $fieldName';
  }
  return null;
}
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor, insira a senha';
  }
  if (value.length < 6) {
    return 'A senha deve ter no mínimo 6 caracteres';
  }
  return null;
}