import 'package:query_optimizer/relational_algebra/util/ra_relational_operator.dart';

class CrossProduct implements RArelationalOperator {

  @override
  late var source;

  @override
  late var source2;
  
  @override
  String symbol = '×';

  @override
  String simpleString() {
    return '(?)×(?)';
  }

}