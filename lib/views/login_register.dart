import 'package:flutter/material.dart';
import 'package:flutter_trabalho/services/authentication_service.dart';
import 'package:flutter_trabalho/widgets/snack_bar_widget.dart';
import 'package:flutter_trabalho/widgets/text_field_widget.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AuthenticationService _authService = AuthenticationService();
  bool _senhaVisivel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Registrar"),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/borboleta.png', height: 250),
                      SizedBox(height: 20),
                      Form(
                          key: _formKey,
                          child: Column(children: [
                            TextFormField(
                                controller: _nameController,
                                decoration: decoration("Nome").copyWith(
                                  prefixIcon: Icon(Icons.person),
                                  hintText: 'Seu nome completo',
                                ),
                                validator: (value) =>
                                    requiredValidator(value, "o nome"),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: decoration("Email").copyWith(
                                  prefixIcon: Icon(Icons.email),
                                  hintText: 'exemplo@email.com',
                                ),
                                validator: emailValidator,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                                controller: _passwordController,
                                decoration: decoration("Senha").copyWith(
                                  prefixIcon: Icon(Icons.lock),
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
                                validator: passwordValidator,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    String name = _nameController.text;
                                    String email = _emailController.text;
                                    String password = _passwordController.text;
                                    _authService
                                        .registerUser(
                                            name: name,
                                            email: email,
                                            password: password)
                                        .then((erro) {
                                      if (erro != null) {
                                        SnackBarWidget(
                                            context: context,
                                            title: erro,
                                            isError: true);
                                      } else {
                                        SnackBarWidget(
                                            context: context,
                                            title:
                                                "Cadastro efetuado com sucesso!",
                                            isError: false);

                                        Navigator.pop(context);
                                      }
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Registrar'),
                                  ],
                                )),
                            SizedBox(height: 10),
                          ])),
                    ]))));
  }
}
