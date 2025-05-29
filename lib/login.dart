import 'package:flutter/material.dart';
import 'criarconta.dart';

bool _obscureText = true;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(238, 207, 169, 201),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza os filhos verticalmente
          crossAxisAlignment: CrossAxisAlignment.center, // Garante que tudo seja centralizado horizontalmente
          children: <Widget>[

            // Exibindo a imagem corretamente com BoxFit.contain para evitar zoom
            Image.asset(
              'assets/images/Pagina_login_letras.png', // Caminho correto da imagem
              width: MediaQuery.of(context).size.width * 0.8,  // Largura ajustada (80% da tela)
              fit: BoxFit.contain, // Ajuste para garantir que a imagem não seja cortada ou amplificada
            ),

            const SizedBox(height: 50), // Espaçamento entre imagem e campo de texto
           
            // Campo de texto para 'Utilizador'
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // 80% da largura da tela
              child: TextField(
                style: TextStyle(
                  fontSize: 16, // Tamanho da fonte
                  color: const Color.fromARGB(221, 255, 255, 255), // Cor do texto
                  fontWeight: FontWeight.w500, // Peso da fonte
                ),
                decoration: InputDecoration(
                  labelText: 'Utilizador',
                  fillColor: Color.fromARGB(255, 0, 0, 0), // Cor do fundo (transparente)
                  filled: true,
                  border: OutlineInputBorder(), // Borda
                ),
              ),
            ),
        
        
            const SizedBox(height: 20), // Espaçamento entre campos
        
        
            // Campo para a palavra-passe
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // 80% da largura da tela
              child: TextField(
                            
                obscureText :  _obscureText,
                style: TextStyle(
                  fontSize: 16, // Tamanho da fonte
                  color: const Color.fromARGB(221, 255, 255, 255), // Cor do texto
                  fontWeight: FontWeight.w500, // Peso da fonte
                ),
                decoration: InputDecoration(
                  
                  labelText: 'Palavra-passe',
                  suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                   onPressed: () {
                        setState(() {
                       _obscureText = !_obscureText;
                       });
                    }
                   ),
                  fillColor: Color.fromARGB(255, 0, 0, 0), // Cor do fundo (transparente)
                  filled: true,
                  border: OutlineInputBorder(), // Borda
                ),
              ),
            ),

            const SizedBox(height: 40), // Espaçamento entre campos



          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4, // 80% da largura da tela
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
               backgroundColor: Colors.black, // Cor de fundo
               foregroundColor: const Color.fromARGB(255, 255, 255, 255), // Cor do texto
               textStyle: TextStyle(
                 fontSize: 16,
                  fontWeight: FontWeight.w500,
              ),
         ),
           onPressed: () {
          print("LOGIN");
         },
        child: Text('Entrar'),
      ),
      ),

      const SizedBox(height: 90), // Espaçamento entre imagem e campo de texto

       SizedBox(
          
            child: Text(
                         'Não tem uma conta ?',
                         style: TextStyle(
                               fontSize: 12,
                               fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 255, 255, 255), // Cor do texto
                          ),
                   ),
          ),


    GestureDetector(
     onTap: () {
       
      print('Texto clicado!');
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CriarConta()), // Aqui usa a classe, não um método
           );
    },
        child: Text(
      'Registe-se',
    style: TextStyle(fontSize: 16, color: Colors.blue),
  ),
)


      

 
          ],
        ),
      ),
    );
  }
}
