import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'dart:convert';

import 'pages/login_page.dart';
import 'pages/recuperacao_senha_page.dart';
import 'pages/cadastro_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  // CARREGA O JSON DA CONTA DE SERVIÇO
  final String serviceAccountJson = await rootBundle.loadString(
    'assets/images/chatbot-460222.json',
  );
  final Map<String, dynamic> credentials = json.decode(serviceAccountJson);
  debugPrint("Service account: ${credentials['client_email']}");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/recuperacao': (context) => const RecuperacaoSenhaPage(),
        '/cadastro': (context) => const CadastroPage(),
      },
    );
  }
}
