import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              width: 200,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Text(
                  'Первый',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Второй',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Третий',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Container(width: 150, height: 60, color: Colors.green),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Image.network(
                      'https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?w=800',
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Image.network(
                      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Image.network(
                      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(radius: 40, backgroundColor: Colors.orange),
                  SizedBox(width: 16),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=200',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Уведомление'),
              content: const Text('Button pressed!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
      backgroundColor: Colors.purple,
      foregroundColor: Colors.red,
      child: const Icon(Icons.add),
    ),
      ),
    );
  }
}