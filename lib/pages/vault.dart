import 'package:flutter/material.dart';
import 'package:password_manager/auth/authentication_service.dart';
import 'package:password_manager/db/app_db.dart';
import 'package:password_manager/pages/multipage/emailstore.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final AuthService _authService = AuthService();
  final VaultDB _db = VaultDB();

  List<String> categories = [];
  bool loading = false;
  String query = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) return;
    setState(() => loading = true);
    final list = await _db.getCategories(userId: userId);
    setState(() {
      categories = list.isNotEmpty
          ? list
          : ['Email', 'Social', 'Apps', 'Website', 'Other'];
      loading = false;
    });
  }

  List<String> get filteredCategories {
    if (query.trim().isEmpty) return categories;
    final q = query.toLowerCase();
    return categories.where((c) => c.toLowerCase().contains(q)).toList();
  }

  void _createCategoryAndOpen() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Create category'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(c);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailStorePage(initialCategory: name),
                ),
              ).then((_) => _loadCategories());
            },
            child: const Text('Create & Open'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxis = (width ~/ 180).clamp(2, 4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        backgroundColor: Colors.blueGrey.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.SignOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search categories',
                ),
                onChanged: (v) => setState(() => query = v),
              ),
              const SizedBox(height: 12),
              if (loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, i) {
                      final name = filteredCategories[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EmailStorePage(initialCategory: name),
                          ),
                        ).then((_) => _loadCategories()),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blueGrey.shade100,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 6),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder,
                                size: 36,
                                color: Colors.blueGrey.shade700,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCategoryAndOpen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
