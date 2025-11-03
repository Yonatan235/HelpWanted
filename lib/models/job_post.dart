class JobPost {
  final String title;
  final String employer;
  final String notes;
  final String? imagePath; 
  final double lat;
  final double lng;

  JobPost({
    required this.title,
    required this.employer,
    required this.notes,
    required this.imagePath,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'employer': employer,
        'notes': notes,
        'imagePath': imagePath,
        'lat': lat,
        'lng': lng,
      };

  static JobPost fromJson(Map<String, dynamic> json) => JobPost(
        title: json['title'],
        employer: json['employer'],
        notes: json['notes'],
        imagePath: json['imagePath'],
        lat: json['lat'],
        lng: json['lng'],
      );
}
