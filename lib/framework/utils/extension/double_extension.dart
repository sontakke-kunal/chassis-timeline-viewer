import 'dart:math';

extension DoubleExtension on double {
  String get getFileSizeString {
    if(this == 0){
      return '';
    }
    const suffixes = ['b', 'kb', 'mb', 'gb', 'tb'];
    try{
      var i = (log(this) / log(1024)).floor();
      return ((this / pow(1024, i)).toStringAsFixed(2)) + suffixes[i].toUpperCase();
    }catch(e){
      return '';
    }
  }
}
