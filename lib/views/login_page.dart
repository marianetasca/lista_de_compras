import 'package:flutter/material.dart';
import 'package:flutter_trabalho/services/authentication_service.dart';
import 'package:flutter_trabalho/widgets/snack_bar_widget.dart';
import 'package:flutter_trabalho/widgets/text_field_widget.dart';

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
                    decoration: decoration("E-mail"),
                    validator: (value) => requiredValidator(value, "email"),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: decoration('Senha'),
                    obscureText: true,
                    validator: (value) => passwordValidator(value),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          String email = _emailController.text;
                          String password = _passwordController.text;
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
