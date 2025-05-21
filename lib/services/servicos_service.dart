import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicoService {
  final String baseUrl = "http://localhost:8000";

  Future<void> createServico(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/servico"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception("falha ao criar serviço");
    }
  }

  Future<Map<String, dynamic>> findServicoById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/servico/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Serviço não encontrado");
    }
  }

  Future<List<dynamic>> findAllServicos() async {
    final response = await http.get(Uri.parse("$baseUrl/servicos"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("falha ao buscar serviços");
    }
  }

  Future<void> updateServico(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/servico/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("falha ao atualizar serviço");
    }
  }

  Future<void> deleteServico(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/servico/$id"));

    if (response.statusCode != 200) {
      throw Exception("falha ao deletar serviço");
    }
  }
}
