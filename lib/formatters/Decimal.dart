import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalFormatter extends TextInputFormatter {
  final int precision;
  DecimalFormatter({@required this.precision});
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text == '0,'.padRight(1 + precision, '0')) {
      return newValue.copyWith(text: '');
    }
    String nt = newValue.text.replaceAll('.', '').replaceAll(',', '');
    // bool negative = false;
    // if (nt.indexOf('-') >= 0) {
    //   negative = true;
    //   nt = nt.replaceAll('-', '');
    // }
    double value = int.parse(nt) / int.parse('1'.padRight(1 + precision, '0'));
    final f = NumberFormat("#,##0.".padRight(6 + precision, '0'), "pt-br");
    // if (negative) value *= -1;
    String newText = f.format(value);
    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
