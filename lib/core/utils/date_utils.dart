import 'package:intl/intl.dart';

String hm(DateTime dt) => DateFormat.Hm().format(dt);
String ymd(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
String shortDate(DateTime dt) => DateFormat.MMMd().format(dt);
