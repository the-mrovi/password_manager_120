import 'package:flutter/material.dart';
import 'package:password_manager/db/app_db.dart';
import 'package:password_manager/auth/authentication_service.dart';

class EmailStorePage extends StatefulWidget {
  final String? initialCategory;
  const EmailStorePage({super.key, this.initialCategory});

  @override
  State<EmailStorePage> createState() => _EmailStorePageState();
}

class _EmailStorePageState extends State<EmailStorePage> {
  final VaultDB _db = VaultDB();
  final AuthService _auth = AuthService();

  
  final labelController = TextEditingController();
  final accountController = TextEditingController();
  final passwordController = TextEditingController();
  final notesController = TextEditingController();

  
  late final String currentCategory;
  List<Map<String, dynamic>> items = [];
  bool loading = false;
  final Set<int> visiblePasswords = {};

  @override
  void initState() {
    super.initState();
  currentCategory = (widget.initialCategory ?? 'Other').toLowerCase();
    _load();
  }

  Future<void> _load() async {
    final userId = _auth.getCurrentUserId();
    if (userId == null) return;
    setState(() => loading = true);
  final categoryKey = currentCategory;
  items = await _db.getItemsByCategory(userId: userId, category: categoryKey);
    setState(() => loading = false);
  }

  void _showItemModal({Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    labelController.text = existing?['label'] ?? '';
    accountController.text = existing?['username'] ?? '';
    passwordController.text = existing?['password'] ?? '';
    notesController.text = existing?['notes'] ?? '';
    bool hide = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          final bottom = MediaQuery.of(context).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(bottom: bottom, left: 20, right: 20, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isEdit ? 'Edit item' : 'Add item', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: labelController, decoration: const InputDecoration(label: Text('Name / Label'))),
                const SizedBox(height: 8),
                TextField(controller: accountController, decoration: const InputDecoration(label: Text('Email / Username / Phone'))),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: hide,
                  decoration: InputDecoration(
                    label: const Text('Password'),
                    suffixIcon: IconButton(
                      icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setModalState(() => hide = !hide),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(controller: notesController, decoration: const InputDecoration(label: Text('Additional details (optional)'))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                      labelController.clear();
                      accountController.clear();
                      passwordController.clear();
                      notesController.clear();
                    }, child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final userId = _auth.getCurrentUserId();
                        if (userId == null) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not signed in')));
                          return;
                        }
                        final label = labelController.text.trim();
                        final account = accountController.text.trim();
                        final pass = passwordController.text;
                        final categoryKey = currentCategory;

                        try {
                          if (isEdit) {
                            final id = existing['id'] as int;
                            await _db.updateVaultItem(id: id, label: label, username: account, password: pass);
                          } else {
                            await _db.createVaultItem(userId: userId, category: categoryKey, label: label, username: account, password: pass);
                          }
                          if (mounted) {
                            Navigator.pop(context);
                            labelController.clear();
                            accountController.clear();
                            passwordController.clear();
                            notesController.clear();
                            await _load();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Updated' : 'Saved')));
                          }
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _db.deleteVaultItem(id);
      if (mounted) {
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    labelController.dispose();
    accountController.dispose();
    passwordController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Vault - ${currentCategory[0].toUpperCase()}${currentCategory.substring(1)}'),
      ),
      body: Column(
        children: [
          const SizedBox.shrink(),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(child: Text('No items in "${currentCategory}"'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        itemBuilder: (context, idx) {
                          final note = items[idx];
                          final id = note['id'] as int;
                          final label = (note['label'] ?? '').toString();
                          final account = (note['username'] ?? '').toString();
                          final password = (note['password'] ?? '').toString();
                          final details = (note['notes'] ?? '').toString();
                          final visible = visiblePasswords.contains(id);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(label.isNotEmpty ? label : '(no label)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                      Row(children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                          onPressed: () => _showItemModal(existing: note),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          onPressed: () => _deleteItem(id),
                                        ),
                                      ])
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(account, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(visible ? password : '•' * (password.length.clamp(4, 12)), style: const TextStyle(letterSpacing: 2))),
                                      IconButton(
                                        icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                                        onPressed: () {
                                          setState(() {
                                            if (visible) visiblePasswords.remove(id); else visiblePasswords.add(id);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  if (details.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(details, style: TextStyle(color: Colors.grey.shade700)),
                                  ]
                                ],
                              ),
                            ),
                          );
                        }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemModal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
