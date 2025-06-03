import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final Function(String) onSearchChanged;

  const SearchField({super.key, required this.onSearchChanged});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search users by name...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[200] : Colors.grey[700],
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
        ),
        onChanged: widget.onSearchChanged,
      ),
    );
  }
}