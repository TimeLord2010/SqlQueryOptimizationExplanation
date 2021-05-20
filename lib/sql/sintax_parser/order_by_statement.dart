import 'package:query_optimizer/sql/sintax_parser/sql_parser.dart';

class OrderByStatement {

  List<OrderByStatementUnit> statements = [];

  OrderByStatement (String statement) {
    var orderByRegExp = RegExp('(?<orderByColumn>$singleVarPat)(\\s+(?<orderBySort>desc|asc))', caseSensitive: false);
    var matches = orderByRegExp.allMatches(statement);
    for (var match in matches) {
      statements.add(OrderByStatementUnit(match));
    }
  }

  List<Map<String, dynamic>> toJson() {
    return statements.map((e) => e.toJson()).toList();
  }

  Set<String> getTables() {
    var tables = <String>{};
    for (var unit in statements) {
      var table = unit.getTable();
      if (table != null) tables.add(table);
    }
    return tables;
  }

  Set<String> getColumns () {
    var columns = <String>{};
    for (var unit in statements) {
      columns.add(unit.column);
    }
    return columns;
  }

}

class OrderByStatementUnit {

  late String column;
  late bool asc;

  OrderByStatementUnit (RegExpMatch match) {
    var obc = match.namedGroup('orderByColumn');
    if (obc == null) throw Exception('named group "orderByColumn" is null.');
    column = obc;
    var obs = match.namedGroup('orderBySort');
    if (obs == null) throw Exception('named group "orderBySort" is null.');
    asc = obs == 'asc';
  }

  Map<String, dynamic> toJson() {
    return {
      'column': column,
      'asc': asc
    };
  }

  String? getTable() {
    if (column.contains('.')) {
      var parts = column.split('.');
      return parts.first;
    }
    return null;
  }

}