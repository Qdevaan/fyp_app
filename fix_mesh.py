def modify(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        c = f.read()

    # Import MeshGradientBackground
    imp_str = "import '../widgets/glass_morphism.dart';"
    if "import '../widgets/mesh_gradient_background.dart';" not in c:
        c = c.replace(imp_str, imp_str + "\nimport '../widgets/mesh_gradient_background.dart';")

    # Replace Scaffold wrapping
    old_scaffold = '''      return Consumer<ConsultantProvider>(
        builder: (context, chat, _) {
          return Scaffold(
            key: _scaffoldKey,
            drawer: _buildDrawer(isDark, chat),'''
            
    new_scaffold = '''      return Consumer<ConsultantProvider>(
        builder: (context, chat, _) {
          return MeshGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              key: _scaffoldKey,
              drawer: _buildDrawer(isDark, chat),'''

    # Only replace if not already replaced
    if 'MeshGradientBackground(\n            child: Scaffold(' not in c:
        c = c.replace(old_scaffold, new_scaffold)

    # Adding the closing tag for MeshGradientBackground at the end
    end_str = '''          ),
        );
      },
    );
  }
}'''

    new_end_str = '''          ),
            ),
          );
        },
      );
    }
}'''

    # Wait, the end of the build method has different indentation? 
    # Let me just check the exact string at the bottom.
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(c)

modify('lib/screens/consultant_screen.dart')
