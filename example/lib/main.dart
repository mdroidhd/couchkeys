// Builds a custom Couchkeys with D-pad navigation and custom styling

import 'package:couchkeys/couchkeys.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couchkeys D-pad Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Couchkeys D-pad Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();
  String _lastSubmittedText = '';

  void _onSubmit() {
    setState(() {
      _lastSubmittedText = controller.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Submitted: ${controller.text}"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 32,
            ),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type something... Use D-pad to navigate",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_lastSubmittedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Last submitted: $_lastSubmittedText',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Use arrow keys to navigate, Enter/Space to select',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Couchkeys(
                keyboardHeight: 300,
                controller: controller,
                enableDpadNavigation: true,
                autofocus: true,
                onSubmit: _onSubmit,
                buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey[800]),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                focusedButtonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue[700]),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  side: MaterialStateProperty.all(
                    const BorderSide(color: Colors.blue, width: 3),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                customLayout: [
                  // First row - Numbers
                  ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                      .map((v) => KeyboardKey(
                            action: InsertAction(v),
                            child:
                                Text(v, style: const TextStyle(fontSize: 18)),
                          ))
                      .toList(),
                  // Second row - Letters A-J
                  ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
                      .map((v) => KeyboardKey(
                            action: InsertAction(v),
                            child:
                                Text(v, style: const TextStyle(fontSize: 18)),
                          ))
                      .toList(),
                  // Third row - Letters K-T
                  ["K", "L", "M", "N", "O", "P", "Q", "R", "S", "T"]
                      .map((v) => KeyboardKey(
                            action: InsertAction(v),
                            child:
                                Text(v, style: const TextStyle(fontSize: 18)),
                          ))
                      .toList(),
                  // Fourth row - Letters U-Z + symbols
                  ["U", "V", "W", "X", "Y", "Z", "-", "'", "@", "."]
                      .map((v) => KeyboardKey(
                            action: InsertAction(v),
                            child:
                                Text(v, style: const TextStyle(fontSize: 18)),
                          ))
                      .toList(),
                  // Fifth row - Action keys
                  [
                    KeyboardKey(
                      action: ClearAction(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.clear, size: 18),
                          SizedBox(width: 4),
                          Text("Clear"),
                        ],
                      ),
                    ),
                    KeyboardKey(
                      action: SpaceAction(),
                      flex: 3,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.space_bar, size: 18),
                          SizedBox(width: 4),
                          Text("Space"),
                        ],
                      ),
                    ),
                    KeyboardKey(
                      action: BackspaceAction(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.backspace, size: 18),
                          SizedBox(width: 4),
                          Text("Back"),
                        ],
                      ),
                    ),
                    KeyboardKey(
                      action: SubmitAction(),
                      // Custom focused style for submit button
                      focusedStyle: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green[700]),
                        side: MaterialStateProperty.all(
                          const BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_return, size: 18),
                          SizedBox(width: 4),
                          Text("Enter"),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
