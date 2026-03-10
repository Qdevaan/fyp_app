import 'dart:io';

void main() {
  final file = File('lib/screens/consultant_screen.dart');
  var lines = file.readAsLinesSync();
  // insert missing parenthesis for Expanded
  lines.insert(857, '                        ),'); 
  file.writeAsStringSync(lines.join('\n'));
}
