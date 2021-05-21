import 'dart:convert';

import 'join_statement.dart';
import 'order_by_statement.dart';
import 'where_statement.dart';

var letters = r'a-zú_';
var singleVarPat = '[' + letters + '][' + letters + r'0-9]*(\.[' + letters + '][' + letters + '0-9]*)?';
//var singleVarPat = r'[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)?';
var numberPat = r'[0-9]+(\.[0-9]+)?';
var stringValuePat = r"'[^']*?'";
var whereOperatorPat = r'(=|>|<|<=|>=|<>|like|(not\s+)?in)';
var multipleVarPat = patSeparatedByComma(singleVarPat);
var columnListOrAll = r'(?<columns>(' + multipleVarPat + r'|\*))';
var whereComparatorPat = '$singleVarPat\\s+$whereOperatorPat\\s+($numberPat|$stringValuePat|$singleVarPat)';
var whereExpressionPat = '$whereComparatorPat(\\s+(and|or)\\s+$whereComparatorPat)*';
var wherePat = '(?<where>\\s+where\\s+$whereExpressionPat)?';
var singleJoinPat = 'join\\s+$singleVarPat\\s+on\\s+$whereExpressionPat';
var nonOptionalJoinPat = '$singleJoinPat(\\s+$singleJoinPat)*';
var joinPat = '(?<join>\\s+$nonOptionalJoinPat)?';
var orderByUnitPat = patSeparatedByComma('($singleVarPat)(\\s+(desc|asc))?');
var orderByPat = r'(?<orderby>\s+order\s+by\s+' + orderByUnitPat + r')?';
var sqlPatStr = '^select\\s+$columnListOrAll\\s+from\\s+(?<table>$singleVarPat)$joinPat$wherePat$orderByPat\\s*;?\$';
var sqlPat = RegExp(sqlPatStr,dotAll: true,caseSensitive: false);

String patSeparatedByComma(String pat) {
  return pat + r'(\s*,\s*' + pat + ')*';
}

class SqlParser {

  late String sql;
  late List<String> columns;
  late String table;
  JoinStatement? join;
  WhereStatement? where;
  OrderByStatement? orderBy;

  SqlParser(String sql) {
    this.sql = sql;
    if (!sqlPat.hasMatch(sql)) throw Exception('Invalid statement $sql.');
    var matches = sqlPat.allMatches(sql);
    if (matches.length != 1) throw Exception('Expected only one match.');
    var match = matches.elementAt(0);
    var columnsGroup = match.namedGroup('columns');
    if (columnsGroup == null) throw Exception('named group "columns" was null.');
    columnsGroup = columnsGroup.replaceAll(' ', '');
    columns = columnsGroup.split(',');
    var tableGroup = match.namedGroup('table');
    if (tableGroup == null) throw Exception('named group "table" was null.');
    table = tableGroup;
    var joinGroup = match.namedGroup('join');
    if (joinGroup != null) join = JoinStatement(joinGroup);
    var whereGroup = match.namedGroup('where');
    if (whereGroup != null) where = WhereStatement(whereGroup);
    var orderGroup = match.namedGroup('orderby');
    if (orderGroup != null) orderBy = OrderByStatement(orderGroup);
  }

  Set<String> getTables () {
    var tables = <String>{};
    tables.add(table);
    if (join != null) {
      tables.addAll(join!.getTables());
    }
    if (where != null) {
      tables.addAll(where!.getTables());
    }
    if (orderBy != null) {
      tables.addAll(orderBy!.getTables());
    }
    return tables;
  }

  Map<String, dynamic> toJson () {
    return {
      'sql': sql,
      'columns': columns,
      'table': table,
      'join': join?.toJson(),
      'where': where?.toJson(),
      'orderBy': orderBy?.toJson()
    };
  }

  @override
  String toString() {
    var encoder = JsonEncoder.withIndent('     ');
    return encoder.convert(toJson());
  }
}
