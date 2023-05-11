import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveList(List<String> myList) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String encodedList = jsonEncode(myList);
  await prefs.setString('myList', encodedList);
}

// Define a function to retrieve the list of strings from shared preferences
Future<List<String>> getList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? encodedList = prefs.getString('myList');
  if (encodedList != null) {
    List<dynamic> decodedList = jsonDecode(encodedList);
    List<String> myList = decodedList.map((item) => item.toString()).toList();
    return myList;
  } else {
    return [];
  }
}

