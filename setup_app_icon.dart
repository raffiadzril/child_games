import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> downloadAndSetupIcon() async {
  try {
    print('📱 Downloading logo for app icon...');
    
    // Download logo from Supabase
    final response = await http.get(Uri.parse(
        'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/challenges/logo.png'));
    
    if (response.statusCode == 200) {
      // Create assets directory if it doesn't exist
      final assetsDir = Directory('assets');
      if (!await assetsDir.exists()) {
        await assetsDir.create();
      }
      
      // Save logo as app_icon.png
      final iconFile = File('assets/app_icon.png');
      await iconFile.writeAsBytes(response.bodyBytes);
      
      print('✅ Logo downloaded successfully to assets/app_icon.png');
      print('');
      print('🔧 Next steps:');
      print('1. Run: flutter pub get');
      print('2. Run: flutter pub run flutter_launcher_icons:main');
      print('3. Rebuild your APK');
      print('');
      print('📱 This will generate:');
      print('- Android launcher icons');
      print('- iOS app icons');  
      print('- Web favicon');
      
    } else {
      print('❌ Failed to download logo: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error downloading logo: $e');
  }
}

void main() async {
  await downloadAndSetupIcon();
}
