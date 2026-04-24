import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileManager {

  //_________________________________________________ GESTION DE CARPETAS _________________________________________________

  //Escoge un directorio por pantalla y retorna su dirección
  static Future<String?> pickDirectory() async {
    String? folder = await FilePicker.platform.getDirectoryPath(
      initialDirectory: '/storage/emulated/0/Documents',
    );
    if (folder != null) print("Carpeta seleccionada: $folder");
    return folder;
  }

  //Crea una directorio/carpeta con la ruta y nombre escogidos
  static void createDirectory(String folderPath, String folderName) {
    final dir = Directory('$folderPath/$folderName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  static Future<void> copyDirectory(String sourcePath, String destinationPath) async {
    final sourceDir = Directory(sourcePath);
    final destination = Directory(destinationPath);

    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    await for (final entity in sourceDir.list(recursive: false)) {
      if (entity is File) {
        final newPath = '$destinationPath/${entity.path.split('/').last}';
        await entity.copy(newPath);
      } else if (entity is Directory) {
        final newDirPath = '$destinationPath/${entity.path.split('/').last}';
        await copyDirectory(entity.path, newDirPath);
      }
    }
  }

  //Cambia el nombre de un directorio devolviendo su nueva ruta
  static Future<String> renameDirectory(String oldPath, String newName) async {
    final dir = Directory(oldPath);
    final path = oldPath.substring(0,oldPath.lastIndexOf('/'));
    final newPath = '$path/$newName';
    await dir.rename(newPath);
    return newPath;
  }

  //Mueve un directorio a una nueva ubicación retornando su nueva ruta
  static Future<String> moveDirectory(String oldPath, String newLocation) async {
    final dir = Directory(oldPath);
    final dirName = oldPath.split('/').last;
    final newPath = '$newLocation/$dirName';
    await dir.rename(newPath);
    return newPath;
  }

  //Elimina un directorio junto con su contenido
  static Future<void> deleteDirectory(Directory dir) async {
    await dir.delete(recursive: true);
  }

  //_________________________________________________ GESTION DE ARCHIVOS _________________________________________________

  //Selecciona por pantalla un archivo y retorna su dirección
  static Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
    } else {
      // Usuario canceló la selección
    }
  }

  //Crea un archivo con la ruta, nombre y contenido seleccionados
  static Future<void> createFile(String path, String content, String name) async {
    try {
      File file = File("$path/$name");
      await file.writeAsString(content);
      print("Archivo creado en: $path/$name");
    } catch (e) {
      print("Error al crear archivo: $e");
    }
  }

  //Renombra un archivo
  static Future<String> renameFile(String oldPath, String newName) async {
    final file = File(oldPath);
    final path = oldPath.substring(0,oldPath.lastIndexOf('/'));
    final newPath = '$path/$newName';
    await file.rename(newPath);
    return newPath;
  }

  //Escribe el contenido deseado en el archivo
  static void writeContent(String filePath, String content) {
    File(filePath).writeAsStringSync(content);
  }

  //Borra el archivo indicado
  static Future<void> deleteFile(File file) async {
    await file.delete();
  }

  //Copia una image como logo.png en la ruta indicada
  static Future<void> copyImage(File img, String path) async {
    try{
      final destination = "$path/logo.png";
      await img.copy(destination);
    }catch(e){
      print("error al copiar imagen");
    }
  }

  // _________________________________________________ PERSISTENCIA _________________________________________________

  static const _keyFavGraphs = 'favorite_graphs';
  static const _KeyGraphs = 'saved_graphs';

  //Guarda la ruta de un grafo en la persistencia
  static Future<void> saveGraphs(String path) async {
    final saves = await SharedPreferences.getInstance();
    final list = saves.getStringList(_KeyGraphs) ?? [];
    if(!list.contains(path)) list.add(path);
    await saves.setStringList(_KeyGraphs, list);
  }

  //Carga la lista de rutas de los grafos guardados
  static Future<List<String>> loadGraphs() async {
    final saves = await SharedPreferences.getInstance();
    return saves.getStringList(_KeyGraphs) ?? [];
  }

  //Elimina la ruta de un grafo de la persistencia
  static Future<void> removeGraphs(String path) async {
    final saves = await SharedPreferences.getInstance();
    final list = saves.getStringList(_KeyGraphs) ?? [];
    list.remove(path);
    await saves.setStringList(_KeyGraphs, list);
  }

  //Carga la lista de rutas de grafos favoritos
  static Future<List<String>> loadFavorites() async {
    final favs = await SharedPreferences.getInstance();
    return favs.getStringList(_keyFavGraphs) ?? [];
  }

  //Añade o elimina la ruta de un grafo de la lista de favoritos
  static Future<void> toggleFavorite(String path) async {
    final favs = await SharedPreferences.getInstance();
    final list = favs.getStringList(_keyFavGraphs) ?? [];
    if(list.contains(path)){
      list.remove(path);
    } else {
      list.add(path);
    }
    await favs.setStringList(_keyFavGraphs, list);
  }

  //Elimina la ruta de un grafo si existe en la lista de favoritos
  static Future<void> purgeFromFavorites(String f) async {
    final favorites = await FileManager.loadFavorites();
    if(favorites.contains(f)) FileManager.toggleFavorite(f);
  }

  //Guarda la fecha mas reciente en la que se accedió al archivo
  static Future<void> saveLastAccessedTime(String path) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessed_${path.split(" / ").last}", DateTime.now().toIso8601String());
  }

  //Devuelve la ultima fecha de acceso del archivo
  static Future<DateTime> getLastAccessedTime(String path) async{
    final prefs = await SharedPreferences.getInstance();
    final date = prefs.getString("accessed_${path.split(" / ").last}");
    return date != null ? DateTime.parse(date) : DateTime.fromMicrosecondsSinceEpoch(0);
  }

//IMPORTANTE __________________
//Metodo de llamada y recepción de texto con Google colab
//NOTA: la conexión con la IA será local descargando el modelo de huggingface y el código diseñado

}