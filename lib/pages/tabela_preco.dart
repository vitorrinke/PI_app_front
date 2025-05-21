import 'package:flutter/material.dart';

class TabelaPrecoPage extends StatefulWidget {
  const TabelaPrecoPage({super.key});

  @override
  State<TabelaPrecoPage> createState() => _TabelaPrecoPageState();
}

class _TabelaPrecoPageState extends State<TabelaPrecoPage> {
  // SIMULAÇÃO DE SERVIÇOS COMO SE VIESSEM DE UMA API
  Future<List<Servico>> obterServicos() async {
    // SIMULA UM ATRASO COMO UMA CHAMADA DE API REAL
    await Future.delayed(const Duration(seconds: 1));

    // LISTA ESTÁTICA POR ENQUANTO, MAS EM BREVE PODE VIR DE UMA API
    return [
      Servico(nome: 'Gesso liso (Parede Rebocada)', valor: 18.00),
      Servico(nome: 'Gesso liso (Alvenaria 25)', valor: 25.00),
      Servico(nome: 'Gesso liso (Chapisco)', valor: 30.00),
      Servico(nome: 'Drywall', valor: 75.00),
      Servico(nome: 'Parede de Drywall', valor: 120.00),
      Servico(nome: 'Moldura (7 cm)', valor: 10.00),
      Servico(nome: 'Moldura (10 cm)', valor: 13.00),
      Servico(nome: 'Moldura (12 cm)', valor: 13.00),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabela de Preços'),
        backgroundColor: const Color(0xFFFFD72C),
      ),
      body: FutureBuilder<List<Servico>>(
        future: obterServicos(), // CHAMADA SIMULADA
        builder: (context, snapshot) {
          // CASO ESTEJA CARREGANDO OS DADOS
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // CASO OCORRA ALGUM ERRO (EX: FALHA DE CONEXÃO)
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os preços.'));
          }

          final servicos = snapshot.data ?? [];

          return ListView.separated(
            itemCount: servicos.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final servico = servicos[index];
              return ListTile(
                title: Text(
                  servico.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  'R\$ ${servico.valor.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// CLASSE DO MODELO DE DADOS DO SERVIÇO
// ESSA ESTRUTURA PODE SER ADAPTADA PARA RECEBER UM JSON DE UMA API FUTURAMENTE
class Servico {
  final String nome;
  final double valor;

  Servico({required this.nome, required this.valor});

  // MÉTODO DE FÁBRICA PARA CONVERTER UM JSON EM UM OBJETO
  // FUTURAMENTE UTILIZADO COM O RETORNO DA API
  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(nome: json['nome'], valor: json['valor'].toDouble());
  }
}
