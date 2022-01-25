import 'package:flutter/material.dart';
import 'package:minesweeper/desktop/button.dart';
import 'package:minesweeper/desktop/desktop.dart';
import 'package:minesweeper/widgets/theme.dart';

class Window extends StatefulWidget {
  final Widget child;
  final String title;
  final Widget? icon;
  final Key appKey;

  const Window({
    Key? key,
    required this.child,
    required this.appKey,
    required this.title,
    this.icon,
  }) : super(key: key);

  @override
  _WindowState createState() => _WindowState();
}

class _WindowState extends State<Window> {
  Offset position = Offset.zero;
  bool focused = false;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode(
      skipTraversal: true,
      canRequestFocus: true,
    );

    focusNode.addListener(() {
      setState(() {
        focused = focusNode.hasFocus;
      });
    });
  }

  void ensureFocused() {
    if (focused) return;
    Desktop.of(context).requestFocus(widget.appKey);
    focusNode.requestFocus();
  }

  void move(Offset offset) {
    ensureFocused();
    setState(() {
      position = position.translate(offset.dx, offset.dy);
    });
  }

  void close() {
    Desktop.of(context).closeWindow(widget.appKey);
  }

  @override
  Widget build(BuildContext context) {
    var theme = CustomTheme.of(context);

    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Focus(
          autofocus: true,
          focusNode: focusNode,
          child: GestureDetector(
            onTapDown: focused ? null : (_) => ensureFocused(),
            onSecondaryTapDown: focused ? null : (_) => ensureFocused(),
            child: Container(
                decoration: BoxDecoration(
                  color: theme.fillColor,
                  border: theme.elevatedBorder,
                ),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTapDown: (_) => ensureFocused(),
                        onSecondaryTapDown: (_) => ensureFocused(),
                        onPanUpdate: (details) => move(details.delta),
                        child: Container(
                          height: 25,
                          width: 100,
                          color: focused ? theme.windowTitleColor : Colors.grey,
                          padding: EdgeInsets.all(4),
                          child: Row(
                            children: [
                              if (widget.icon != null)
                                Container(
                                  padding: EdgeInsets.only(right: 4),
                                  height: 25,
                                  child: widget.icon,
                                ),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              WinButton(
                                child: Image.asset(
                                  "assets/win/close.png",
                                  color: Colors.black87,
                                ),
                                onPressed: close,
                              )
                            ],
                          ),
                        ),
                      ),
                      IgnorePointer(
                        ignoring: !focused,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: widget.child,
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ));
  }
}
