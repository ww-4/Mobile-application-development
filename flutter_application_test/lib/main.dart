import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем переменные из .env
  await dotenv.load(fileName: "key.env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
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
  double? totalBalance;
  List<dynamic> plannedPayments = [];
  List<dynamic> lastMonthExpenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final supabase = Supabase.instance.client;

    try {
      // Загрузка баланса (берём первую запись)
      final balanceResponse = await supabase.from('balances').select('total_balance').limit(1).single();
      final balance = balanceResponse['total_balance'] as num?;

      // Загрузка плановых платежей
      final plannedResponse = await supabase
          .from('planned_payments')
          .select()
          .order('due_date', ascending: true);

      // Загрузка расходов за март 2025
      final expensesResponse = await supabase
          .from('expenses')
          .select()
          .gte('expense_date', '2025-03-01')
          .lte('expense_date', '2025-03-31')
          .order('expense_date', ascending: false);

      setState(() {
        totalBalance = balance?.toDouble();
        plannedPayments = plannedResponse;
        lastMonthExpenses = expensesResponse;
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка загрузки: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // === Баланс ===
//               Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF66BB6A), Color(0xFF4DB6AC)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.all(Radius.circular(16)),
//                 ),
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: Colors.white.withOpacity(0.8),
//                           radius: 20,
//                           child: Text('👤', style: TextStyle(fontSize: 20)),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.8),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
// child: const Text(
//                             'Payday in a week',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Total balance to spend',
//                       style: TextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                     Text(
//                       '\$${totalBalance?.toStringAsFixed(2) ?? '0.00'}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // === Planning Ahead ===
//               Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Planning Ahead',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '\$${plannedPayments.map((p) => p['amount'] as num).fold(0.0, (a, b) => a + b).abs().toStringAsFixed(2)}',
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 100,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: plannedPayments.length,
//                   itemBuilder: (context, index) {
//                     final item = plannedPayments[index];
//                     final color = Color(int.parse(item['icon_color'].substring(1), radix: 16) + 0xFF000000);
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 12),
//                       child: Container(
//                         width: 80,
//                         decoration: BoxDecoration(
//                           color: color,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.circle, color: Colors.white, size: 24),
//                             const SizedBox(height: 8),
//                             Text(
//                               '\$${(item['amount'] as num).abs().toStringAsFixed(2)}',
//                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'In 2 days',
//                               style: const TextStyle(color: Colors.white70, fontSize: 10),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // === Last Month Expense ===
//               Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Last Month Expense',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '-\$${lastMonthExpenses.map((e) => e['amount'] as num).fold(0.0, (a, b) => a + b).abs().toStringAsFixed(2)}',
// style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 100,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: lastMonthExpenses.length,
//                   itemBuilder: (context, index) {
//                     final item = lastMonthExpenses[index];
//                     final color = Color(int.parse(item['icon_color'].substring(1), radix: 16) + 0xFF000000);
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 12),
//                       child: Container(
//                         width: 120,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey[300]!, width: 1),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: 24,
//                                     height: 24,
//                                     decoration: BoxDecoration(
//                                       color: color,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         item['category'][0],
//                                         style: const TextStyle(color: Colors.white, fontSize: 10),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     item['category'],
//                                     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                                   ),
//                                 ],
//                               ),
//                               const Spacer(),
//                               Text(
//                                 '\$${(item['amount'] as num).abs().toStringAsFixed(2)}',
//                                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // === Часть 1: Простые виджеты ===
          Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text('Text 1'),
              Text('Text 2'),
              Text('Text 3'),
            ],
          ),
          Container(
            width: 200,
            height: 50,
            color: Colors.red,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://www.google.com/imgres?q=networkimage&imgurl=https%3A%2F%2Fmiro.medium.com%2Fv2%2Fresize%3Afit%3A1400%2F1*zl9D5iFcntc9E2xURl6nyA.png&imgrefurl=https%3A%2F%2Fmedium.com%2F%40xrolediamond%2Fwriting-optimal-flutter-code-pt1-networkimage-vs-image-network-and-when-to-use-them-48e9cc5e0d1b&docid=yJt8CE5Lm6NgeM&tbnid=gP3Iv28fOX8fIM&vet=12ahUKEwiIvc6GsK2QAxViU1UIHRknHkEQM3oECCcQAA..i&w=1400&h=699&hcb=2&ved=2ahUKEwiIvc6GsK2QAxViU1UIHRknHkEQM3oECCcQAA'),
                ),
                const SizedBox(width: 20),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Button pressed!');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

