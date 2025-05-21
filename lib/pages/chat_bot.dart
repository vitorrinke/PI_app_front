import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

const Color kPrimaryColor = Color(0xFFFFD72C); // AMARELO DA EMPRESA
final Logger _logger = Logger('ChatBotPage'); // LOGGER DEFINIDO

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();

    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      _logger.severe('ERRO: GOOGLE_API_KEY NÃO FOI CARREGADA DO .ENV!');
    } else {
      _logger.info('SUCESSO: GOOGLE_API_KEY CARREGADA COM SUCESSO.');
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': text});
      _controller.clear();
    });

    await _sendToGoogleCloud(text);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendToGoogleCloud(String userMessage) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      _logger.severe('Chave API do Google está vazia.');
      setState(() {
        messages.add({
          'role': 'bot',
          'text': 'Chave da API do Google não configurada corretamente.',
        });
      });
      return;
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
    );

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': userMessage},
          ],
        },
      ],
    });

    _logger.info('Enviando requisição para a API do Google Cloud Gemini...');
    _logger.info('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      _logger.info('Status da resposta: ${response.statusCode}');
      _logger.info('Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          messages.add({'role': 'bot', 'text': reply});
        });
      } else if (response.statusCode == 401) {
        _logger.warning('ERRO 401: Unauthorized - Verifique sua chave API.');
        setState(() {
          messages.add({
            'role': 'bot',
            'text':
                'Erro 401: Não autorizado. Verifique a chave da API do Google.',
          });
        });
      } else {
        _logger.warning('ERRO DA API: ${response.statusCode}');
        setState(() {
          messages.add({
            'role': 'bot',
            'text':
                'Erro ao processar resposta da IA (código ${response.statusCode}).',
          });
        });
      }
    } catch (e) {
      _logger.severe('ERRO AO CHAMAR API DO GOOGLE', e);
      setState(() {
        messages.add({'role': 'bot', 'text': 'Erro de conexão com a IA.'});
      });
    }
  }

  Widget _buildMessage(String role, String text) {
    bool isUser = role == 'user';
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? kPrimaryColor : Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IA Assistente',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final role = messages[index]['role']!;
                final text = messages[index]['text']!;
                return _buildMessage(role, text);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: kPrimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
