class ApiConstants {
  static const String baseUrl = 'http://localhost:5197/api/';

  // Auth
  static const String register = 'Auth/register';
  static const String login = 'Auth/login';

  // Materials
  static const String materials = 'Materials';
  static String materialById(int id) => 'Materials/$id';
  static const String materialUpload = 'Materials/upload';
  static String materialDownload(int id) => 'Materials/$id/download';

  // Ratings
  static const String ratings = 'Ratings';
  static String ratingsByMaterial(int id) => 'Ratings/material/$id';

  // Bookmarks
  static const String bookmarks = 'Bookmarks';
  static String bookmarkById(int materialId) => 'Bookmarks/$materialId';

  // Profile
  static const String profileMe = 'Profile/me';
  static const String profileUploads = 'Profile/my-uploads';
  static const String profileDownloads = 'Profile/my-downloads';
}
