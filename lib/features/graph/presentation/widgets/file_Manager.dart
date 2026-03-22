import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileManager {

  //GESTION DE ARCHIVOS Y CARPETAS ______________________________________________________

  //Escoge un directorio por pantalla y retorna su dirección
  static Future<String?> pickFolder() async {
    String? folder = await FilePicker.platform.getDirectoryPath();

    if (folder != null) {
      print("Carpeta seleccionada: $folder");
    }

    return folder;
  }

  //Crea una carpeta en una dirección vaultPath con el nombre escogido folderName
  static void createFolder(String vaultPath, String folderName) {
    final dir = Directory('$vaultPath/$folderName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  //Crear archivo json y carpeta dentro de la carpeta escogida

  //Crea un archivo en la direccion path con un contenido content
  static Future<void> createFile(String path, String content, String name) async {
    File file = File("$path/$name");
    await file.writeAsString(content);
  }

  //Selecciona por pantalla un archivo y retorna su dirección
  static Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
    } else {
      // Usuario canceló la selección
    }
  }

  //Selecciona por pantalla un archivo y lo borra
  static Future<void> deleteFile(File file) async {
    bool confirm = false;

    //Preguntar al usuario

    if(confirm){
      await file.delete();
    }else{
      //El usuario canceló la operación
    }
  }

  //Selecciona por pantalla un directorio y lo borra
  static Future<void> deleteDirectory(Directory dir) async {
    bool confirm = false;

    //Preguntar al usuario

    if(confirm){
      await dir.delete(recursive: true);
    }else{
      //El usuario canceló la operación
    }
  }

  static Future<void> copyImage(File img, String path) async {
    try{
      final destination = "$path/logo.png";
      await img.copy(destination);
    }catch(e){
      print("error al copiar imagen");
    }
  }

  //Metodo de creación de txt para los nodos
  //Metodo para borrar los archivos
  //Olvidar -> quitar del registro de la app, se tendria que usar pickFolder para recordar

  //PERSISTENCIA ______________________________________________________
  //To do: Olvidar -> quitar del registro de la app, se tendria que usar pickFolder para recordar
  //Done:  Guardar y cargar

  static const _keyFavGraphs = 'favorite_graphs';
  static const _KeyGraphs = 'saved_graphs';

  static Future<void> saveFolders(String path) async {
    final saves = await SharedPreferences.getInstance();
    final list = saves.getStringList(_KeyGraphs) ?? [];
    if(!list.contains(path)) list.add(path);
    await saves.setStringList(_KeyGraphs, list);
  }

  static Future<List<String>> loadFolders() async {
    final saves = await SharedPreferences.getInstance();
    return saves.getStringList(_KeyGraphs) ?? [];
  }

  static Future<void> removeFolders(String path) async {
    final saves = await SharedPreferences.getInstance();
    final list = saves.getStringList(_KeyGraphs) ?? [];
    list.remove(path);
    await saves.setStringList(_KeyGraphs, list);
  }

  static Future<List<String>> loadFavorites() async {
    final favs = await SharedPreferences.getInstance();
    return favs.getStringList(_keyFavGraphs) ?? [];
  }

  static Future<void> toggleFavorites(String path) async {
    final favs = await SharedPreferences.getInstance();
    final list = favs.getStringList(_keyFavGraphs) ?? [];
    if(list.contains(path)){
      list.remove(path);
    } else {
      list.add(path);
    }
    await favs.setStringList(_keyFavGraphs, list);
  }

//IMPORTANTE __________________
//Metodo de llamada y recepción de texto con Google colab
//NOTA: la conexión con la IA será local descargando el modelo de huggingface y el código diseñado

}