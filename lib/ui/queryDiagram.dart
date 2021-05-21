import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:query_optimizer/relational_algebra/util/ra_operator.dart';
import 'package:query_optimizer/relational_algebra/util/ra_relational_operator.dart';

class VisualTreeConfig {
  int nodeHorizontalSpacing = 10;
  int nodeVerticalSpacing = 40;
}

// class Tree<T> {
//   Tree? parent;
//   late T current;
//   List<Tree<T>> children = [];

//   Tree(T c) {
//     current = c;
//   }
// }

// double calcLen (String a) {
//   var l = a.length;
//   return l.toDouble() * 1.0;
// }

// double calculateWidth(RAoperator op, VisualTreeConfig config, {double prev = 0}) {
//   if (op.source is String) {
//     var l = calcLen(op.source);
//     return ((l > prev ? l : prev) + config.nodeHorizontalSpacing).toDouble();
//   } else {
//     if (op is RArelationalOperator) {
//       return calculateWidth(op.source, config, prev: prev) + calculateWidth(op.source2, config, prev: prev);
//     } else {
//       var l = calcLen(op.simpleString());
//       if (l > prev) prev = l;
//       return calculateWidth(op.source, config, prev: prev);
//     }
//   }
// }

// List<Positioned> buildDiagramNodes(op, VisualTreeConfig config, double x, double y, {double? width}) {
//   var list = <Positioned>[];
//   if (width == null) width = calculateWidth(op, config);
//   var value = '';
//   if (op is String) {
//     value = op;
//   } else if (op is RAoperator) {
//     //value = op.symbol;
//     value = op.simpleString();
//   } else {
//     throw Exception('Parameter $op is of type invalid.');
//   }
//   list.add(Positioned(
//     top: y,
//     left: x + width / 2,
//     child: Text('(${(x + width / 2)}, $y)'),
//     //child: Text(value),
//   ));
//   if (op is String) return list;
//   y += config.nodeVerticalSpacing;
//   if (op is RArelationalOperator) {
//     var a = buildDiagramNodes(op.source, config, x, y, width: width / 2);
//     list.addAll(a);
//     var b = buildDiagramNodes(op.source2, config, x + (width / 2), y, width: width / 2);
//     list.addAll(b);
//   } else {
//     var a = buildDiagramNodes(op.source, config, x, y, width: width);
//     list.addAll(a);
//   }
//   return list;
// }

void buildDiagramNodes(Graph graph, op, {Node? parent}) {
  Node? current;
  if (op is String) {
    current = Node.Id(op);
    //current = Node(Text(op));
  } else if (op is RAoperator) {
    current = Node.Id(op.simpleString());
    //current = Node(Text(op.simpleString()));
  } else {
    throw Exception('Parameter $op is of type invalid.');
  }
  if (parent != null) graph.addEdge(parent, current);
  if (op is String) return;
  if (op is RArelationalOperator) {
    buildDiagramNodes(graph, op.source, parent: current);
    buildDiagramNodes(graph, op.source2, parent: current);
  } else {
    buildDiagramNodes(graph, op.source, parent: current);
  }
}

Widget makeDiagram(RAoperator op) {
  var graph = Graph();
  graph.isTree = true;
  var builder = BuchheimWalkerConfiguration();
  builder.siblingSeparation = (100);
  builder.levelSeparation = (150);
  builder.subtreeSeparation = (150);
  //builder.orientation = (BuchheimWalkerConfiguration.ORIENTATION_BOTTOM_TOP);
  builder.orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  buildDiagramNodes(graph, op);
  return GraphView(
      graph: graph,
      algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
      paint: Paint()
        ..color = Colors.blue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
      builder: (Node node) {
        // I can decide what widget should be shown here based on the id
        var a = node.key.value as String;
        return Text(
          a, 
          style: TextStyle(fontWeight: FontWeight.bold),);
      });
}
