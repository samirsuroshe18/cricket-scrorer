import 'package:cricket_scorer/core/translations/en.dart';
import 'package:cricket_scorer/core/translations/hi.dart';
import 'package:cricket_scorer/core/translations/mr.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en': en, 'mr': mr, 'hi': hi};
}
