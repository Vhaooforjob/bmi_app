import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/blog_api.dart';
import '../data/blog_post.dart';

class BlogController extends ChangeNotifier {
  final BlogApi api;
  BlogController(this.api);

  bool loading = false;
  bool loadingMore = false;
  String? error;

  List<BlogPost> items = [];
  Timer? _debounce;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await api.list();
    } catch (e) {
      error = 'Không tải được danh sách';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (q.trim().isEmpty) {
        await load();
        return;
      }
      loading = true;
      error = null;
      notifyListeners();
      try {
        items = await api.search(q.trim());
      } catch (e) {
        error = 'Tìm kiếm thất bại';
      } finally {
        loading = false;
        notifyListeners();
      }
    });
  }
}
