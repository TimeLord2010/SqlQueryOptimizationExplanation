import 'package:query_optimizer/sql/sintax_parser/sql_parser.dart';

import '../../string_util.dart';

class WhereStatement {
  dynamic left;
  bool and = false;
  dynamic right;

  WhereStatement(String statement) {
    var parts = splitOnce(statement, RegExp(' and ', caseSensitive: false));
    if (parts.length == 2) {
      left = WhereStatement(parts[0]);
      and = true;
      right = WhereStatement(parts[1]);
      return;
    }
    parts = splitOnce(statement, RegExp(' or ', caseSensitive: false));
    if (parts.length == 2) {
      left = WhereStatement(parts[0]);
      and = false;
      right = WhereStatement(parts[1]);
      return;
    }
    left = WhereStatementUnit(statement);
    and = false;
    right = null;
  }

  Set<String> getTables() {
    var tables = <String>{};
    if (left is WhereStatement || left is WhereStatementUnit) {
      tables.addAll(left.getTables());
    }
    if (right is WhereStatement || right is WhereStatementUnit) {
      tables.addAll(right.getTables());
    }
    return tables;
  }

  Set<String> getColumns() {
    var columns = <String>{};
    if (left is WhereStatement || left is WhereStatementUnit) {
      columns.addAll(left.getColumns());
    }
    if (right is WhereStatement || right is WhereStatementUnit) {
      columns.addAll(right.getColumns());
    }
    return columns;
  }

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    if (left is WhereStatementUnit || left is WhereStatement) {
      result['left'] = left.toJson();
    } else {
      result['left'] = 'Invalid type for left';
    }
    if (right is WhereStatement || right is WhereStatementUnit) {
      result['and'] = and;
      result['right'] = right.toJson();
    }
    return result;
  }

  static void loop(WhereStatement where, Function(WhereStatementUnit) func) {
    if (where == null) return;
    if (where.left is WhereStatement) {
      loop(where.left, func);
    } else if (where.left is WhereStatementUnit) {
      func(where.left);
    }
    if (where.right is WhereStatement) {
      loop(where.right, func);
    } else if (where.right is WhereStatementUnit) {
      func(where.right);
    }
  }
}

class WhereStatementUnit {
  
  late String column;
  late String op;
  late String value;

  WhereStatementUnit(String s) {
    var v =
        '(?<whereColumn>$singleVarPat)\\s+(?<whereOperator>$whereOperatorPat)\\s+(?<whereValue>$numberPat|$stringValuePat|$singleVarPat)';
    var whereComparatorRegExp = RegExp(v, caseSensitive: false);
    var match = whereComparatorRegExp.firstMatch(s);
    if (match == null) {
      throw Exception(
          'Tried to access groups of non where unit: $s.\nPattern: $v');
    }
    var c = match.namedGroup('whereColumn');
    if (c == null) throw Exception('named group "whereColumn" is null.');
    column = c;
    var wo = match.namedGroup('whereOperator');
    if (wo == null) throw Exception('named group "whereOperator" is null.');
    op = wo;
    var wv = match.namedGroup('whereValue');
    if (wv == null) throw Exception('named group "whereValue" is null.');
    value = wv;
  }

  Set<String> getTables() {
    var tables = <String>{};
    if (column.contains('.')) {
      var parts = column.split('.');
      tables.add(parts.first);
    }
    var pat = RegExp('^$singleVarPat\$');
    if (pat.hasMatch(value)) {
      if (value.contains('.')) {
        var parts = value.split('.');
        tables.add(parts.first);
      }
    }
    return tables;
  }

  Set<String> getColumns() {
    var columns = <String>{ column };
    var pat = RegExp('^$singleVarPat\$');
    if (pat.hasMatch(value)) {
      columns.add(value);
    }
    return columns;
  }

  Map<String, dynamic> toJson() {
    return {'column': column, 'operator': op, 'value': value};
  }
}
