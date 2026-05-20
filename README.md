# TechTrend Radar — iOS

SwiftUI native iOS uygulaması. Aynı backend API'yi kullanır.

## Gereksinimler

- macOS 14+ (Sonoma)
- Xcode 16+
- iOS 17+ hedef
- Apple Developer hesabı (App Store için)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Kurulum (Mac'te)

```bash
# 1. XcodeGen kur
brew install xcodegen

# 2. Proje dosyasını oluştur
cd ios/
xcodegen generate

# 3. Xcode'da aç
open TechTrendRadar.xcodeproj
```

## Xcode Ayarları

1. **Signing & Capabilities** → Team ID gir (Apple Developer hesabından)
2. **Bundle ID**: `com.techtrend.radar` (değiştirmek istersen `project.yml`'de güncelle)
3. **API URL**: Uygulama içi Ayarlar ekranından yapılandırılır

## API URL Yapılandırması

Uygulama açılışında Ayarlar → API Bağlantısı ekranından backend URL'sini değiştirebilirsin.

Kalıcı bir URL için [Railway](https://railway.app) veya [Render](https://render.com) kullan.

## App Store'a Yükleme

1. Xcode → Product → Archive
2. Organizer → Distribute App → App Store Connect
3. [App Store Connect](https://appstoreconnect.apple.com) → Yeni uygulama oluştur
4. Gerekli meta verileri doldur:
   - **Kategori**: Finance veya Business
   - **Ekran görüntüleri**: iPhone 6.9" (en az 3 ekran)
   - **Açıklama**: Türkçe ve İngilizce
   - **Anahtar kelimeler**: tech, stocks, trends, finance
5. Review'a gönder (~24-48 saat)

## Proje Yapısı

```
ios/
├── project.yml                    ← XcodeGen config
└── TechTrendRadar/
    ├── TechTrendRadarApp.swift    ← Entry point
    ├── ContentView.swift          ← TabView
    ├── Models/
    │   └── Models.swift           ← Codable veri modelleri
    ├── Services/
    │   └── APIService.swift       ← URLSession + caching
    ├── ViewModels/
    │   ├── CategoriesViewModel.swift
    │   ├── StockDetailViewModel.swift
    │   └── TrendsViewModel.swift
    ├── Views/
    │   ├── Design/
    │   │   └── DesignSystem.swift ← Renkler, tipografi, glass card
    │   ├── Categories/
    │   │   ├── CategoriesView.swift
    │   │   └── CategoryDetailView.swift
    │   ├── Stocks/
    │   │   ├── StockDetailView.swift
    │   │   ├── StockChartView.swift
    │   │   └── StockMetricsView.swift
    │   ├── Trends/
    │   │   └── TrendsView.swift
    │   └── Settings/
    │       └── SettingsView.swift
    ├── Assets.xcassets/
    └── PrivacyInfo.xcprivacy      ← App Store Privacy gereği
```

## App Icon

`Assets.xcassets/AppIcon.appiconset/` klasörüne **1024×1024 PNG** ekle.
Canva, Figma veya SF Symbols'ten üretebilirsin. Dark background (#0F172A) + sky blue (#38BDF8) hexagon önerilir.

## Performans Notları

- `@Observable` macro → ObservableObject'e göre daha az re-render
- `LazyVStack` → uzun listeler için lazy loading
- `URLCache` → 20 MB memory + 100 MB disk cache
- Task cancellation → ekrandan çıkınca ağ istekleri iptal edilir
- Swift Charts `AreaMark + LineMark` → native GPU rendering
