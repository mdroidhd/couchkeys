library couchkeys;

import 'package:couchkeys/couchkeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide KeyboardKey;

/// A customizable virtual keyboard.
/// The keyboard can be customized with a custom layout, button style, and height.
///
/// The keyboard is built around [KeyboardKey] widgets, which are used to define its layout. It is designed to be used in conjunction with a [TextEditingController].
///
/// This keyboard supports D-pad navigation for Android TV and other devices with directional input.
class Couchkeys extends StatefulWidget {
  /// Callback triggered when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback triggered when submit action is performed (e.g., Enter key pressed).
  final VoidCallback? onSubmit;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Defines a custom layout for the keyboard.
  ///
  /// If null, a default layout will be used.
  final List<List<KeyboardKey>>? customLayout;

  /// Customizes the appearance of the keys.
  /// If a key has its own style, it will merge with this style, overriding any duplicate properties.
  final ButtonStyle? buttonStyle;

  /// Customizes the appearance of focused keys when D-pad navigation is enabled.
  /// If not provided, individual keys can still have their own focusedStyle.
  final ButtonStyle? focusedButtonStyle;

  /// The height of the keyboard.
  /// Defaults to 200.
  final double? keyboardHeight;

  /// Transforms the text before it is inserted into the controller for advanced functionality.
  final String? Function(String? incomingValue)? textTransformer;

  /// Whether to enable D-pad navigation support.
  /// When enabled, users can navigate between keys using arrow keys and select using Enter/Space.
  final bool enableDpadNavigation;

  /// Focus node for the keyboard widget.
  final FocusNode? focusNode;

  /// Whether to auto-focus the first key when the keyboard is created.
  /// Only applies when enableDpadNavigation is true.
  final bool autofocus;

  /// Whether to enable physical keyboard input globally for the virtual keyboard.
  /// When true, typing on a physical keyboard will insert characters when any key is focused.
  final bool enablePhysicalKeyboard;

  /// Creates a new instance of [Couchkeys].
  /// Example:
  /// ```dart
  /// Couchkeys(
  ///   controller: controller,
  ///   keyboardHeight: 200,
  ///   enableDpadNavigation: true,
  ///   onSubmit: () => print('Submit pressed!'),
  /// )
  /// ```
  const Couchkeys({
    super.key,
    this.onChanged,
    this.onSubmit,
    this.controller,
    this.customLayout,
    this.keyboardHeight,
    this.textTransformer,
    this.buttonStyle,
    this.focusedButtonStyle,
    this.enableDpadNavigation = true,
    this.focusNode,
    this.autofocus = false,
    this.enablePhysicalKeyboard = true,
  });

  @override
  State<Couchkeys> createState() => _CouchkeysState();

  /// Static method to get the state and call focus methods
  static _CouchkeysState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CouchkeysState>();
  }
}

class _CouchkeysState extends State<Couchkeys> {
  TextEditingController? _controller;
  late final List<List<KeyboardKey>> _keyLayout;
  late final List<List<FocusNode>> _focusNodes;
  int _currentRow = 0;
  int _currentCol = 0;
  late FocusNode _keyboardFocusNode;

  TextEditingController get effectiveController =>
      widget.controller ?? _controller!;

