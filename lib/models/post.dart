class Post {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final List<FilePostDetail>? files;

  Post({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.files,
  });
  @override
  String toString() {
    return 'Post(title: $title, body: $body, imageUrl: $imageUrl, files: $files)';
  }

  // Método para convertir un objeto JSON a Post
  factory Post.fromJson(Map<String, dynamic> json) {
    List<dynamic>? filesJson = json['files'];
    List<FilePostDetail>? filesList;
    if (filesJson != null && filesJson.isNotEmpty) {
      filesList = filesJson
          .map((fileJson) => FilePostDetail.fromJson(fileJson))
          .toList();
    }
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      imageUrl: json['image'],
      userId: json['user_id'],
      userName: json['user'][
          'name'], // Asumimos que el backend envía el nombre del usuario dentro de un objeto 'user'.
      createdAt: DateTime.parse(
          json['created_at']), // Convertimos la fecha de creación a DateTime.
      files: filesList,
    );
  }

  // Método para convertir un objeto Post a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image': imageUrl,
      'user_id': userId,
      'files': files?.map((file) => file.toJson()).toList(),
      // No necesitamos enviar el 'userName' y 'createdAt' al backend a menos que lo requieras para alguna operación en particular.
    };
  }
}

class FilePostDetail {
  final String name;
  final String url;
  final String? type; // Puede ser nulo, así que usamos String?
  final int? size; // Puede ser nulo, así que usamos int?

  FilePostDetail({
    required this.name,
    required this.url,
    this.type, // No es necesario usar "required" porque puede ser nulo
    this.size,
  });

  @override
  String toString() {
    return 'File(name: $name, url: $url)';
  }

  factory FilePostDetail.fromJson(Map<String, dynamic> json) {
    return FilePostDetail(
      name: json['name'],
      url: json['path'],
      type: json['type'],
      size: json['size'] != null
          ? int.parse(json['size'].toString())
          : null, // Convertimos a int solo si no es nulo
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'path': url, 'type': type, 'size': size};
  }
}
