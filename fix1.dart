import 'dart:io';

void main() {
  final file = File('lib/screens/consultant_screen.dart');
  String content = file.readAsStringSync().replaceAll('\r\n', '\n');

  // Add MeshGradientBackground
  final scaffoldOld = '''    return Consumer<ConsultantProvider>(
      builder: (context, chat, _) {
        return Scaffold(
          key: _scaffoldKey,''';
  final scaffoldNew = '''    return Consumer<ConsultantProvider>(
      builder: (context, chat, _) {
        return MeshGradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,''';
  if (content.contains(scaffoldOld)) {
    content = content.replaceAll(scaffoldOld, scaffoldNew);
    print("Wrapped Scaffold");
  } else {
    print("Scaffold string not found");
  }

  final endOld = '''                ),
              ],
            ),
          ),
        );
      },
    );
  }
}''';
  final endNew = '''                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}''';
  if (content.contains(endOld)) {
    content = content.replaceAll(endOld, endNew);
    print("Closed MeshGradientBackground");
  } else {
    print("End old not found");
  }
  
  file.writeAsStringSync(content);
}
