import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_post.dart';

class JobStorage {
  static const String _key = 'job_posts';

  static Future<List<JobPost>> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => JobPost.fromJson(e)).toList();
  }

  static Future<void> savePosts(List<JobPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(posts.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
