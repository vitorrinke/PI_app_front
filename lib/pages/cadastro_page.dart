// lib/pages/cadastro_page.dart

import 'package:flutter/material.dart';
import 'package:curso_flutter/validators/cadastro_validator.dart';
import '../services/user.service.dart';

const Color kPrimaryColor = Color(0xFFFFD72C); // AMARELO PADRÃO A

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  CadastroPageState createState() => CadastroPageState();
}

class CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>(); // Chave do formulário para validação
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // IMAGEM DE FUNDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img_fundo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // BOTÃO VOLTAR
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // CONTEÚDO CENTRAL
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(217, 255, 255, 255),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Criar Conta',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // NOME
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person, color: kPrimaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        validator: CadastroValidator.validateName,
                      ),
                      const SizedBox(height: 16),

                      // E-MAIL
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email, color: kPrimaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: CadastroValidator.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // SENHA
                      TextFormField(
                        controller: _senhaController,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: CadastroValidator.validatePassword,
                      ),
                      const SizedBox(height: 16),

                      // CONFIRMAR SENHA
                      TextFormField(
                        controller: _confirmarSenhaController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          return CadastroValidator.validateConfirmPassword(
                            value,
                            _senhaController.text,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // BOTÃO "CRIAR CONTA"
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // LÓGICA FUTURA DE CADASTRO
                              // Por exemplo, chamar a API para criar o usuário
                              final userData = {
                                "nome": _nomeController.text,
                                "email": _emailController.text,
                                "senha": _senhaController.text,
                                "tipo_user": 0,
                              };

                              try {
                                await _userService.createUser(userData);
                                print('suceso?');
                              } catch (error) {
                                print(error);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Criar Conta',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
