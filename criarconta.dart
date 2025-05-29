
import 'package:flutter/material.dart';

class CriarConta extends StatelessWidget {
  const CriarConta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(238, 207, 169, 201),
      appBar: AppBar(backgroundColor: Color.fromARGB(238, 207, 169, 201)),
      body: MyHomePage(title: "Criar Conta"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _obscureText2 = true;
  bool _obscureText3 = true;
 
  final TextEditingController nome1Controller = TextEditingController();
  final TextEditingController nome2Controller = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String _errorTextNome = '';
 String _errorTextApelido = '';
 String _errorTextSenha = '';
 String _errorTextConfirmacao = '';
 String _errorTextEmail = '';
void validarDados() {
  setState(() {
    // Validação do Nome
    if (nome1Controller.text.isEmpty) {
      _errorTextNome = "O Nome não pode estar vazio";
    } else {
      _errorTextNome = "";
    }

    // Validação do Apelido
    if (nome2Controller.text.isEmpty) {
      _errorTextApelido = "O Apelido não pode estar vazio";
    } else {
      _errorTextApelido = "";
    }

    // Validação do Email
    if (emailController.text.isEmpty) {
      _errorTextEmail = "O email não pode estar vazio!";
    } else {
      _errorTextEmail = "";
    }

    // Validação da Palavra-passe
    if (passController.text.isEmpty) {
      _errorTextSenha = "A palavra-passe não pode estar vazia!";
    } else if (passController.text.length < 8) {
      _errorTextSenha = "A palavra-passe deve ter pelo menos 8 caracteres!";
    } else {
      _errorTextSenha = ""; // Remove o erro se estiver tudo certo
    }

    // Validação da Confirmação da Palavra-passe
    if (confirmpassController.text.isEmpty) {
      _errorTextConfirmacao = "A confirmação da palavra-passe não pode estar vazia!";
    } else if (passController.text != confirmpassController.text) {
      _errorTextConfirmacao = "As palavras-passe não coincidem!";
    } else {
      _errorTextConfirmacao = "";
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(238, 207, 169, 201),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Imagem
              Image.asset(
                'assets/images/Pagina_login_letras.png', // Caminho correto da imagem
                width: MediaQuery.of(context).size.width * 0.8, // 80% da largura da tela
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              // Nome 1
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: nome1Controller,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                  decoration:  InputDecoration(
                    labelText: 'Nome próprio',
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(),
                   errorText: _errorTextNome.isNotEmpty ? _errorTextNome : null, // Problema aqui

                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nome 2
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: nome2Controller,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                  decoration:  InputDecoration(
                    labelText: 'Apelido',
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(),
                    errorText: _errorTextApelido.isNotEmpty ? _errorTextApelido : null, // Problema aqui

                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Senha
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: passController,
                  obscureText: _obscureText2,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Palavra-passe',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText2 ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureText2 = !_obscureText2;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.black,
                    border: const OutlineInputBorder(),
                  errorText: _errorTextSenha.isNotEmpty ? _errorTextSenha : null, // Problema aqui

                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Confirmar Senha
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: confirmpassController,
                  obscureText: _obscureText3,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Palavra-passe',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText3 ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureText3 = !_obscureText3;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.black,
                    border: const OutlineInputBorder(),
                    errorText: _errorTextConfirmacao.isNotEmpty ? _errorTextConfirmacao : null, // Problema aqui

                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: emailController,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                  decoration:  InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(),
                   errorText: _errorTextEmail.isNotEmpty ? _errorTextEmail : null, // Problema aqui

                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Botão de criar conta
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),


                  onPressed: () {
                    
                    validarDados();
                  },

                  child: const Text('Criar conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
