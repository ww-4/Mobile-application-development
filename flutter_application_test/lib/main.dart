import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/key.env");
  } catch (e) {
    print('Файл key.env не найден, используется только HTTP запрос');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isConnected = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  Future<List<Map<String, dynamic>>>? _messagesFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      setState(() {
        _errorMessage =
            
            'Проверьте файл key.env и настройки.';
      });
      return;
    }

    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

      Supabase.instance.client
          .from('messages')
          .stream(primaryKey: ['id'])
          .listen((List<Map<String, dynamic>> data) {
        print(data);
      });

      setState(() {
        _isConnected = true;
        _errorMessage = null;
      });
      _updateMessages();
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка подключения к Supabase: $e';
      });
    }
  }

  void _updateMessages() {
    setState(() {
      _messagesFuture = _getMessagesFuture();
      _errorMessage = null;
    });
  }

  Future<List<Map<String, dynamic>>> _getMessagesFuture() async {
    if (!_isConnected) {
      await _initializeSupabase();
    }

    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки данных: $e';
      });
      throw Exception('Ошибка загрузки данных: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (!_isConnected || _messageController.text.trim().isEmpty) return;

    try {
      await Supabase.instance.client.from('messages').insert({
        'message': _messageController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      _messageController.clear();
      _updateMessages();
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка отправки сообщения: $e';
      });
    }
  }

  void _onUpdateButtonPressed() {
    _updateMessages();
  }

  Future<void> _handleLogin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen(isLogin: true)),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  Future<void> _handleSignUp() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen(isLogin: false)),
    );

    if (result == true) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      setState(() {
        _isAuthenticated = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы вышли из аккаунта'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выхода: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('d MMMM yyyy, HH:mm', 'ru_RU').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-1.0, -1.0),
            end: const Alignment(1.0, 1.0),
            colors: [
              const Color(0xFF808080).withOpacity(0.9),
              const Color(0xFF707070).withOpacity(0.85),
              const Color(0xFF606060).withOpacity(0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF505050).withOpacity(0.5),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (_isAuthenticated) {
              // Пользователь вошел: Настройки / Выход
              if (index == 0) {
                // Настройки - пока без функционала
              } else if (index == 1) {
                _handleSignOut();
              }
            } else {
              // Пользователь не вошел: Вход / Регистрация
              if (index == 0) {
                _handleLogin();
              } else if (index == 1) {
                _handleSignUp();
              }
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          items: _isAuthenticated
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Настройки',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.logout),
                    label: 'Выход',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.login),
                    label: 'Вход',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_add),
                    label: 'Регистрация',
                  ),
                ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
        child: Stack(
          children: [
            // Background image would go here if provided
            // For now, using chrome silver gradient overlay

            // Chrome Glass Mobile Interface
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-1.0, -1.0),
                  end: const Alignment(1.0, 1.0),
                  colors: [
                    const Color(0xFFC0C0C0).withOpacity(0.15), // silver
                    const Color(0xFF808080).withOpacity(0.15), // grey
                    const Color(0xFFA9A9A9).withOpacity(0.15), // dark grey
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Column(
                children: [
                  // Mobile Header - Chrome Silver
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 24,
                      bottom: 24,
                      left: 24,
                      right: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-1.0, -1.0),
                        end: const Alignment(1.0, 1.0),
                        colors: [
                          const Color(0xFFC0C0C0).withOpacity(0.25),
                          const Color(0xFFD3D3D3).withOpacity(0.2),
                          const Color(0xFFA9A9A9).withOpacity(0.25),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC0C0C0).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Main Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              child: const Text(
                                'Добро пожаловать',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFFC0C0C0,
                                  ).withOpacity(0.6),
                                  width: 2,
                                ),
                                gradient: LinearGradient(
                                  begin: const Alignment(-1.0, -1.0),
                                  end: const Alignment(1.0, 1.0),
                                  colors: [
                                    const Color(0xFFD3D3D3).withOpacity(0.3),
                                    const Color(0xFFA9A9A9).withOpacity(0.3),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFC0C0C0,
                                    ).withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.transparent,
                                backgroundImage: const NetworkImage(
                                  'https://i.ibb.co/5Wxmwyqg/630.png',
                                ),
                                onBackgroundImageError:
                                    (exception, stackTrace) {},
                                
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Connection Status Indicator
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isConnected
                                        ? const Color(0xFFCBD5E1) // slate-300
                                        : const Color(0xFF64748B), // slate-500
                                    boxShadow: _isConnected
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFCBD5E1,
                                              ).withOpacity(0.9),
                                              blurRadius: 15,
                                              spreadRadius: 0,
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF64748B,
                                              ).withOpacity(0.8),
                                              blurRadius: 15,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.wifi,
                              size: 16,
                              color: _isConnected
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isConnected ? 'Подключено' : 'Не подключено',
                              style: TextStyle(
                                color: const Color(0xFFE2E8F0), // slate-200
                                fontSize: 14,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black45,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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

                  // Mobile Input Area - Chrome
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
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
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _messageController,
                              onSubmitted: (_) => _sendMessage(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Введите сообщение...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                ),
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isConnected ? _sendMessage : null,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 48,
                              height: 48,
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
                                    color: const Color(
                                      0xFFC0C0C0,
                                    ).withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.send,
                                color: _isConnected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mobile Messages Area - Chrome Style
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-1.0, -1.0),
                            end: const Alignment(1.0, 1.0),
                            colors: [
                              const Color(0xFFA9A9A9).withOpacity(0.15),
                              const Color(0xFF808080).withOpacity(0.1),
                              const Color(0xFFC0C0C0).withOpacity(0.15),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFC0C0C0).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _isConnected && _messagesFuture != null
                              ? FutureBuilder<List<Map<String, dynamic>>>(
                                  future: _messagesFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              size: 48,
                                              color: Colors.redAccent,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Ошибка: ${snapshot.error}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: _updateMessages,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white
                                                    .withOpacity(0.2),
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Повторить'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'Нет сообщений',
                                          style: TextStyle(
                                            color: const Color(0xFFCBD5E1),
                                            fontSize: 18,
                                            shadows: [
                                              const Shadow(
                                                color: Colors.black45,
                                                blurRadius: 3,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return RefreshIndicator(
                                      onRefresh: () async {
                                        _updateMessages();
                                        await _messagesFuture;
                                      },
                                      color: Colors.white,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(20),
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          final message = snapshot.data![index];
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: const Alignment(
                                                  -1.0,
                                                  -1.0,
                                                ),
                                                end: const Alignment(1.0, 1.0),
                                                colors: [
                                                  const Color(
                                                    0xFFD3D3D3,
                                                  ).withOpacity(0.25),
                                                  const Color(
                                                    0xFFC0C0C0,
                                                  ).withOpacity(0.2),
                                                  const Color(
                                                    0xFFA9A9A9,
                                                  ).withOpacity(0.2),
                                                  const Color(
                                                    0xFF808080,
                                                  ).withOpacity(0.15),
                                                  const Color(
                                                    0xFFC0C0C0,
                                                  ).withOpacity(0.25),
                                                ],
                                                stops: const [
                                                  0.0,
                                                  0.25,
                                                  0.5,
                                                  0.75,
                                                  1.0,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: const Color(
                                                  0xFFC0C0C0,
                                                ).withOpacity(0.4),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 25,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  message['message'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black45,
                                                        blurRadius: 3,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _formatDateTime(
                                                    message['created_at'],
                                                  ),
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                    fontSize: 14,
                                                    shadows: [
                                                      const Shadow(
                                                        color: Colors.black45,
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Подключение к базе данных...',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Mobile Refresh Button - Chrome
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onUpdateButtonPressed,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: const Alignment(-1.0, -1.0),
                              end: const Alignment(1.0, 1.0),
                              colors: [
                                const Color(0xFFD3D3D3).withOpacity(0.3),
                                const Color(0xFFC0C0C0).withOpacity(0.25),
                                const Color(0xFFA9A9A9).withOpacity(0.25),
                                const Color(0xFF808080).withOpacity(0.2),
                                const Color(0xFFC0C0C0).withOpacity(0.3),
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFC0C0C0).withOpacity(0.4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC0C0C0).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Обновить',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                     ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}