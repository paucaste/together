import 'package:flutter/material.dart';
import 'package:togethertest/models/api_response.dart';
import 'package:togethertest/models/post.dart';
import 'package:togethertest/screens/organitzacio/create_post_screen.dart';
import 'package:togethertest/screens/organitzacio/edit_post_screen.dart';
import 'package:togethertest/screens/organitzacio/post_details_screen.dart';
import 'package:togethertest/services/posts_service.dart';
import 'package:togethertest/utils/post_utils.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  fetchPosts() async {
    ApiResponse apiResponse = await getMyPosts();
    if (apiResponse.error == null) {
      setState(() {
        this.posts = apiResponse.data as List<Post>;
        isLoading = false;
      });
    } else {
      // Handle error
      print('Error: ${apiResponse.error}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    await fetchPosts();
  }

  void _deletePostAndRefresh(int postId, int postIndex) async {
    var response = await deletePost(postId);
    if (response.error == null) {
      // El post se eliminó correctamente. Refresca la lista local.
      setState(() {
        posts.removeAt(postIndex);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post eliminado exitosamente')));
    } else {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al eliminar el post')));
    }
  }

  // Función para calcular la diferencia de días
  String daysSinceCreation(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    final int days = difference.inDays;
    final int months = days ~/
        30; // Esto divide y redondea hacia abajo para obtener la cantidad de meses completos
    final int years = months ~/ 12;

    if (years > 0) {
      return "${years}y";
    } else if (months > 0) {
      return "${months}m";
    } else {
      return "${days}d";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width -
                    16, // Restamos los 8.0 de margen en ambos lados
              ),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("¿Tiene un post importante?"),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors
                                  .deepPurple), // Cambia el color de fondo aquí
                        ),
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CreatePostScreen(),
                            ),
                          );
                          if (result != null) {
                            _refreshPosts();
                          }
                        },
                        child: Text("Crear post"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshPosts,
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PostDetails(
                                  postId: posts[index].id,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        posts[index].userName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 2.0,
                                      ),
                                      child: Text(
                                        daysSinceCreation(
                                            posts[index].createdAt),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        posts[index].title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      child: Text(
                                        truncateText(posts[index].body, 150),
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 4.0,
                                  right: 4.0,
                                  child: postMenuButton(
                                    // Para borrar:
                                    () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Confirmar eliminación'),
                                          content: Text(
                                              '¿Estás seguro de que deseas eliminar este post?'),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancelar'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                              child: Text('Eliminar'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Cierra el cuadro de diálogo
                                                _deletePostAndRefresh(
                                                    posts[index].id, index);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    // Para editar:
                                    () {
                                      // Código para editar
                                      print('Opción editar seleccionada');
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditPostScreen(
                                            id: posts[index].id,
                                            title: posts[index].title,
                                            description: posts[index].body,
                                            imageUrl: posts[index]
                                                .imageUrl, // Asegúrate de que tu objeto post tiene este campo o ajústalo según tus necesidades
                                            // Añade otros campos si los hay
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

String truncateText(String text, int truncateAfter) {
  String textWithoutNewlines =
      text.replaceAll('\n', ' '); // Reemplazar saltos de línea con espacios

  return textWithoutNewlines.length <= truncateAfter
      ? textWithoutNewlines
      : textWithoutNewlines.substring(0, truncateAfter) + '...';
}
