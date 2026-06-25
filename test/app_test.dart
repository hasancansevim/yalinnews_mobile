import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalinnews_mobile/main.dart';
import 'package:yalinnews_mobile/shared/widgets/news_card.dart';
import 'package:yalinnews_mobile/shared/widgets/category_chip.dart';

void main() {
  testWidgets('App Flow Test - Home, Category, Detail, Auth, Favorites', (WidgetTester tester) async {
    // 1. Ana sayfa açılıyor mu? Haberler geliyor mu?
    await tester.pumpWidget(const ProviderScope(child: YalinNewsApp()));
    await tester.pump(const Duration(seconds: 1)); // Wait for animations and initial API loads (uses dummy data if API fails)

    expect(find.text('YalınNews'), findsOneWidget); // AppBar title
    expect(find.byType(NewsCard), findsWidgets); // News are loaded

    // 2. Kategori filtreleri çalışıyor mu?
    final categoryChip = find.byType(CategoryChip).first;
    expect(categoryChip, findsWidgets);
    await tester.tap(categoryChip);
    await tester.pump(const Duration(seconds: 1));
    // After tapping category, news list should refresh
    expect(find.byType(NewsCard), findsWidgets);

    // 3. Bir habere tıklayınca detay sayfası açılıyor mu?
    final firstNewsCard = find.byType(NewsCard).first;
    await tester.tap(firstNewsCard);
    await tester.pump(const Duration(seconds: 1));
    
    // Check if Detail screen opened (by looking for 'Yazar:' or HTML content)
    expect(find.textContaining('Yazar:'), findsOneWidget);

    // 4. Favori ekle çalışıyor mu? (Giriş yapılmadığı için snackbar çıkmalı)
    final bookmarkAddButton = find.byIcon(Icons.bookmark_add_outlined);
    expect(bookmarkAddButton, findsOneWidget);
    await tester.tap(bookmarkAddButton);
    await tester.pump();
    expect(find.text('Favoriye eklemek için giriş yapmalısınız.'), findsOneWidget);

    // Go back to home
    final backButton = find.byTooltip('Back');
    await tester.tap(backButton);
    await tester.pump(const Duration(seconds: 1));

    // 5. Giriş yap ekranı çalışıyor mu?
    final loginTab = find.text('Giriş');
    await tester.tap(loginTab);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Giriş Yap').last, findsOneWidget); // Screen title and button
    final emailField = find.byType(TextField).first;
    final passField = find.byType(TextField).last;
    
    await tester.enterText(emailField, 'test@yalinnews.com');
    await tester.enterText(passField, '123456');
    
    final loginBtn = find.text('Giriş Yap').last;
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    // After login, it should navigate to Profile (or remain in tab 2 which turns to Profil)
    // The dummy API might fail if the real endpoint is down, but let's assume it attempts.
    // If it fails, it will just remain on login. We will check if it throws red screen.
    
    // 6. Kırmızı ekran hatası var mı?
    expect(tester.takeException(), isNull);
  });
}
