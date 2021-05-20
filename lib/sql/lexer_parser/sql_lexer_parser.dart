import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:query_optimizer/sql/sintax_parser/sql_parser.dart';
import 'package:query_optimizer/sql/sintax_parser/where_statement.dart';

const db_metadata_url = 'https://8n242oo4sj.execute-api.sa-east-1.amazonaws.com/prod/mysql/getmetadata';

Future<List<TableInfo>> getDatabaseMetaData() async {
  var response = await http.post(Uri.parse(db_metadata_url));
  if (response.statusCode != 200) {
    var message = response.body;
    throw Exception('Failed to get database meta data. Body: $message');
  }
  var decoded = utf8.decode(response.body.runes.toList());
  var metadata = json.decode(decoded);
  if (!(metadata is Map)) throw Exception('Meta data response was not a map.');
  if (!metadata.containsKey('result')) {
    throw Exception('Result not found in meta data response.');
  }
  var result = metadata['result'];
  if (!(result is List)) throw Exception('Result must be a list.');
  return result.map<TableInfo>((e) => TableInfo(e)).toList();
}

class ColumnInfo {
  late String name;
  late String type;
  late bool isNullable;

  ColumnInfo(param) {
    name = param['COLUMN_NAME'];
    type = param['DATA_TYPE'];
    isNullable = param['IS_NULLABLE'] == 'YES';
  }
}

class TableInfo {
  late String table;
  List<ColumnInfo> columns = [];

  TableInfo(param) {
    table = param['TABLE_NAME'];
    columns = param['COLUMNS'].map<ColumnInfo>((x) => ColumnInfo(x)).toList();
  }
}

Future<List<TableInfo>> getRelevantTableInfo(SqlParser sqlParser) async {
  var tables = sqlParser.getTables();
  var tablesInfo = await getDatabaseMetaData();
  return tablesInfo.where((element) => tables.contains(element.table)).toList();
}

void checkColumnLexaly(List<TableInfo> tablesInfo, column) {
  if (column is Iterable) {
    for (var c in column) {
      checkColumnLexaly(tablesInfo, c);
    }
    return;
  }
  if (column == '*') {
    return;
  }
  if (column.contains('.')) {
    var tableColumn = column.split('.');
    var tableName = tableColumn[0];
    checkTableLexaly(tablesInfo, tableName);
  } else {
    var columnCount = tablesInfo.where((element) => element.columns.any((columnInfo) => columnInfo.name == column)).length;
    if (columnCount == 0) {
      throw Exception('Column $column does not exist in any table.');
    } else if (columnCount != 1) {
      throw Exception('Ambiguous column $column.');
    }
  }
}

void checkTableLexaly(List<TableInfo> tablesInfo, table) {
  if (table is Iterable) {
    for (var t in table) {
      checkTableLexaly(tablesInfo, t);
    }
    return;
  }
  var tableExists = tablesInfo.any((element) => element.table == table);
  if (!tableExists) {
    throw Exception('Table $table does not exist.');
  }
}

String getColumnWithTable(String column, List<TableInfo> tablesInfo) {
  if (column.contains('.') || column == '*') return column;
  var tablesWhereColumnAppears = tablesInfo.where((element) => element.columns.any((columnInfo) => columnInfo.name == column));
  if (tablesWhereColumnAppears.isEmpty) {
    throw Exception('Column $column does not exist in any table.');
  } else if (tablesWhereColumnAppears.length != 1) {
    throw Exception('Ambiguous column $column.');
  } else {
    var table = tablesWhereColumnAppears.elementAt(0);
    return table.table + '.' + column;
  }
}

void makeTableNameExplicit(SqlParser parser, List<TableInfo> tablesInfo) {
  for (var i = 0; i < parser.columns.length; i++) {
    parser.columns[i] = getColumnWithTable(parser.columns[i], tablesInfo);
  }
  if (parser.join != null) {
    for (var i = 0; parser.join != null && i < parser.join!.statement.length; i++) {
      var st = parser.join!.statement[i];
      WhereStatement.loop(st.where, (unit) => unit.column = getColumnWithTable(unit.column, tablesInfo));
    }
  }
  if (parser.where != null) {
    var where = parser.where as WhereStatement;
    WhereStatement.loop(where, (unit) => unit.column = getColumnWithTable(unit.column, tablesInfo));
  }
  if (parser.orderBy != null) {
    for (var i = 0; parser.orderBy != null && i < parser.orderBy!.statements.length; i++) {
      var st = parser.orderBy!.statements[i];
      st.column = getColumnWithTable(st.column, tablesInfo);
    }
  }
}

Future checkLexaly(SqlParser sqlParser) async {
  var tablesInfo = await getRelevantTableInfo(sqlParser);
  if (sqlParser.columns.length == 1 && sqlParser.columns[0] == '*') {
    var newColumns = <String>{};
    tablesInfo.forEach((tableInfo) {
      tableInfo.columns.forEach((column) {
        newColumns.add(column.name);
      });
    });
    sqlParser.columns = newColumns.toList();
  }
  makeTableNameExplicit(sqlParser, tablesInfo);
  checkTableLexaly(tablesInfo, sqlParser.table);
  if (sqlParser.join != null) {
    checkTableLexaly(tablesInfo, sqlParser.join!.getTables());
    checkColumnLexaly(tablesInfo, sqlParser.join!.getColumns());
  }
  if (sqlParser.where != null) {
    checkTableLexaly(tablesInfo, sqlParser.where!.getTables());
    checkColumnLexaly(tablesInfo, sqlParser.where!.getColumns());
  }
  if (sqlParser.orderBy != null) {
    checkTableLexaly(tablesInfo, sqlParser.orderBy!.getTables());
    checkColumnLexaly(tablesInfo, sqlParser.orderBy!.getColumns());
  }
  checkColumnLexaly(tablesInfo, sqlParser.columns);
  return true;
}
