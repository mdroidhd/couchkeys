import 'package:couchkeys/couchkeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// This widget is used to define the layout of the [Couchkeys] keyboard.
/// The layout is defined as a list of rows on [Couchkeys.customLayout] property, where each row is a list of [KeyboardKey] widgets.
///
/// The widget expects a [child] to display on the key, and an [action] to perform when the key is pressed. The [action] can be one of the following:
/// - [InsertAction(String)]
/// - [BackspaceAction]
/// - [SpaceAction]
/// - [ClearAction]
class KeyboardKey extends StatefulWidget {
  /// The label to display on the key.
  final Widget? child;

  /// The action to perform when the key is pressed.
  /// Takes a [KeyboardAction] as an argument, which is one of the following:
  /// - [InsertAction(String)]
  /// - [BackspaceAction]
  /// - [SpaceAction]
  /// - [ClearAction]
  final KeyboardAction? action;

  /// Callback triggered on key press to set custom behavior. Not required if [action] is set.
  final ValueSetter<KeyboardAction?>? onTap;

  /// Callback triggered on long key press.
  final ValueSetter<KeyboardAction?>? onLongPress;

  /// Controls how the space in a row is distributed among the keys.
  /// A value of 2 will make the key occupy twice the width of a key with a value of 1.
  ///
  /// Default value is 1.
  final int flex;

  /// Customizes the appearance of the key.
  /// If parent [Couchkeys] has a [buttonStyle], it will merge with this style, overriding any duplicate properties.
  final ButtonStyle? style;

  /// Customizes the appearance of the key when it's focused (for D-pad navigation).
  /// If not provided, a default blue border will be used.
  final ButtonStyle? focusedStyle;

  /// The space around the key.
  ///
  /// Default value is 2.
  final double gap;

  /// Focus node for D-pad navigation.
  final FocusNode? focusNode;

  /// Whether this key can be focused (for D-pad navigation).
  final bool canRequestFocus;

  /// Whether this key should autofocus on widget creation.
  final bool autofocus;

  /// Creates a new instance of [KeyboardKey]. [child] must be specified.
  /// Example:
  /// ```dart
  /// KeyboardKey(
  ///   action: InsertAction('a'),
  ///   child: const Text('A'),
  ///   focusedStyle: ButtonStyle(
  ///     side: MaterialStateProperty.all(BorderSide(color: Colors.red, width: 3)),
  ///   ),
  /// )
  /// ```
  const KeyboardKey({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.action,
    this.flex = 1,
    this.style,
    this.focusedStyle,
    this.gap = 2,
    this.focusNode,
    this.canRequestFocus = true,
    this.autofocus = false,
  });

  @override
  State<KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<KeyboardKey> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: SizedBox.expand(
        child: Padding(
          padding: EdgeInsets.all(widget.gap),
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: widget.canRequestFocus,
            autofocus: widget.autofocus,
            onKeyEvent: _handleKeyEvent,
            child: Builder(
              builder: (context) {
                ButtonStyle? buttonStyle;

                if (_isFocused) {
                  // Use custom focused style if provided, otherwise default focused style
                  if (widget.focusedStyle != null) {
                    buttonStyle = widget.focusedStyle;
                  } else {
                    // Default focused style with blue border
                    buttonStyle =
                        (widget.style ?? const ButtonStyle()).copyWith(
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Colors.blue, width: 2),
                      ),
                    );
                  }
                } else {
                  buttonStyle = widget.style;
                }

                return TextButton(
                  style: buttonStyle,
                  onPressed: _onTap,
                  onLongPress: _onLongPress,
                  child: widget.child ?? const SizedBox.shrink(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // Handle Enter/Select key press (typical for D-pad center button)
      if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _onTap();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _onTap() {
    widget.onTap?.call(widget.action);
  }

  void _onLongPress() {
    widget.onLongPress?.call(widget.action);
  }
}
