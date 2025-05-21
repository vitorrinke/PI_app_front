import 'package:flutter/material.dart';

class DetalhesPage extends StatefulWidget {
  final int codigoOrcamento;

  const DetalhesPage({super.key, required this.codigoOrcamento});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  late Map<String, dynamic> orcamento;
  List<Map<String, dynamic>> itens = [];
  List<Map<String, dynamic>> servicosDisponiveis = [];
  TextEditingController descricaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosSimulados();
  }

  void _carregarDadosSimulados() {
    orcamento = {
      'cliente': 'João da Silva',
      'descricao': 'Serviço de manutenção elétrica',
      'progresso': 40,
      'status': 'Aceito',
    };

    descricaoController.text = orcamento['descricao'];

    itens = [
      {'id': 1, 'nome': 'Drywall', 'preco': 75.00, 'quantidade': 10},
      {'id': 2, 'nome': 'Moldura (10 cm)', 'preco': 13.00, 'quantidade': 5},
    ];

    servicosDisponiveis = [
      {'nome': 'Gesso liso (Parede Rebocada)', 'valor_unitario': 18.00},
      {'nome': 'Gesso liso (Alvenaria 25)', 'valor_unitario': 25.00},
      {'nome': 'Gesso liso (Chapisco)', 'valor_unitario': 30.00},
      {'nome': 'Drywall', 'valor_unitario': 75.00},
      {'nome': 'Parede de Drywall', 'valor_unitario': 120.00},
      {'nome': 'Moldura (7 cm)', 'valor_unitario': 10.00},
      {'nome': 'Moldura (10 cm)', 'valor_unitario': 13.00},
      {'nome': 'Moldura (12 cm)', 'valor_unitario': 13.00},
    ];
  }

  void _adicionarItem(Map<String, dynamic> item) {
    setState(() {
      itens.add(item);
    });
  }

  void _removerItem(int index) {
    setState(() {
      itens.removeAt(index);
    });
  }

  void _atualizarProgresso(double novoValor) {
    setState(() {
      orcamento['progresso'] = novoValor;
    });
  }

  double calcularTotal() {
    return itens.fold(
      0,
      (soma, item) =>
          soma + (item['preco'] as double) * (item['quantidade'] as int),
    );
  }

  void _mostrarDialogoAdicionarItem() {
    String? servicoSelecionado;
    int quantidade = 1;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Adicionar Item'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  hint: const Text('Selecione um serviço'),
                  items:
                      servicosDisponiveis.map((servico) {
                        return DropdownMenuItem(
                          value: servico['nome'] as String,
                          child: Text(servico['nome'] as String),
                        );
                      }).toList(),
                  onChanged: (value) {
                    servicoSelecionado = value;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (metros)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantidade = int.tryParse(value) ?? 1;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (servicoSelecionado != null) {
                    if (itens.any(
                      (item) => item['nome'] == servicoSelecionado,
                    )) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item já adicionado.')),
                      );
                      return;
                    }
                    final servico = servicosDisponiveis.firstWhere(
                      (s) => s['nome'] == servicoSelecionado,
                    );
                    _adicionarItem({
                      'id': itens.length + 1,
                      'nome': servico['nome'],
                      'preco': servico['valor_unitario'],
                      'quantidade': quantidade,
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  void _alterarQuantidade(int index, int novaQuantidade) {
    setState(() {
      itens[index]['quantidade'] = novaQuantidade;
    });
  }

  // Função para enviar as alterações ao banco
  void _salvarAlteracoes() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text('Tem certeza que deseja salvar as alterações?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Enviar dados alterados para o banco de dados
                  // Aqui, seria onde você faria a chamada ao backend para atualizar os dados no banco
                  setState(() {
                    orcamento['descricao'] =
                        descricaoController.text; // Atualiza a descrição
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alterações salvas com sucesso!'),
                    ),
                  );
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Orçamento'),
        backgroundColor: Colors.amber, // cor amarela no topo
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${orcamento['cliente']}'),
            const SizedBox(height: 16),
            const Text(
              'Descrição do Serviço: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                hintText: 'Descrição do serviço',
              ),
              maxLines: null, // Permite múltiplas linhas
            ),
            const SizedBox(height: 16),
            const Text(
              'Itens do Orçamento:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: itens.length,
                itemBuilder: (_, index) {
                  final item = itens[index];
                  return ListTile(
                    title: Text(item['nome'] as String),
                    subtitle: Text(
                      'R\$ ${(item['preco'] as double).toStringAsFixed(2)} x ${item['quantidade']} metros',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.amber, // Ícone lápis amarelo
                          onPressed: () {
                            // Editar quantidade
                            int novaQuantidade = item['quantidade'];
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('Alterar Quantidade'),
                                    content: TextField(
                                      controller: TextEditingController(
                                        text: novaQuantidade.toString(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        novaQuantidade =
                                            int.tryParse(value) ??
                                            novaQuantidade;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Quantidade (metros)',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _alterarQuantidade(
                                            index,
                                            novaQuantidade,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Alterar'),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.amber, // Ícone lixeira amarelo
                          onPressed: () => _removerItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Text(
              'Total: R\$ ${calcularTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // fundo branco
                foregroundColor: Colors.grey[800], // texto/ícone cinza escuro
              ),
              onPressed: _mostrarDialogoAdicionarItem,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Item'),
            ),
            const SizedBox(height: 16),
            Text('Progresso: ${orcamento['progresso'].toInt()}%'),
            Slider(
              value: (orcamento['progresso'] as num).toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '${orcamento['progresso']}%',
              onChanged:
                  (orcamento['status'] == 'Aceito')
                      ? _atualizarProgresso
                      : null,
              activeColor: Colors.amber, // Cor da barra de progresso amarela
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // fundo branco
                foregroundColor: Colors.grey[800], // texto cinza escuro
              ),
              onPressed: _salvarAlteracoes,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
