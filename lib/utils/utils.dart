

import 'dart:math';

String unixToMonthDay(int unixDate){
  DateTime d = DateTime.fromMillisecondsSinceEpoch(unixDate);
  return "${d.month}-${d.day}";
}

String firstNChars(String str, int n){
  int m = min(str.length, n);
  return m == str.length? str: str.substring(0,n)+"...";
}