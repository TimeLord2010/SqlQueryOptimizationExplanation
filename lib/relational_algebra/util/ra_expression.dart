import 'package:query_optimizer/relational_algebra/operations/projection.dart';
import 'package:query_optimizer/relational_algebra/operations/selection.dart';
import 'package:query_optimizer/relational_algebra/operations/theta_join.dart';
import 'package:query_optimizer/sql/sintax_parser/sql_parser.dart';
import 'package:query_optimizer/sql/sintax_parser/where_statement.dart';

class RAexpression {
}

RAexpression sqlToRelationalAlgebra(SqlParser parsed) {
  var projection = Projection(parsed.table, parsed.columns);
  if (parsed.where != null) {
    var selection = Selection.fromSql(parsed.where as WhereStatement, parsed.table);
    projection.source = selection;
    if (parsed.join == null) {
      selection.source = parsed.table;
    } else {
      selection.source = ThetaJoin.reverse(ThetaJoin.build(parsed.join, parsed.table));
    }
  } else if (parsed.join != null) {
	  projection.source = ThetaJoin.reverse(ThetaJoin.build(parsed.join, parsed.table));
  } else {
	  projection.source = parsed.table;
  }
  return projection;
}
