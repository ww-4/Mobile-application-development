import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 90,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF7A0012),
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.black, width: 4),
                  ),
                ),
                child: const Text(
                  'TEXT',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(
                      flex: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF7A0012),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.black, width: 4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF7A0012),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.black, width: 4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF7A0012),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.black, width: 4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFF7A0012),
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.black, width: 4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF7A0012),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.black, width: 4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF7A0012),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.black, width: 4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFF7A0012),
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.black, width: 4),
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
      ),
    ),
  );
}
