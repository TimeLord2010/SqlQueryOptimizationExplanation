import 'package:query_optimizer/sql/sintax_parser/sql_parser.dart';
import 'package:query_optimizer/sql/sintax_parser/where_statement.dart';

class JoinStatement {

  List<JoinStatementUnit> statement = [];

  JoinStatement(String s) {
    var singleJoinRegExp = RegExp('join\\s+(?<joinTable>$singleVarPat)\\s+on\\s+(?<joinCondition>$whereExpressionPat)',caseSensitive: false);
    var matches = singleJoinRegExp.allMatches(s);
    for (var match in matches) {
      statement.add(JoinStatementUnit(match));
    }
  }

  Set<String> getTables() {
    var tables = <String>{};
    for (var joinUnit in statement) {
      tables.add(joinUnit.joinedTable);
      tables.addAll(joinUnit.where.getTables());
    }
    return tables;
  }

  Set<String> getColumns () {
    var columns = <String>{};
    for (var unit in statement) {
      columns.addAll(unit.where.getColumns());
    }
    return columns;
  }

  List<Map<String, dynamic>> toJson() {
    return statement.map((e) => e.toJson()).toList();
  }
}

class JoinStatementUnit {

  late String joinedTable;
  late WhereStatement where;

  JoinStatementUnit (RegExpMatch match) {
    var jt = match.namedGroup('joinTable');
    if (jt == null) throw Exception('named group "joinTable" is null.');
    joinedTable = jt;
    var w = match.namedGroup('joinCondition');
    if (w == null) throw Exception('named group "joinCondition" is null.');
    where = WhereStatement(w);
  }

  Map<String, dynamic> toJson () {
    return {
      'joinedTable': joinedTable,
      'where': where.toJson()
    };
  }

}