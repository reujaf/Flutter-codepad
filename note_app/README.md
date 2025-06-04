# VS Code Not Defteri

VS Code'a benzer arayüze sahip modern bir Android not defteri uygulaması.

## Özellikler

- VS Code benzeri karanlık tema ve kullanıcı arayüzü
- Terminal arayüzü ile gelişmiş komut sistemi
- Çeşitli medya desteği:
  - Yerel görsel ekleme
  - Kod bloğu ekleme (çeşitli dil destekleri ile)
  - Noktalı ve numaralı liste oluşturma
- Gelişmiş terminal komutları:
  - `img` - Galeriden görsel ekleme
  - `code` - Kod bloğu ekleme
  - `list` - Noktalı liste ekleme
  - `list 1` - Numaralı liste ekleme
  - `help` - Tüm komutların detaylı açıklaması
- Terminal geçmişi (yukarı/aşağı tuşlarıyla gezinme)
- Çift tıklama ile terminal açma
- Notları sekmeler halinde görüntüleme (Tüm Notlar ve Son Eklenenler)
- Uzun basarak içerikleri silme
- Otomatik olarak düzenleme tarihini kaydetme

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
- Sekmelerde gezerek tüm notları veya son eklenen notları görüntüleyebilirsiniz
- Sağ alt köşedeki + butonuna tıklayarak yeni not ekleyebilirsiniz
- Terminal açmak için:
  - Not düzenleme ekranında sağ üst köşedeki terminal ikonuna tıklayın
  - Veya not içeriği alanına çift tıklayın
- Terminal komutları ile içerik ekleyin (help komutu ile tüm komutları görebilirsiniz)
- Eklenen içerikleri silmek için üzerine uzun basın
- Sağ alt köşedeki küçük kaydet ikonuna tıklayarak notu kaydedin

## Proje Yapısı

- `lib/main.dart` - Ana uygulama giriş noktası
- `lib/theme/app_theme.dart` - VS Code teması ve renk tanımlamaları
- `lib/models/note.dart` - Not veri modeli
- `lib/models/command.dart` - Terminal komut modeli
- `lib/screens/notes_screen.dart` - Notları listeleyen ana ekran
- `lib/screens/note_detail_screen.dart` - Not ekleme ve düzenleme ekranı
- `lib/services/notes_service.dart` - Notları depolama ve alma işlemlerini yöneten servis
- `lib/widgets/terminal_widget.dart` - Terminal arayüzü
- `lib/widgets/code_block_widget.dart` - Kod bloğu görünümü
- `lib/widgets/image_widget.dart` - Görsel görünümü
- `lib/widgets/list_widget.dart` - Liste görünümü 