import 'package:flutter/material.dart';
import 'detalhes_page.dart';
import 'criar_orcamento_page.dart'; // Import da nova página

const Color kPrimaryColor = Color(0xFFFFD72C); // Cor principal para destaque

class OrcamentoPage extends StatelessWidget {
  const OrcamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> orcamentos = [
      {
        'codigoOrcamento': 1,
        'cliente': 'João da Silva',
        'descricao': 'Serviço de manutenção elétrica',
        'progresso': 40,
        'status': 'Aceito',
      },
      {
        'codigoOrcamento': 2,
        'cliente': 'Maria Oliveira',
        'descricao': 'Pintura de parede interna',
        'progresso': 0,
        'status': 'Pendente',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orcamentos.length,
              itemBuilder: (context, index) {
                final orcamento = orcamentos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      orcamento['cliente'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(orcamento['descricao']),
                    trailing:
                        orcamento['status'] == 'Aceito'
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Progresso"),
                                Text("${orcamento['progresso']}%"),
                                SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    value: orcamento['progresso'] / 100.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor,
                                        ),
                                  ),
                                ),
                              ],
                            )
                            : Text('Status: ${orcamento['status']}'),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DetalhesPage(
                                  codigoOrcamento: orcamento['codigoOrcamento'],
                                ),
                          ),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CriarOrcamentoPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
