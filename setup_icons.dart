import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> downloadAndSetupIcons() async {
  try {
    print('Downloading logo from Supabase...');

    // Download logo from URL
    final response = await http.get(
      Uri.parse(
        'https://jokvxdrxswytjjhxuhvk.supabase.co/storage/v1/object/public/challenges/logo.png',
      ),
    );

    if (response.statusCode == 200) {
      print('Logo downloaded successfully');

      // Create directories if they don't exist
      await Directory('web/icons').create(recursive: true);
      await Directory('assets').create(recursive: true);

      // Save logo to web/favicon.png (for web icon)
      final webFavicon = File('web/favicon.png');
      await webFavicon.writeAsBytes(response.bodyBytes);
      print('Web favicon saved to web/favicon.png');

      // Save logo to web/icons/Icon-192.png (for PWA)
      final webIcon192 = File('web/icons/Icon-192.png');
      await webIcon192.writeAsBytes(response.bodyBytes);
      print('Web icon saved to web/icons/Icon-192.png');

      // Save logo to web/icons/Icon-512.png (for PWA)
      final webIcon512 = File('web/icons/Icon-512.png');
      await webIcon512.writeAsBytes(response.bodyBytes);
      print('Web icon saved to web/icons/Icon-512.png');

      // Save logo to assets for app icon generation
      final appIcon = File('assets/app_icon.png');
      await appIcon.writeAsBytes(response.bodyBytes);
      print('App icon saved to assets/app_icon.png');

      print('\nSetup completed! Now run:');
      print('1. flutter pub get');
      print('2. dart run flutter_launcher_icons:main (for mobile app icons)');
      print('3. flutter build web (to rebuild web with new icons)');
    } else {
      print('Failed to download logo: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

void main() async {
  await downloadAndSetupIcons();
}
