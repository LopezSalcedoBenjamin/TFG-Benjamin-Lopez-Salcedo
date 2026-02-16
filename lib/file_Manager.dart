import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileManager {
  //Plan de gestión de archivos (crear una clase para ello y tenerlo separado)
  //Crear metodo pickFolder para escoger sitio de guardado

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
  static Future<void> createFile(String path, String content) async {
    File file = File(path);
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
  static Future<void> deleteFile(File file) async {
    bool confirm = false;

    //Preguntar al usuario

    if(confirm){
      await file.delete();
    }else{
      //El usuario canceló la operación
    }
  }

  static Future<void> deleteDirectory(Directory dir) async {
    bool confirm = false;

    //Preguntar al usuario

    if(confirm){
      await dir.delete(recursive: true);
    }else{
      //El usuario canceló la operación
    }
  }

  //Metodo de creación de txt para los nodos
  //Metodo para borrar los archivos
  //Olvidar -> quitar del registro de la app, se tendria que usar pickFolder para recordar

  //IMPORTANTE __________________
  //Metodo de llamada y recepción de texto con Google colab
  //NOTA: la conexión con la IA será local descargando el modelo de huggingface y el código diseñado

  //PERSISTENCIA----------------------------------------------
  //To do: Olvidar -> quitar del registro de la app, se tendria que usar pickFolder para recordar
  //Done:  Guardar y cargar

  static Future<void> saveFolders(List<String> folders) async {
    final saves = await SharedPreferences.getInstance();
    await saves.setStringList('folders', folders);
  }

  static Future<List<String>> loadFolders() async {
    final saves = await SharedPreferences.getInstance();
    return saves.getStringList('folders') ?? [];
  }

}