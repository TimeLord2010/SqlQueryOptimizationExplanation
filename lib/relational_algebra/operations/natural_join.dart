import 'package:query_optimizer/relational_algebra/util/ra_relational_operator.dart';

class NaturalJoin implements RArelationalOperator {
  @override
  late var source;

  @override
  String symbol = '⋈';

  @override
  late var source2;

  @override
  String simpleString() {
    return '(?)⋈(?)';
  }
  
}