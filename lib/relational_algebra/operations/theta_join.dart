import 'package:query_optimizer/relational_algebra/util/conditional.dart';
import 'package:query_optimizer/relational_algebra/util/ra_relational_operator.dart';
import 'package:query_optimizer/sql/sintax_parser/join_statement.dart';

class ThetaJoin implements RArelationalOperator {
  
  ThetaJoin();

  late Conditional condition;

  @override
  late var source;

  @override
  late var source2;

  @override
  final String symbol = '⋈θ';

  static ThetaJoin lastTheta(ThetaJoin join) {
    if (join.source is ThetaJoin) {
      return lastTheta(join.source);
    }
    if (join.source2 is ThetaJoin) {
      return lastTheta(join.source2);
    }
    return join;
  }

  static ThetaJoin reverse(ThetaJoin join) {
    var joins = <ThetaJoin>[join];
    while (join.source is ThetaJoin || join.source2 is ThetaJoin) {
      if (join.source is ThetaJoin) {
        joins.add(join.source);
        join = join.source;
      } else if (join.source2 is ThetaJoin) {
        joins.add(join.source2);
        join = join.source2;
      }
    }
    var cache;
    for (var i = joins.length - 1; i > 0; i--) {
      var currentJoin = joins[i];
      var nextJoin = joins[i - 1];
      if (currentJoin.source is String && currentJoin.source2 is String) {
        if (nextJoin.source is String) {
          cache = nextJoin.source;
          nextJoin.source = currentJoin.source;
        } else if (nextJoin.source2 is String) {
          cache = nextJoin.source2;
          nextJoin.source2 = currentJoin.source;
        } else {
          throw Exception('Invalid theta join.');
        }
        currentJoin.source = nextJoin;
      } else {
        if (currentJoin.source is ThetaJoin) {
          currentJoin.source = nextJoin;
        } else if (currentJoin.source2 is ThetaJoin) {
          currentJoin.source2 = nextJoin;
        } else {
          throw Exception('Invalid theta join.');
        }
        if (i - 1 == 0) {
          if (nextJoin.source is ThetaJoin) {
            nextJoin.source = cache;
          } else if (nextJoin.source2 is ThetaJoin) {
            nextJoin.source2 = cache;
          } else {
            throw Exception('Invalid theta join.');
          }
        } else {
          if (currentJoin.source is String) {
            cache = currentJoin.source;
            currentJoin.source = cache;
          } else if (currentJoin.source2 is String) {
            cache = currentJoin.source2;
            currentJoin.source2 = cache;
          } else {
            throw Exception('Invalid theta join.');
          }
        }
      }
    }
    return joins.last;
  }

  static ThetaJoin build(obj, defaultTable, {table}) {
    var theta = ThetaJoin();
    if (obj is JoinStatement) {
      var a = obj;
      theta.source = defaultTable;
      theta.condition = Conditional.fromWhereStatement(a.statement[0].where, defaultTable);
      if (a.statement.length > 1) {
        theta.source2 = build(a.statement.skip(1), defaultTable, table: a.statement[0].joinedTable);
      } else if (a.statement.length == 1) {
        theta.source2 = a.statement[0].joinedTable;
      } else {
        throw Exception('Invalid number of statements in join.');
      }
    } else if (obj is Iterable<JoinStatementUnit>) {
      var a = obj;
      theta.source = table;
      theta.condition = Conditional.fromWhereStatement(a.elementAt(0).where, defaultTable);
      if (a.length > 1) {
        theta.source2 = build(a.skip(1), defaultTable, table: a.elementAt(0).joinedTable);
      } else if (a.length == 1) {
        theta.source2 = a.elementAt(0).joinedTable;
      } else {
        throw Exception('Invalid number of statements in join.');
      }
    } else {
      throw Exception('Invalid type.');
    }
    return theta;
  }

  String basicString () {
    return '(${source is ThetaJoin? "" : source})$symbol{$condition}(${source2 is ThetaJoin? "" : source2})';
  }

  @override
  String toString() {
    return '($source)$symbol{$condition}($source2)';
  }

  @override
  String simpleString() {
    return '(?)$symbol{$condition}(?)';
  }
}
