import 'package:flutter/material.dart';
import 'package:flutter_trabalho/services/authentication_service.dart';
import 'package:flutter_trabalho/widgets/snack_bar_widget.dart';
import 'package:flutter_trabalho/widgets/text_field_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AuthenticationService _authService = AuthenticationService();
  bool _senhaVisivel = false;
  bool _lembrarMe = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _carregarCredenciais();
  }

  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }

  Future<void> _carregarCredenciais() async {
    final prefs = await SharedPreferences.getInstance();
    if (!_isActive) return;
    
    setState(() {
      _lembrarMe = prefs.getBool('lembrarMe') ?? false;
      if (_lembrarMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('senha') ?? '';
        if (_isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Credenciais carregadas automaticamente'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _salvarCredenciais() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lembrarMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('senha', _passwordController.text);
      await prefs.setBool('lembrarMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('senha');
      await prefs.setBool('lembrarMe', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset("assets/borboleta.png", height: 250),
              SizedBox(height: 16),
              Text(
                'Lista de Compras',
                style: TextStyle(
                  fontSize: 34,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 17, 66, 107),
                ),
              ),
              SizedBox(height: 32),
              Form(
                key: _formKey,
                  child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: decoration("E-mail").copyWith(
                      prefixIcon: Icon(Icons.email),
                      hintText: 'exemplo@email.com',
                    ),
                    validator: emailValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: decoration('Senha').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _senhaVisivel = !_senhaVisivel;
                          });
                        },
                      ),
                    ),
                    obscureText: !_senhaVisivel,
                    validator: (value) => passwordValidator(value),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _lembrarMe,
                        onChanged: (value) {
                          setState(() {
                            _lembrarMe = value ?? false;
                          });
                        },
                      ),
                      Text('Lembrar-me'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          String email = _emailController.text;
                          String password = _passwordController.text;
                          
                          await _salvarCredenciais();
                          
                          _authService
                              .loginUser(email: email, password: password)
                              .then((erro) {
                            if (erro != null) {
                              SnackBarWidget(
                                  context: context,
                                  title: erro,
                                  isError: true);
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Entrar'),
                        ],
                      )),
                  TextButton(
                      onPressed: () {
                        print("Navegando para tela de registro");
                        Navigator.pushNamed(context, "/loginRegister");
                      },
                      child: Text("Ainda não tem conta? Registre-se")),
                ],
              ))
            ],
          ),
        )));
  }
}
