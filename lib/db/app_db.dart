import 'package:supabase_flutter/supabase_flutter.dart';
class VaultDB {
  final _client = Supabase.instance.client;
  final _table = 'vault_items';

  Future<void> createVaultItem({
    required String userId,
    required String category,
    String? label,
    String? username,
    required String password,
  }) async {
    await _client.from(_table).insert({
      'user_id': userId,
      'category': category,
      'label': label,
      'username': username,
      'password': password,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getItemsByCategory({
    required String userId,
    required String category,
  }) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('category', category)
        .order('created_at', ascending: false);
    return (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  
  Future<List<String>> getCategories({
    required String userId,
  }) async {
    final res = await _client.from(_table).select('category').eq('user_id', userId);
    final list = (res as List).map((e) => Map<String, dynamic>.from(e as Map))
        .map((m) => (m['category'] ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    return list;
  }

  Future<void> updateVaultItem({
    required int id,
    String? label,
    String? username,
    String? password,
  }) async {
    final data = <String, dynamic>{};
    if (label != null) data['label'] = label;
    if (username != null) data['username'] = username;
    if (password != null) data['password'] = password;
    if (data.isEmpty) return;
    await _client.from(_table).update(data).eq('id', id);
  }

  Future<void> deleteVaultItem(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
