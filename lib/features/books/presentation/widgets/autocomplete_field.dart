import 'package:flutter/material.dart';

/// A text field with autocomplete suggestions
class AutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final List<String> suggestions;
  final String? Function(String?)? validator;
  final int maxLines;

  const AutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.suggestions,
    this.hint,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        // Get the last word being typed (after the last comma)
        final text = textEditingValue.text;
        final lastCommaIndex = text.lastIndexOf(',');
        final currentWord = lastCommaIndex == -1
            ? text.trim().toLowerCase()
            : text.substring(lastCommaIndex + 1).trim().toLowerCase();

        if (currentWord.isEmpty) {
          return const Iterable<String>.empty();
        }

        return suggestions.where((option) =>
            option.toLowerCase().contains(currentWord) &&
            !text.toLowerCase().contains(option.toLowerCase()));
      },
      onSelected: (selection) {
        final text = controller.text;
        final lastCommaIndex = text.lastIndexOf(',');

        if (lastCommaIndex == -1) {
          controller.text = selection;
        } else {
          // Replace only the part after the last comma
          controller.text = '${text.substring(0, lastCommaIndex + 1)} $selection';
        }

        // Move cursor to end
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        // Sync the controllers
        if (textController.text != controller.text) {
          textController.text = controller.text;
        }
        controller.addListener(() {
          if (textController.text != controller.text) {
            textController.text = controller.text;
          }
        });

        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            alignLabelWithHint: maxLines > 1,
          ),
          validator: validator,
          maxLines: maxLines,
          onChanged: (value) {
            controller.text = value;
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A chip-based input field for multi-select values with suggestions
class ChipInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final List<String> suggestions;

  const ChipInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.suggestions,
    this.hint,
  });

  @override
  State<ChipInputField> createState() => _ChipInputFieldState();
}

class _ChipInputFieldState extends State<ChipInputField> {
  late List<String> _selectedItems;
  final _focusNode = FocusNode();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parseControllerText();
    widget.controller.addListener(_parseControllerText);
  }

  void _parseControllerText() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      _selectedItems = [];
    } else {
      _selectedItems = text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (mounted) setState(() {});
  }

  void _updateController() {
    widget.controller.text = _selectedItems.join(', ');
  }

  void _addItem(String item) {
    if (item.isNotEmpty && !_selectedItems.contains(item)) {
      setState(() {
        _selectedItems.add(item);
      });
      _updateController();
    }
    _textController.clear();
  }

  void _removeItem(String item) {
    setState(() {
      _selectedItems.remove(item);
    });
    _updateController();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_parseControllerText);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter suggestions to exclude already selected items
    final availableSuggestions = widget.suggestions
        .where((s) => !_selectedItems.contains(s))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips display
        if (_selectedItems.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedItems.map((item) {
              return Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeItem(item),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],

        // Autocomplete input
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              // Show all available suggestions when field is focused but empty
              return availableSuggestions.take(5);
            }
            final query = textEditingValue.text.toLowerCase();
            return availableSuggestions
                .where((s) => s.toLowerCase().contains(query))
                .take(10);
          },
          onSelected: (selection) {
            _addItem(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint ?? 'Escribe para buscar...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      _addItem(controller.text.trim());
                      controller.clear();
                    }
                  },
                ),
              ),
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addItem(value.trim());
                  controller.clear();
                }
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(
                          option,
                          style: theme.textTheme.bodyMedium,
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
