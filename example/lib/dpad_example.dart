// Demonstrates D-pad navigation with Couchkeys

import 'package:couchkeys/couchkeys.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DpadExampleApp());
}

class DpadExampleApp extends StatelessWidget {
  const DpadExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couchkeys D-pad Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DpadExamplePage(),
    );
  }
}

class DpadExamplePage extends StatefulWidget {
  const DpadExamplePage({super.key});

  @override
  State<DpadExamplePage> createState() => _DpadExamplePageState();
}

class _DpadExamplePageState extends State<DpadExamplePage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Couchkeys D-pad Navigation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'D-pad Navigation Instructions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Use arrow keys to navigate between keys'),
                    Text('• Press Enter, Space, or Select to activate a key'),
                    Text('• The focused key will have a blue border'),
                    Text(
                        '• The first key is auto-focused when the keyboard loads'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text field
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Use D-pad to type here...",
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Virtual keyboard with D-pad support
            Expanded(
              child: Couchkeys(
                controller: controller,
                enableDpadNavigation: true, // Enable D-pad navigation
                autofocus: true, // Auto-focus first key
                keyboardHeight: 300,
                buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.grey[800],
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                customLayout: [
                  // First row - Numbers
                  ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                      .map(
                        (v) => KeyboardKey(
                          action: InsertAction(v),
                          child: Text(
                            v,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                      .toList(),

                  // Second row - QWERTY
                  ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
                      .map(
                        (v) => KeyboardKey(
                          action: InsertAction(v),
                          child: Text(
                            v,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                      .toList(),

                  // Third row - ASDF
                  ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
                      .map(
                    (v) => KeyboardKey(
                      action: InsertAction(v),
                      child: Text(
                        v,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                      .followedBy([
                    KeyboardKey(
                      action: BackspaceAction(),
                      child: const Icon(Icons.backspace, size: 18),
                    ),
                  ]).toList(),

                  // Fourth row - ZXCV
                  ["Z", "X", "C", "V", "B", "N", "M"]
                      .map(
                    (v) => KeyboardKey(
                      action: InsertAction(v),
                      child: Text(
                        v,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                      .followedBy([
                    KeyboardKey(
                      action: SpaceAction(),
                      flex: 2,
                      child: const Text(
                        "SPACE",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    KeyboardKey(
                      action: ClearAction(),
                      child: const Text(
                        "CLEAR",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ]).toList(),
                ],
              ),
            ),

            // Status
            const SizedBox(height: 16),
            Text(
              'Current text: "${controller.text}"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
