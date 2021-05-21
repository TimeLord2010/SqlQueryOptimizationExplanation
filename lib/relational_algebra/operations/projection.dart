import 'package:query_optimizer/relational_algebra/util/column.dart';
import 'package:query_optimizer/relational_algebra/util/ra_operator.dart';

class Projection implements RAoperator {

  @override
  late var source;

  @override
  final String symbol = 'π';

  late List<Column> outputColumns;

  Projection.fromColumns(Iterable<Column> columns, s) {
    outputColumns = columns.toList();
    source = s;
  }

  Projection(String defaultTable, List<String> cols) {
    outputColumns = [];
    for (var col in cols) {
      if (col.contains('.')) {
        var parts = col.split('.');
        outputColumns.add(Column(parts[0], parts[1]));
      } else {
        outputColumns.add(Column(col, defaultTable));
      }
    }
  }

  @override
  String toString() {
    return '$symbol $outputColumns ($source)';
  }

  @override
  String simpleString() {
    return '$symbol $outputColumns (?)';
  }
}