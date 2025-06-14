//
//  WordManager.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import Foundation

class WordManager: ObservableObject {
    
    // Türkçe kelime listesi - gerçek uygulamada JSON dosyasından yüklenecek
    private let turkceKelimeler5Harf = [
        "ABONE", "ACELE", "ADRES", "AGAÇ", "AHLAK", "AKTÖR", "ALARM", "ALÇAK",
        "ALKOL", "ALTIN", "AMBER", "ANKET", "ANTEP", "ARABA", "ARENA", "ASKER",
        "ASLAN", "ATLAS", "AVUÇ", "AYRAN", "BADEM", "BAHÇE", "BAKIR", "BALIK",
        "BALON", "BAMBU", "BANKA", "BARUT", "BAŞAK", "BAYAR", "BEBEK", "BEĞEN",
        "BELGE", "BEYIN", "BILGI", "BINME", "BIZON", "BOĞAZ", "BOMBA", "BOYUT",
        "BUGÜN", "BULUT", "BURMA", "CADDE", "CAHIL", "CAZIP", "ÇELIK", "ÇEVRE",
        "ÇIÇEK", "ÇINAR", "ÇILEK", "ÇORAP", "DAIRE", "DALGA", "DAMLA", "DEFTER",
        "DERGI", "DIGER", "DIKEY", "DILEK", "DOĞAL", "DRAMA", "DÜNYA", "EKRAN",
        "ELMAS", "EMLEK", "ENDIK", "ESMER", "FAKAT", "FARUK", "FENER", "FERDI",
        "FIKIR", "FILIZ", "FINCAN", "GARAJ", "GELIN", "GEMI", "GERÇEK", "GIRDI",
        "GÖLGE", "GRUBA", "GÜLER", "GÜNEŞ", "GÜVEN", "HABER", "HAFTA", "HAKİM",
        "HAYAL", "HEMEN", "HESAP", "HIZLI", "HIÇBIR", "IKLAN", "IMKAN", "INSAN",
        "ISLEM", "KALBI", "KALEM", "KAMP", "KAPAK", "KARAR", "KARGO", "KATIN",
        "KAYIT", "KEMER", "KERPE", "KETON", "KIRIM", "KITAP", "KIZIL", "KOLEJ",
        "KÖMÜR", "KÖPEK", "KÖPRÜ", "KURUM", "KÜTÜK", "LAHZA", "LIDER", "LIMAN",
        "MADDE", "MAĞRA", "MAKAM", "MAKUL", "MASAL", "MEDET", "METAL", "MEYVE",
        "MINIK", "MIRAS", "MURAT", "MÜDÜR", "NEDEN", "NIYET", "NOKTA", "NUMARA",
        "OCAK", "ODUN", "OLGUN", "ONLAR", "OPERA", "ORGAN", "OYUNU", "ÖZGÜR",
        "PARTI", "PASTA", "PATIK", "PAZAR", "PEMBE", "PERUK", "PILOT", "PROJE",
        "RADYO", "RAPOR", "REKLA", "RENK", "RISALE", "ROBOT", "ROMAN", "RUTIN",
        "SAAT", "SAFRA", "SAKAL", "SALON", "SANAT", "SEFER", "SEVGI", "SILAH",
        "SINIF", "SIYAH", "SORUN", "SPOR", "SÜPER", "ŞAHIN", "ŞEKER", "ŞEREF",
        "ŞIRKET", "TABLO", "TARIH", "TAŞIT", "TEKNE", "TEMEL", "TERZI", "TIYAT",
        "TOPLUM", "TUTAR", "TÜRKÜ", "UÇUŞ", "UMUT", "USTA", "UYGUN", "UZMAN",
        "VAGON", "VAKIT", "VATAN", "VEREM", "VIDEO", "VILLA", "VURUŞ", "YAKMA",
        "YAKIN", "YALAN", "YANIK", "YARIS", "YATAK", "YAZAR", "YEMEK", "YENGE",
        "YETER", "YOĞUN", "ZAFER", "ZAMAN", "ZEMIN", "ZIYAR", "ZORUN"
    ]
    
    func getRandomWord() -> String {
        return turkceKelimeler5Harf.randomElement() ?? "ELMAS"
    }
    
    func isValidWord(_ word: String) -> Bool {
        let uppercasedWord = word.uppercased()
        return turkceKelimeler5Harf.contains(uppercasedWord)
    }
    
    func getAllWords() -> [String] {
        return turkceKelimeler5Harf
    }
    
    // JSON dosyasından kelime yükleme (gelecekte kullanılacak)
    func loadWordsFromJSON() {
        guard let url = Bundle.main.url(forResource: "turkce_kelimeler", withExtension: "json") else {
            print("JSON dosyası bulunamadı")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([String].self, from: data)
            // Kelimeleri kullan
        } catch {
            print("JSON yükleme hatası: \(error)")
        }
    }
}