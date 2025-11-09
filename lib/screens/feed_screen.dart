import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_post.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            "assets/feed_bg.jpg",
            fit: BoxFit.cover,
          ),
        ),

        // Semi-transparent overlay for readability
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),

        // Feed Content
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  "No shared jobs yet",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final posts = docs
                .map((d) => JobPost.fromJson(d.data() as Map<String, dynamic>))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (_, i) => _JobCard(post: posts[i]),
            );
          },
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobPost post;
  const _JobCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black45,
      color: Colors.white.withOpacity(0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Photo
          post.imageUrl.isNotEmpty
              ? AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) =>
                        progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator()),
                  ),
                )
              : Container(
                  height: 140,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.storefront, size: 48, color: Colors.grey),
                ),

          // Text Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (post.employer.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      post.employer,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                if (post.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      post.notes,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
