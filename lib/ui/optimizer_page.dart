import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:query_optimizer/ui/utils/scrollable.dart';

class OptimizerPage extends StatefulWidget {
  OptimizerPage({required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _OptimizerPage();
}

class _OptimizerPage extends State<OptimizerPage> {
  @override
  Widget build(BuildContext context) {
    var a = '';
    a += 'select idMovimentacao, DataMovimentacao, Movimentacao.Descricao, TipoMovimento.DescMovimentacao, Categoria.DescCategoria, Contas.Descricao, Valor ';
    a += 'from Movimentacao ';
    a += 'join TipoMovimento on TipoMovimento.idTipoMovimento = Movimentacao.TipoMovimento_idTipoMovimento ';
    a += 'join Categoria on Categoria.idCategoria = Movimentacao.Categoria_idCategoria ';
    a += 'join Contas on Contas.idConta = Movimentacao.Contas_idConta ';
    a += "where TipoMovimento.DescMovimentacao = 'Débito' and Categoria.DescCategoria = 'Salário' and Valor > 10 and Contas.Descricao = 'Bitcoin';";
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
                initialValue: a,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'query', hintText: 'select col1, col2 from tb1 where col1 = 1;'),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [ElevatedButton(onPressed: () {}, child: Text('Go'))],
                ),
              ),
              Expanded(
                  child: makeScrollable(Container(
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
