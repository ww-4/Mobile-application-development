import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Пытаемся загрузить переменные окружения (опционально)
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
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
  String? _errorMessage;
  String _inputValue = ''; // Состояние для поля ввода
  Future<List<Map<String, dynamic>>>? _messagesFuture; // Future для FutureBuilder

  @override
  void initState() {
    super.initState();
    _initializeSupabase();
  }

  Future<void> _initializeSupabase() async {
    String? supabaseUrl;
    String? supabaseKey;

    // Получение ключа и URL через HTTP PATCH запрос
    try {
      final response = await http.patch(
        Uri.parse('https://college.panfilius.ru/keys.php'),
      );

      if (response.statusCode == 200) {
        // Разбор полученного ответа в формате JSON
        final jsonData = json.decode(response.body);
        supabaseUrl = jsonData['url'] as String?;
        supabaseKey = jsonData['key'] as String?;
        
        if (supabaseUrl == null || supabaseKey == null) {
          throw Exception('Не удалось получить URL или ключ из ответа');
        }
      } else {
        throw Exception('Ошибка HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // Если HTTP запрос не удался, пытаемся получить из переменных окружения
      print('Не удалось получить данные через HTTP: $e');
      print('Попытка получить данные из переменных окружения...');
      
      supabaseUrl = dotenv.env['SUPABASE_URL'];
      supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      if (supabaseUrl == null || supabaseKey == null) {
        setState(() {
          _errorMessage = 'Не удалось получить ключи Supabase.\n'
              'Ошибка HTTP: $e\n'
              'Переменные окружения также не найдены.\n'
              'Проверьте подключение к интернету и настройки.';
        });
        return;
      }
    }

    // Использование полученных данных для подключения к Supabase
    try {
      await Supabase.initialize(
        url: supabaseUrl!,
        anonKey: supabaseKey!,
      );
      setState(() {
        _isConnected = true;
        _errorMessage = null;
      });
      _updateMessages(); // Обновляем Future для FutureBuilder
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка подключения к Supabase: $e';
      });
    }
  }

  // Управление состоянием - обновление Future для FutureBuilder
  void _updateMessages() {
    setState(() {
      _messagesFuture = _getMessagesFuture();
      _errorMessage = null;
    });
  }

  // Получение данных из Supabase
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

  // Управление состоянием - обработка отправки сообщения
  Future<void> _sendMessage() async {
    if (!_isConnected || _messageController.text.trim().isEmpty) return;

    try {
      // Отправка сообщения через insert в базу данных
      await Supabase.instance.client.from('messages').insert({
        'message': _messageController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      _messageController.clear();
      setState(() {
        _inputValue = '';
      });
      
      // Автоматически обновляем список при получении новых данных
      _updateMessages();
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка отправки сообщения: $e';
      });
    }
  }

  // Управление состоянием - обработка изменений в поле ввода
  void _onInputChanged(String value) {
    setState(() {
      _inputValue = value;
    });
  }

  // Управление состоянием - обработка нажатия кнопки обновления
  void _onUpdateButtonPressed() {
    print('Button pressed!');
    setState(() {
      // Кнопка обновления с использованием setState
      _updateMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Test App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Первый Container с заданными параметрами
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.blueAccent,
            child: const Center(
              child: Text(
                'Добро пожаловать!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Row с тремя элементами Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text(
                  'Первый',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Второй',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Третий',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Второй Container с другими параметрами
          Container(
            width: double.infinity,
            height: 60,
            color: Colors.green,
            child: const Center(
              child: Text(
                'Статус подключения',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          // Отображение ошибок
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.shade100,
              width: double.infinity,
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Поле ввода сообщения с обработкой изменений (onChanged)
          // Поле ввода → Управление состоянием
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onInputChanged, // Отправка в управление состоянием
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isConnected ? _sendMessage : null,
                  child: const Text('Отправить'),
                ),
              ],
            ),
          ),
          
          // Expanded с Row и двумя CircleAvatar
          Expanded(
            child: Column(
              children: [
                // Row с CircleAvatar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=200',
                        ),
                        onBackgroundImageError: (exception, stackTrace) {
                          // Обработка ошибки загрузки изображения
                        },
                      ),
                    ],
                  ),
                ),
                
                // FutureBuilder для отображения списка сообщений
                // Supabase DB → FutureBuilder → List.generate → UI
                Expanded(
                  child: _isConnected && _messagesFuture != null
                      ? FutureBuilder<List<Map<String, dynamic>>>(
                          future: _messagesFuture, // Получение данных из Supabase
                          builder: (context, snapshot) {
                            // Проверка состояния подключения (connectionState)
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            // Проверка наличия ошибки (hasError)
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Ошибка: ${snapshot.error}',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _updateMessages,
                                      child: const Text('Повторить'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Проверка наличия данных (hasData)
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('Нет сообщений'),
                              );
                            }

                            // Отображение списка сообщений используя List.generate
                            // FutureBuilder → List.generate
                            return RefreshIndicator(
                              onRefresh: () async {
                                _updateMessages();
                                await _messagesFuture;
                              },
                              child: ListView(
                                children: List.generate(
                                  snapshot.data!.length,
                                  (index) {
                                    final message = snapshot.data![index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          message['message'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          message['created_at'] != null
                                              ? DateTime.parse(
                                                      message['created_at'])
                                                  .toString()
                                              : '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Подключение к базе данных...'),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      // FloatingActionButton с обработчиком onPressed
      // Кнопка обновления → Управление состоянием
      floatingActionButton: FloatingActionButton(
        onPressed: _onUpdateButtonPressed, // Отправка в управление состоянием
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh),
      ),
    );
  }

}
