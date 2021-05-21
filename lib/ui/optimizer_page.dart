import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:query_optimizer/query_optimizer/queryOptimizer.dart';
import 'package:query_optimizer/relational_algebra/util/ra_expression.dart';
import 'package:query_optimizer/sql/lexer_parser/sql_lexer_parser.dart';
import 'package:query_optimizer/sql/sintax_parser/sql_parser.dart';
import 'package:query_optimizer/ui/queryDiagram.dart';
import 'package:query_optimizer/ui/utils/scrollable.dart';

class OptimizerPage extends StatefulWidget {
  OptimizerPage({required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _OptimizerPage();
}

class _OptimizerPage extends State<OptimizerPage> {

  _OptimizerPage ({String? sql}) {
      currentSql = sql ?? "select idMovimentacao, DataMovimentacao, Movimentacao.Descricao, TipoMovimento.DescMovimentacao, Categoria.DescCategoria, Contas.Descricao, Valor from Movimentacao join TipoMovimento on TipoMovimento.idTipoMovimento = Movimentacao.TipoMovimento_idTipoMovimento join Categoria on Categoria.idCategoria = Movimentacao.Categoria_idCategoria join Contas on Contas.idConta = Movimentacao.Contas_idConta where TipoMovimento.DescMovimentacao = 'Débito' and Categoria.DescCategoria = 'Salário' and Valor > 10 and Contas.Descricao = 'Bitcoin';";
  }
  Widget? content;
  String currentSql = "";
  final TextEditingController _nameController = TextEditingController();

  void process() {
    try {
      var parser = SqlParser(currentSql);
      //await checkLexaly(parser);
      var ra = sqlToRelationalAlgebra(parser);
      var optimized = optimize(ra, parser.getTables().toList());
      setState(() {
        //content = makeScrollable(makeDiagram(optimized), width: width);
        content = InteractiveViewer(
          constrained: false,
          boundaryMargin: EdgeInsets.all(10),
          minScale: 0.001,
          maxScale: 5,
          child: makeDiagram(optimized),
        );
      });
    } catch (e) {
      setState(() {
        content = Text(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = currentSql;
    return Scaffold(
        appBar: AppBar(
          title: Text("Query Optimization Explainer"),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                //initialValue: currentSql,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'query', hintText: 'select col1, col2 from tb1 where col1 = 1;'),
                onChanged: (v) {
                  currentSql = v;
                },
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          process();
                        },
                        child: Text('Go')),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _nameController.clear();
                              currentSql = '';
                              content = null;
                            });
                          },
                          child: Text("Clear")),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: content ??
                      makeScrollable(Container(
                        color: Colors.grey[200],
                        child: Stack(
                          children: [
                            Positioned(
                                top: 10,
                                left: 10,
                                child: SizedBox(
                                  width: 50,
                                  height: 900,
                                  child: Container(
                                    color: Colors.black,
                                  ),
                                )),
                            Positioned(
                                left: 100,
                                top: 100,
                                child: SizedBox(
                                  width: 600,
                                  height: 100,
                                  child: Container(
                                    color: Colors.deepOrange,
                                  ),
                                ))
                          ],
                        ),
                      )))
            ],
          ),
        ));
  }
}
