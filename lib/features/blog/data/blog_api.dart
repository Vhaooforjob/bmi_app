import 'package:dio/dio.dart';
import 'blog_post.dart';

class BlogApi {
  final Dio dio;
  BlogApi(this.dio);

  Future<List<BlogPost>> list() async {
    final res = await dio.get('/api/document/');
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(BlogPost.fromJson).toList();
  }

  Future<List<BlogPost>> search(String title) async {
    final res = await dio.get('/api/document/search/$title');
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(BlogPost.fromJson).toList();
  }

  Future<BlogPost> detail(String id) async {
    final res = await dio.get('/api/document/$id');
    return BlogPost.fromJson(res.data as Map<String, dynamic>);
  }
}
