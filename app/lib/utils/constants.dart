import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.black)),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}

String toCamelCase(String text) {
  List<String> words = text.toLowerCase().split('_');

  for (int i = 1; i < words.length; i++) {
    words[i] = words[i][0].toUpperCase() + words[i].substring(1);
  }

  return words.join('');
}

Map<String, dynamic> toCamelCaseMap(Map<String, dynamic> json) {
  Map<String, dynamic> newJson = {};
  json.forEach((key, value) {
    newJson[toCamelCase(key)] = value;
  });

  return newJson;
}
