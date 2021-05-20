class Column {
	
  late String table;
  late String name;

  Column(String _table, String _name) {
    table = _table;
    name = _name;
  }

  @override
  String toString() {
    // TODO: implement toString
    return table + '.' + name;
  }
}