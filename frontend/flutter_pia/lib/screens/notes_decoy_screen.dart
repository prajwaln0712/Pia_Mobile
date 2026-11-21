import 'package:flutter/material.dart';
import 'chat_screen.dart';

/// A generic, deliberately plain notes app — the destination for Quick Exit.
/// Nothing here references this app's real branding/theme on purpose: if
/// someone glances at the screen, it should read as an ordinary notes app,
/// not anything related to CreatingWings/Pia.
///
/// The back arrow in the app bar is the real user's way back in — ordinary
/// for any notes app to have, so it isn't a suspicious "escape hatch."
class NotesDecoyScreen extends StatefulWidget {
  const NotesDecoyScreen({super.key});

  @override
  State<NotesDecoyScreen> createState() => _NotesDecoyScreenState();
}

class _NotesDecoyScreenState extends State<NotesDecoyScreen> {
  final List<String> _notes = [
    'Grocery list',
    'Meeting notes — Tuesday',
  ];

  void _addNote() {
    setState(() => _notes.insert(0, 'New note'));
  }

  void _returnToChat() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _returnToChat,
        ),
        title: const Text('Notes'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.black54),
            title: Text(_notes[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
