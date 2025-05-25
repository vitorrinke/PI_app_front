import 'package:curso_flutter/services/servicos_service.dart';
import 'package:flutter/material.dart';
import '../services/orcamento_service.dart';
import '../services/user.service.dart';
import '../models/user_model.dart';

class CriarOrcamentoPage extends StatefulWidget {
  const CriarOrcamentoPage({super.key});

  @override
  CriarOrcamentoPageState createState() => CriarOrcamentoPageState();
}

class CriarOrcamentoPageState extends State<CriarOrcamentoPage> {
  late Map<String, dynamic> orcamento;
  List<Map<String, dynamic>> itens =
      []; // Lista de itens adicionados ao orçamento
  List<Map<String, dynamic>> servicosDisponiveis =
      []; // Serviços disponíveis para o orçamento
  TextEditingController descricaoController = TextEditingController();
  TextEditingController clienteController = TextEditingController();
  TextEditingController codigoClienteController = TextEditingController();
  final _orcamentoService = OrcamentoService();
  final _servicoService = ServicoService();
  final _userService = UserService();

  // Dados simulados de clientes (na API, seria um retorno de um banco de dados)
  List<Map<String, dynamic>> clientes = [
    {'id': 1, 'nome': 'João Paulo'},
    {'id': 2, 'nome': 'Maria Silva'},
    {'id': 3, 'nome': 'Pedro Costa'},
  ];

  @override
  void initState() {
    super.initState();
    _carregarOrcamentos();
    _carregarServicos();
  }

  void _carregarOrcamentos() async {
    try {
      List<dynamic> fetchedOrcamentos =
          await _orcamentoService.findOrcamentosByView();
      setState(() {
        orcamento = fetchedOrcamentos.first.cast<Map<String, dynamic>>();
      });

      // Populate controllers with the fetched data
      descricaoController.text = orcamento['descricao'];
      clienteController.text = orcamento['cliente'];
      codigoClienteController.text = orcamento['codigo_cliente'];
    } catch (e) {
      print("Erro ao carregar orçamentos: $e");
    }
  }

  // Aqui você também precisaria fazer uma requisição à API para buscar os serviços disponíveis
  void _carregarServicos() async {
    try {
      List<dynamic> fetchedServicos = await _servicoService.findAllServicos();
      setState(() {
        servicosDisponiveis = fetchedServicos.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Erro ao carregar serviços: $e");
    }
  }

  void mostrarDialogoCliente(BuildContext context) async {
    try {
      List<User> clientes =
          await _userService.findAllUsersDart(); // Fetch users dynamically

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Selecione o Código do Cliente'),
              content: ListView.builder(
                shrinkWrap: true,
                itemCount: clientes.length,
                itemBuilder: (context, index) {
                  final cliente = clientes[index];
                  return ListTile(
                    title: Text('${cliente.nome} (${cliente.id})'),
                    onTap: () {
                      codigoClienteController.text = cliente.id.toString();
                      clienteController.text = cliente.nome;
                      Navigator.pop(context); // Fecha o diálogo
                    },
                  );
                },
              ),
            ),
      );
    } catch (e) {
      print("Erro ao buscar clientes: $e");
    }
  }

  void _adicionarItem(Map<String, dynamic> item) {
    setState(() {
      itens.add(item); // Adiciona item à lista de itens do orçamento
    });
  }

  void _removerItem(int index) {
    setState(() {
      itens.removeAt(index); // Remove item da lista
    });
  }

  double calcularTotal() {
    // Calcula o total do orçamento somando os valores de cada item
    return itens.fold(
      0,
      (soma, item) =>
          soma + (item['preco'] as double) * (item['quantidade'] as int),
    );
  }

  void _mostrarDialogoAdicionarItem() {
    // Função para mostrar o dialogo de adicionar um novo item ao orçamento
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
                // Dropdown para escolher o serviço
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
                    servicoSelecionado = value; // Captura serviço selecionado
                  },
                ),
                const SizedBox(height: 8),
                // Campo para inserir a quantidade
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (metros)',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantidade =
                        int.tryParse(value) ?? 1; // Atualiza a quantidade
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o diálogo
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Verifica se o item já foi adicionado ao orçamento
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
                  Navigator.pop(context); // Fecha o diálogo após adicionar
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
    );
  }

  void _salvarOrcamento() {
    // Função para salvar o orçamento (enviar os dados para a API)
    // Aqui você faria uma requisição POST para a API para salvar o orçamento no banco de dados.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Orçamento salvo com sucesso!')),
    );
    Navigator.pop(context); // Fecha a tela de criação do orçamento
  }

  @override
  Widget build(BuildContext context) {
    const corAmarela = Color(0xFFFFD72C); // Cor amarela para o cabeçalho

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Orçamento'),
        backgroundColor: corAmarela,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para selecionar o código do cliente
            const Text(
              'Código do Cliente: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                // Exibe um diálogo para escolher o cliente
                // Aqui você deve obter a lista de clientes da API via GET
                mostrarDialogoCliente(context);
              },
              child: TextField(
                controller: codigoClienteController,
                decoration: const InputDecoration(
                  hintText: 'Código do Cliente',
                ),
                keyboardType: TextInputType.number,
                enabled: false, // Campo somente leitura
              ),
            ),
            const SizedBox(height: 16),
            // Campo para o nome do cliente
            const Text(
              'Cliente: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: clienteController,
              decoration: const InputDecoration(
                hintText: 'Nome do Cliente (Apelido)',
              ),
              enabled: false, // Não permite editar o nome do cliente
            ),
            const SizedBox(height: 16),
            // Campo para descrição do orçamento
            const Text(
              'Descrição do Orçamento: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                hintText: 'Descrição do Orçamento',
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            // Lista de itens do orçamento
            const Text(
              'Itens do Orçamento: ',
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removerItem(index), // Remove o item
                    ),
                  );
                },
              ),
            ),
            // Exibe o total do orçamento
            Text(
              'Total: R\$ ${calcularTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Botão para adicionar um novo item
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
              ),
              onPressed:
                  _mostrarDialogoAdicionarItem, // Chama o diálogo para adicionar item
              icon: Icon(Icons.add, color: corAmarela),
              label: const Text('Adicionar Item'),
            ),
            const SizedBox(height: 16),
            // Botão para salvar o orçamento
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corAmarela,
                foregroundColor: Colors.black,
              ),
              onPressed: _salvarOrcamento, // Salva o orçamento
              child: const Text('Salvar Orçamento'),
            ),
          ],
        ),
      ),
    );
  }
}
