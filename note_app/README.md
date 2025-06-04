# Note App

Basit bir not defteri uygulaması.

## Özellikler

- Not ekleme
- Not düzenleme
- Not silme
- Notları listeleme
- Notların yerel depolanması

## Kurulum

1. Flutter'ı yükleyin: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
2. Depoyu klonlayın
3. Bağımlılıkları yükleyin:
   ```
   flutter pub get
   ```
4. Uygulamayı çalıştırın:
   ```
   flutter run
   ```

## Kullanım

- Ana ekranda tüm notları görebilirsiniz
- Sağ alt köşedeki + butonuna tıklayarak yeni not ekleyebilirsiniz
- Bir nota tıklayarak detaylarını görüntüleyebilir ve düzenleyebilirsiniz
- Bir notu soldan sağa kaydırarak silebilirsiniz

## Yapı

- `lib/main.dart` - Ana uygulama giriş noktası
- `lib/models/note.dart` - Not veri modeli
- `lib/screens/notes_screen.dart` - Notları listeleyen ana ekran
- `lib/screens/note_detail_screen.dart` - Not ekleme ve düzenleme ekranı
- `lib/services/notes_service.dart` - Notları depolama ve alma işlemlerini yöneten servis 