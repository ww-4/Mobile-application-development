import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, this.isLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late bool _isLogin;
  String? _errorMessage;
  Future<bool>? _authFuture;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  Future<bool> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    final email = _loginController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        // Вход
        final response = await AuthService.signIn(email, password);
        if (response.user != null) {
          return true;
        } else {
          setState(() {
            _errorMessage = 'Неверный email или пароль';
          });
          return false;
        }
      } else {
        // Регистрация
        final response = await AuthService.signUp(email, password);
        if (response.user != null) {
          setState(() {
            _errorMessage = null;
          });
          return true;
        } else {
          setState(() {
            _errorMessage = 'Ошибка регистрации';
          });
          return false;
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
      });
      return false;
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-1.0, -1.0),
              end: const Alignment(1.0, 1.0),
              colors: [
                const Color(0xFFC0C0C0).withOpacity(0.15),
                const Color(0xFF808080).withOpacity(0.15),
                const Color(0xFFA9A9A9).withOpacity(0.15),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment(-1.0, -1.0),
                          end: Alignment(1.0, 1.0),
                          colors: [
                            Color(0xFFE8E8E8),
                            Color(0xFFC0C0C0),
                            Color(0xFFA8A8A8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          _isLogin ? 'Вход' : 'Регистрация',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-1.0, -1.0),
                            end: const Alignment(1.0, 1.0),
                            colors: [
                              const Color(0xFFA9A9A9).withOpacity(0.2),
                              const Color(0xFF808080).withOpacity(0.15),
                              const Color(0xFFC0C0C0).withOpacity(0.2),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFC0C0C0).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4)),
                          ],
                        ),
                        child: TextFormField(
                          controller: _loginController,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите email';
                            }
                            if (!value.contains('@')) {
                              return 'Введите корректный email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-1.0, -1.0),
                            end: const Alignment(1.0, 1.0),
                            colors: [
                              const Color(0xFFA9A9A9).withOpacity(0.2),
                              const Color(0xFF808080).withOpacity(0.15),
                              const Color(0xFFC0C0C0).withOpacity(0.2),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFC0C0C0).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Пароль',
                            hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите пароль';
                            }
                            if (!_isLogin && value.length < 6) {
                              return 'Пароль должен быть не менее 6 символов';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      FutureBuilder<bool>(
                        future: _authFuture,
                        builder: (context, snapshot) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: snapshot.connectionState == ConnectionState.waiting
                                  ? null
                                  : () {
                                      setState(() {
                                        _errorMessage = null;
                                        _authFuture = _handleAuth();
                                      });
                                    },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment(-1.0, -1.0),
                                    end: Alignment(1.0, 1.0),
                                    colors: [
                                      Color(0xFFC0C0C0),
                                      Color(0xFFA8A8A8),
                                      Color(0xFF909090),
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFC0C0C0).withOpacity(0.5),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: snapshot.connectionState == ConnectionState.waiting
                                      ? const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        )
                                      : Text(
                                          _isLogin ? 'Войти' : 'Зарегистрироваться',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                        ),
                      if (_authFuture != null)
                        FutureBuilder<bool>(
                          future: _authFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (snapshot.hasData && snapshot.data == true && mounted) {
                                  Navigator.of(context).pop(true);
                                }
                              });
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorMessage = null;
                            _loginController.clear();
                            _passwordController.clear();
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Нет аккаунта? Зарегистрироваться'
                              : 'Уже есть аккаунт? Войти',
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

