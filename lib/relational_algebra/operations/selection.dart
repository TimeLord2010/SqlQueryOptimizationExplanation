import 'package:query_optimizer/relational_algebra/util/conditional.dart';
import 'package:query_optimizer/relational_algebra/util/ra_operator.dart';
import 'package:query_optimizer/sql/sintax_parser/where_statement.dart';

class Selection implements RAoperator {
	
  @override
  late var source;

  @override
  final String symbol = 'σ';

  late Conditional condition;

  Selection ();

  Selection.fromSql(WhereStatement where, String defaultTable) {
    condition = Conditional.fromWhereStatement(where, defaultTable);
  }

  @override
  String toString() {
    return '$symbol {$condition}($source)';
  }
  
}