  /// Manually request focus for the keyboard.
  /// This will focus the current key position or the first key if none was focused before.
  void requestKeyboardFocus() {
    if (widget.enableDpadNavigation && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNodes.isNotEmpty) {
          _focusNodes[_currentRow][_currentCol].requestFocus();
        }
      });
    }
  }

  /// Move focus to a specific key position.
  void focusKey(int row, int col) {
    if (widget.enableDpadNavigation && mounted && _focusNodes.isNotEmpty) {
      final validRow = row.clamp(0, _focusNodes.length - 1);
      final validCol = col.clamp(0, _focusNodes[validRow].length - 1);
      _currentRow = validRow;
      _currentCol = validCol;
      _focusNodes[validRow][validCol].requestFocus();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _createLocalController();

    _keyLayout = widget.customLayout ?? _defaultLayout;
    _keyboardFocusNode = widget.focusNode ?? FocusNode();

    if (widget.enableDpadNavigation) {
      _initializeFocusNodes();
    }

    // Add hardware keyboard listener if physical keyboard is enabled
    if (widget.enablePhysicalKeyboard) {
      HardwareKeyboard.instance.addHandler(_handlePhysicalKeyboard);
    }
  }

  void _initializeFocusNodes() {
    _focusNodes = _keyLayout
        .map((row) => row.map((key) => FocusNode()).toList())
        .toList();

    // Add listeners to track focus changes
    for (int rowIndex = 0; rowIndex < _focusNodes.length; rowIndex++) {
      for (int colIndex = 0;
          colIndex < _focusNodes[rowIndex].length;
          colIndex++) {
        final row = rowIndex;
        final col = colIndex;
        _focusNodes[rowIndex][colIndex].addListener(() {
          if (_focusNodes[row][col].hasFocus) {
            _currentRow = row;
            _currentCol = col;
          }
        });
      }
    }

    // If autofocus is enabled, focus the first key after the frame is built
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNodes.isNotEmpty && _focusNodes[0].isNotEmpty) {
          _focusNodes[0][0].requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _keyboardFocusNode,
      onFocusChange: (value) {
        if (value && mounted && widget.enableDpadNavigation) {
          // When the keyboard gains focus, restore focus to the current key position
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _focusNodes.isNotEmpty) {
              _focusNodes[_currentRow][_currentCol].requestFocus();
            }
          });
        }
      },
      onKeyEvent:
          widget.enableDpadNavigation ? _handleKeyboardNavigation : null,
      child: SizedBox(
        height: widget.keyboardHeight ?? 200,
        child: Column(
          children: [
            for (int rowIndex = 0; rowIndex < _keyLayout.length; rowIndex++)
              _buildRowOfWidgets(_keyLayout[rowIndex], rowIndex),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    if (widget.focusNode == null) {
      _keyboardFocusNode.dispose();
    }
    if (widget.enableDpadNavigation) {
      for (final row in _focusNodes) {
        for (final node in row) {
          node.dispose();
        }
      }
    }
    // Remove hardware keyboard listener
    if (widget.enablePhysicalKeyboard) {
      HardwareKeyboard.instance.removeHandler(_handlePhysicalKeyboard);
    }
    super.dispose();
  }

  KeyEventResult _handleKeyboardNavigation(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Handle physical keyboard submit
      if (widget.enablePhysicalKeyboard &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        _submitHandler();
        return KeyEventResult.handled;
      }

      // Handle D-pad navigation
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          _moveFocus(-1, 0);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowDown:
          final success = _moveFocus(1, 0);
          return success ? KeyEventResult.handled : KeyEventResult.ignored;
        case LogicalKeyboardKey.arrowLeft:
          _moveFocus(0, -1);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowRight:
          _moveFocus(0, 1);
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  bool _moveFocus(int deltaRow, int deltaCol) {
    final newRow = (_currentRow + deltaRow).clamp(0, _keyLayout.length - 1);
    final newCol =
        (_currentCol + deltaCol).clamp(0, _keyLayout[newRow].length - 1);

    if (newRow != _currentRow || newCol != _currentCol) {
      _currentRow = newRow;
      _currentCol = newCol;
      _focusNodes[_currentRow][_currentCol].requestFocus();
      return true;
    }

    return false;
  }

  /// Handles physical keyboard input when the virtual keyboard has focus
  bool _handlePhysicalKeyboard(KeyEvent event) {
    // Only handle if physical keyboard is enabled and widget has focus or any key has focus
    if (!widget.enablePhysicalKeyboard || !mounted) {
      return false;
    }

    // Check if the keyboard widget or any of its keys have focus
    bool hasKeyboardFocus = _keyboardFocusNode.hasFocus;

    if (widget.enableDpadNavigation && _focusNodes.isNotEmpty) {
      for (final row in _focusNodes) {
        for (final node in row) {
          if (node.hasFocus) {
            hasKeyboardFocus = true;
            break;
          }
        }
        if (hasKeyboardFocus) break;
      }
    }

    if (!hasKeyboardFocus) {
      return false;
    }

    if (event is KeyDownEvent) {
      // Handle character input
      final character = _getCharacterFromKeyEvent(event);
      if (character != null) {
        _insertHandler(character);
        return true;
      }

      // Handle special keys
      switch (event.logicalKey) {
        case LogicalKeyboardKey.backspace:
        case LogicalKeyboardKey.delete:
          _backspaceHandler();
          return true;
        case LogicalKeyboardKey.space:
          _spaceHandler();
          return true;
        case LogicalKeyboardKey.enter:
          _submitHandler();
          return true;
      }
    }

    return false;
  }

  /// Extract character from physical keyboard event
  String? _getCharacterFromKeyEvent(KeyEvent event) {
    // Handle letters and numbers
    if (event.logicalKey.keyLabel.length == 1) {
      final char = event.logicalKey.keyLabel;
      // Check if it's a valid printable character
      if (char.codeUnitAt(0) >= 32 && char.codeUnitAt(0) <= 126) {
        return char;
      }
    }

    // Handle numbers from numpad
    if (event.logicalKey == LogicalKeyboardKey.numpad0) return '0';
    if (event.logicalKey == LogicalKeyboardKey.numpad1) return '1';
    if (event.logicalKey == LogicalKeyboardKey.numpad2) return '2';
    if (event.logicalKey == LogicalKeyboardKey.numpad3) return '3';
    if (event.logicalKey == LogicalKeyboardKey.numpad4) return '4';
    if (event.logicalKey == LogicalKeyboardKey.numpad5) return '5';
    if (event.logicalKey == LogicalKeyboardKey.numpad6) return '6';
    if (event.logicalKey == LogicalKeyboardKey.numpad7) return '7';
    if (event.logicalKey == LogicalKeyboardKey.numpad8) return '8';
    if (event.logicalKey == LogicalKeyboardKey.numpad9) return '9';

    return null;
  }

  void _handleAction(action) {
    switch (action) {
      case InsertAction(value: final value):
        _insertHandler(value);
        break;
      case ClearAction():
        _clearHandler();
        break;
      case BackspaceAction():
        _backspaceHandler();
        break;
      case SpaceAction():
        _spaceHandler();
        break;
      case SubmitAction():
        _submitHandler();
        break;
      default:
    }
  }

  void onChangedCallback() => widget.onChanged?.call(effectiveController.text);

  Widget _buildRowOfWidgets(List<KeyboardKey> keys, int rowIndex) {
    return Expanded(
      child: Row(
        children: [
          for (int colIndex = 0; colIndex < keys.length; colIndex++)
            _buildKeyWidget(keys[colIndex], rowIndex, colIndex),
        ],
      ),
    );
  }

  Widget _buildKeyWidget(KeyboardKey keyWidget, int rowIndex, int colIndex) {
    final style = keyWidget.style != null && widget.buttonStyle != null
        ? keyWidget.style!.merge(widget.buttonStyle!)
        : keyWidget.style ?? widget.buttonStyle;

    // Determine focused style: key's focusedStyle > keyboard's focusedButtonStyle > default
    final focusedStyle = keyWidget.focusedStyle ?? widget.focusedButtonStyle;

    final onTap = keyWidget.onTap ?? _handleAction;

    final focusNode = widget.enableDpadNavigation
        ? _focusNodes[rowIndex][colIndex]
        : keyWidget.focusNode;

    final autofocus = widget.enableDpadNavigation
        ? (widget.autofocus && rowIndex == 0 && colIndex == 0)
        : keyWidget.autofocus;

    return KeyboardKey(
      action: keyWidget.action,
      style: style,
      focusedStyle: focusedStyle,
      onTap: onTap,
      flex: keyWidget.flex,
      key: keyWidget.key,
      focusNode: focusNode,
      canRequestFocus: keyWidget.canRequestFocus,
      autofocus: autofocus,
      child: keyWidget.child,
    );
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? TextEditingController()
        : TextEditingController.fromValue(value);
  }

  void _clearHandler() {
    effectiveController.text = "";
    onChangedCallback();
  }

  void _spaceHandler() {
    if (effectiveController.text != "") {
      effectiveController.text = "${effectiveController.text.trim()} ";
    }
    onChangedCallback();
  }

  void _submitHandler() {
    widget.onSubmit?.call();
  }

  void _backspaceHandler() {
    if (effectiveController.text.isNotEmpty) {
      effectiveController.text = effectiveController.text
          .substring(0, effectiveController.text.length - 1);
    }
    onChangedCallback();
  }

  void _insertHandler(String? text) {
    if (text != null) {
      if (widget.textTransformer != null) {
        effectiveController.text =
            effectiveController.text + widget.textTransformer!(text)!;
      } else {
        effectiveController.text = effectiveController.text + text;
      }
    }
    onChangedCallback();
  }

  final List<List<KeyboardKey>> _defaultLayout = [
    ["A", "B", "C", "D", "E", "F", "G", "1", "2", "3"]
        .map(
          (v) => KeyboardKey(
            action: InsertAction(v),
            child: Text(v),
          ),
        )
        .toList(),
    ["H", "I", "J", "K", "L", "M", "N", "4", "5", "6"]
        .map(
          (v) => KeyboardKey(
            action: InsertAction(v),
            child: Text(v),
          ),
        )
        .toList(),
    ["O", "P", "Q", "R", "S", "T", "U", "7", "8", "9"]
        .map(
          (v) => KeyboardKey(
            action: InsertAction(v),
            child: Text(v),
          ),
        )
        .toList(),
    ["V", "W", "X", "Y", "Z", "-", "'", "&", "0", "@"]
        .map(
          (v) => KeyboardKey(
            action: InsertAction(v),
            child: Text(v),
          ),
        )
        .toList(),
    [
      KeyboardKey(
        action: ClearAction(),
        child: const Text("Clear"),
      ),
      KeyboardKey(
        action: SpaceAction(),
        flex: 2,
        child: const Text("Space"),
      ),
      KeyboardKey(
        action: BackspaceAction(),
        child: const Icon(Icons.backspace),
      ),
      KeyboardKey(
        action: SubmitAction(),
        child: const Icon(Icons.keyboard_return),
      ),
    ],
  ];
}
