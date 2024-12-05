import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock<IconData>(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
  super.key,
  this.items = const [],
  required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late List<T> _items;
  late Map<int, bool> _hoverStates; // To track hover state for each item

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
    _hoverStates = {}; // Initialize hover state map
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          _items.length,
              (index) {
            final item = _items[index];

            return Draggable<T>(
              data: item,
              onDragStarted: () {
                setState(() {
                  _hoverStates[index] = false; // Reset hover effect when dragging starts
                });
              },
              childWhenDragging: Container(), // Empty container while dragging
              feedback: Material(
                color: Colors.transparent,
                child: widget.builder(item), // Visual feedback
              ),
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  _hoverStates[index] = false; // Reset hover effect when drag is canceled
                });
              },
              onDragEnd: (details) {
                setState(() {
                  _hoverStates[index] = false; // Reset hover effect when drag ends
                });
              },
              child: MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _hoverStates[index] = true; // Mark as hovered
                  });
                },
                onExit: (_) {
                  setState(() {
                    _hoverStates[index] = false; // Mark as not hovered
                  });
                },
                child: DragTarget<T>(
                  builder: (context, candidateData, rejectedData) {
                    bool isHovered = _hoverStates[index] ?? false; // Get hover state
                    return GestureDetector(
                      onTap: () {},
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..scale(isHovered ? 1.3 : 1.0), // Hover effect: Scale
                        child: widget.builder(item),
                      ),
                    );
                  },
                  onAccept: (draggedItem) {
                    setState(() {
                      // Reorder the items
                      int draggedIndex = _items.indexOf(draggedItem);
                      _items.removeAt(draggedIndex);
                      _items.insert(index, draggedItem);
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
