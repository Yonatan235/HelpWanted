import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  XFile? _photo;

  final _title = TextEditingController();
  final _employer = TextEditingController();
  final _notes = TextEditingController();

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _photo = image);
    }
  }

  Future<void> _sharePost() async {
    // Require job title
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job Title is required.")),
      );
      return;
    }

    // Request location
    Position? pos;
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse) {
      pos = await Geolocator.getCurrentPosition();
    }

    // Upload image if present
    String imageUrl = '';
    if (_photo != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child("photos/${DateTime.now().millisecondsSinceEpoch}.jpg");

      final bytes = await _photo!.readAsBytes();
      await ref.putData(bytes);
      imageUrl = await ref.getDownloadURL();
    }

    // Save post to Firestore
    await FirebaseFirestore.instance.collection("posts").add({
      "title": _title.text.trim(),
      "employer": _employer.text.trim(),
      "notes": _notes.text.trim(),
      "imageUrl": imageUrl,
      "lat": pos?.latitude ?? 0,
      "lng": pos?.longitude ?? 0,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Reset UI
    setState(() {
      _photo = null;
      _title.clear();
      _employer.clear();
      _notes.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Shared publicly ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Photo preview
          if (_photo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? FutureBuilder(
                      future: _photo!.readAsBytes(),
                      builder: (_, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                              height: 240,
                              child: Center(child: CircularProgressIndicator()));
                        }
                        return Image.memory(snapshot.data!,
                            height: 240, fit: BoxFit.cover);
                      },
                    )
                  : Image.file(
                      File(_photo!.path),
                      height: 240,
                      fit: BoxFit.cover,
                    ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Take a photo of a 'Now Hiring' sign.",
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Take Photo"),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: "Job Title (required)",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _employer,
            decoration: const InputDecoration(
              labelText: "Employer Name (optional)",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Notes (optional)",
              hintText: "e.g., 'Ask for manager', 'Evenings available', etc.",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _sharePost,
              child: const Text("Share Publicly"),
            ),
          ),
        ],
      ),
    );
  }
}
