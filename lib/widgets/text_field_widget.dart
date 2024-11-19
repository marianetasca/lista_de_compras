import 'package:flutter/material.dart';

InputDecoration decoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

String? requiredValidator(String? value, String field) {
  if (value == null || value.isEmpty) {
    return 'Por favor, preencha $field';
  }
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'O e-mail é obrigatório';
  }
  
  // Expressão regular para validação de e-mail
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  if (!emailRegex.hasMatch(value)) {
    return 'Digite um e-mail válido';
  }
  
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'A senha é obrigatória';
  }
  if (value.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  return null;
}