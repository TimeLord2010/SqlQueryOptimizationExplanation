import 'package:query_optimizer/relational_algebra/util/ra_operator.dart';
import 'package:query_optimizer/relational_algebra/util/ra_relational_operator.dart';

class RAnavigator {
  List<dynamic> ancestors = [];
  dynamic expression;
  int level = 0;

  bool get isTop {
    return level <= 0 || ancestors.isEmpty;
  }

  bool get isLeaf {
    return expression.source is String;
  }

  bool get isBranch {
    return ['⋈θ', '×', '⋈'].contains(expression.symbol);
  }

  RAnavigator(op) {
    if (op is String) {
      throw Exception('String $op is not a valid argument type.');
    }
    expression = op;
  }

  bool goDown({bool left = true}) {
    if (expression == null || expression.source is String) return false;
    ancestors.add(expression);
    level += 1;
    if (isBranch) {
      RArelationalOperator relational = expression.source;
      if (left) {
        expression = relational.source;
      } else {
        expression = relational.source2;
      }
    } else {
      expression = expression.source;
    }
    return true;
  }

  void goUp() {
    if (isTop) return;
    var lastAncestor = ancestors.removeLast();
    expression = lastAncestor;
    level -= 1;
  }

  void goTop() {
    while (!isTop) {
      goUp();
    }
  }

  void remove (op) {
    if (['⋈θ', '×', '⋈'].contains(op.symbol)) {
      throw Exception('The operation remove does not support branch operators.');
    }
    loop(this, (item, parent) {
      if (item == op) {
        if (parent == null) throw Exception('Parent of $item is null.');
        parent.source = item.source;
      }
    });
  }

  dynamic parentOf (op) {
    var result;
    loop(this, (item, parent) {
      if (item == op) {
        result = parent;
        return true;
      }
    });
    return result;
  }

  static void loop(RAnavigator nav, Function(dynamic, dynamic) func, {bool shouldGoTop = true, parent}) {
    if (shouldGoTop) nav.goTop();
    while (true) {
      var funcResult = func(nav.expression, parent);
      if (funcResult != null) return;
      if (nav.isBranch) {
        if (nav.expression.source is String) {
          func(nav.expression.source, parent);
        } else {
          loop(RAnavigator(nav.expression.source), func, shouldGoTop: false, parent: nav.expression);
        }
        if (nav.expression.source2 is String) {
          func(nav.expression.source2, parent);
        } else {
          loop(RAnavigator(nav.expression.source2), func, shouldGoTop: false, parent: nav.expression);
        }
        break;
      } else {
        if (nav.expression == null || nav.expression.source is String) {
          break;
        } else {
          parent = nav.expression;
          nav.goDown();
        }
      }
    }
  }

  static dynamic lookFor(RAnavigator nav, String table, {bool reset = true, bool left = true, Function(RAoperator)? func}) {
    if (reset) nav.goTop();
    while (true) {
      if (func != null) func(nav.expression);
      if (nav.isBranch) {
        if (nav.expression.source is String) {
          if (nav.expression.source == table) {
            return nav.expression;
          }
        } else {
          var result = lookFor(RAnavigator(nav.expression.source), table, reset: false, func: func);
          if (result != null) return result;
        }
        if (nav.expression.source2 is String) {
          return nav.expression.source2 == table ? nav.expression : null;
        } else {
          return lookFor(RAnavigator(nav.expression.source2), table, left: false, reset: false, func: func);
        }
      } else {
        if (nav.expression == null || nav.expression.source is String) {
          if (nav.expression.source is String && nav.expression.source == table) {
            return nav.expression;
          }
          break;
        } else {
          nav.goDown(left: left);
        }
      }
    }
    return null;
  }
}
