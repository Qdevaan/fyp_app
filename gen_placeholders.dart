import 'dart:io';

void main() {
  final stitchDir = Directory(r'd:\FYP\fyp_app\stitch');
  final screensDir = Directory(r'd:\FYP\fyp_app\lib\screens');
  final widgetsDir = Directory(r'd:\FYP\fyp_app\lib\widgets');

  if (!screensDir.existsSync()) screensDir.createSync(recursive: true);
  if (!widgetsDir.existsSync()) widgetsDir.createSync(recursive: true);

  final existingScreens = screensDir.listSync().map((f) => f.path.split(Platform.pathSeparator).last).toList();

  for (var entity in stitchDir.listSync()) {
    if (entity is Directory) {
      final folderName = entity.path.split(Platform.pathSeparator).last;
      final nameParts = folderName.split('_');
      
      final isScreen = nameParts.contains('screen') || 
                       nameParts.contains('dashboard') || 
                       nameParts.contains('profile') || 
                       ['connections', 'search_discovery', 'session_history'].contains(folderName);
                       
      final targetDir = isScreen ? screensDir : widgetsDir;
      
      var cleanName = folderName.replaceAll('_redesign', '').replaceAll('_screen', '');
      if (cleanName.endsWith('_')) cleanName = cleanName.substring(0, cleanName.length - 1);
      
      final fileName = cleanName + (isScreen ? '_screen' : '') + '.dart';
      final filePath = '${targetDir.path}\\$fileName';
      
      if (!File(filePath).existsSync() && !existingScreens.contains(fileName)) {
        final words = cleanName.split('_');
        final className = words.map((word) => word.isNotEmpty ? word.substring(0, 1).toUpperCase() + word.substring(1) : '').join('') + (isScreen ? 'Screen' : 'Widget');
        
        final content = '''
import 'package:flutter/material.dart';

class $className extends StatelessWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('$className')),
    );
  }
}
''';
        File(filePath).writeAsStringSync(content);
        print('Created $fileName in ${isScreen ? "screens" : "widgets"}');
      }
    }
  }
}
