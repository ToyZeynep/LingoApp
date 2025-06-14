//
//  WordManager.swift
//  LingoApp
//
//  Created by Zeynep Toy on 14.06.2025.
//


import Foundation

class WordManager: ObservableObject {
    
    // 4 harfli Türkçe kelimeler
    private let turkceKelimeler4Harf = [
        "ADET", "AĞAÇ", "ALAN", "ALEV", "ALIN", "ALTI", "ANNE", "ARZU",
        "AYAK", "AYAR", "BABA", "BACA", "BAKI", "BAŞ", "BEKA", "BELA",
        "BEST", "BILE", "BIÇE", "BODY", "BOYU", "BUDA", "CAFE", "CAMI",
        "CEZA", "DAHA", "DAMA", "DANE", "DEDE", "DELI", "DENE", "DERS",
        "DEVA", "DIZI", "DOĞA", "DOLU", "DOST", "DRAM", "DURU", "DÜŞE",
        "EKMK", "ELMA", "EMRE", "ESER", "EVET", "EVIM", "FACE", "FARE",
        "FARK", "FENA", "FETE", "FILM", "GECE", "GEMI", "GENÇ", "GEZI",
        "GIDA", "GIGI", "GIYIM", "GOLF", "GÖÇE", "GÖZÜ", "GRUP", "GÜLÜ",
        "HACI", "HALK", "HAMR", "HANE", "HARC", "HAVA", "HAYE", "HIZM",
        "IBEN", "ICAT", "IDAL", "IHYA", "IMAL", "IMAN", "IPEK", "IŞIK",
        "JEEP", "JULI", "KABA", "KAFA", "KAĞT", "KALE", "KAMP", "KAPI",
        "KARA", "KART", "KASE", "KATI", "KAYA", "KEDI", "KENT", "KESE",
        "KILO", "KIRA", "KITA", "KOKU", "KOLA", "KONU", "KOVA", "KÖYÜ",
        "KUTU", "KÜTÜ", "LALE", "LAMA", "LAPA", "LEKE", "LIMAN", "LOBI",
        "MAMA", "MARS", "MASA", "MENU", "META", "MINI", "MODA", "MOLA",
        "MÜZE", "NANE", "NARA", "NASA", "NERE", "NOEL", "NOVE", "OLTA",
        "OYUN", "ÖDÜL", "ÖĞLE", "ÖLÇÜ", "ÖMER", "ÖNCE", "ÖYKÜ", "PARA",
        "PARK", "PARTI", "PASTA", "PEDE", "PIKA", "POLO", "PULS", "QUIZ",
        "RADL", "RAĞM", "RAKS", "RAMP", "RANT", "RAYO", "REEL", "RIZA",
        "SAAT", "SADE", "SAGA", "SAIK", "SAKI", "SALI", "SAMA", "SANA",
        "SARA", "SARI", "SEFA", "SERA", "SESI", "SEVI", "SEZA", "SIKI",
        "SILA", "SINA", "SIRA", "SOBA", "SODA", "SONA", "SORU", "SOYA",
        "ŞAIR", "ŞAKA", "ŞANS", "ŞARK", "ŞATO", "ŞEKI", "ŞEMA", "ŞIFA",
        "TABA", "TACI", "TADA", "TAHA", "TAKI", "TALE", "TAMA", "TANE",
        "TARA", "TASA", "TAVA", "TAXI", "TAZE", "TEMA", "TENE", "TEPE",
        "TERS", "TEZA", "TICE", "TIKI", "TILA", "TINE", "TIRA", "TIRE",
        "TOPA", "TOZA", "TUBA", "TUCE", "TUKA", "TULA", "TURA", "TUZA",
        "UBEY", "UÇAK", "ULAK", "ULVI", "UMDE", "UNDE", "URFA", "USER",
        "UZAK", "VADI", "VALE", "VANA", "VARA", "VEFA", "VELI", "VERA",
        "VETO", "VEZA", "VIDA", "VIRA", "YABA", "YACI", "YAFA", "YAKA",
        "YAMA", "YANA", "YARA", "YASA", "YATA", "YAVA", "YAYA", "YEDI",
        "YEME", "YERE", "YESI", "YETI", "YEZA", "YICA", "YIGI", "YILA",
        "YINE", "YIRA", "YISE", "YITA", "YIYE", "YIZA", "YOGA", "YOLA",
        "YONA", "YORA", "YOSE", "YOTA", "YOZA", "YUVA", "YUZE", "ZADE",
        "ZARA", "ZATA", "ZAVA", "ZAYA", "ZEKI", "ZERA", "ZETA", "ZIYA"
    ]
    
    // 5 harfli Türkçe kelimeler (mevcut liste)
    private let turkceKelimeler5Harf = [
        "ABONE", "ACELE", "ADRES", "AĞAÇ", "AHLAK", "AKTÖR", "ALARM", "ALÇAK",
        "ALKOL", "ALTIN", "AMBER", "ANKET", "ANTEP", "ARABA", "ARENA", "ASKER",
        "ASLAN", "ATLAS", "AVUÇ", "AYRAN", "BADEM", "BAHÇE", "BAKIR", "BALIK",
        "BALON", "BAMBU", "BANKA", "BARUT", "BAŞAK", "BAYAR", "BEBEK", "BEĞEN",
        "BELGE", "BEYIN", "BILGI", "BINME", "BIZON", "BOĞAZ", "BOMBA", "BOYUT",
        "BUGÜN", "BULUT", "BURMA", "CADDE", "CAHIL", "CAZIP", "ÇELIK", "ÇEVRE",
        "ÇIÇEK", "ÇINAR", "ÇILEK", "ÇORAP", "DAIRE", "DALGA", "DAMLA", "DEFTER",
        "DERGI", "DIĞER", "DIKEY", "DILEK", "DOĞAL", "DRAMA", "DÜNYA", "EKRAN",
        "ELMAS", "EMLEK", "ENDIK", "ESMER", "FAKAT", "FARUK", "FENER", "FERDI",
        "FIKIR", "FILIZ", "FINCAN", "GARAJ", "GELIN", "GEMICI", "GERÇEK", "GIRDI",
        "GÖLGE", "GRUBA", "GÜLER", "GÜNEŞ", "GÜVEN", "HABER", "HAFTA", "HAKIM",
        "HAYAL", "HEMEN", "HESAP", "HIZLI", "HIÇBIR", "IKLAN", "IMKAN", "INSAN",
        "ISLEM", "KALBI", "KALEM", "KAMPA", "KAPAK", "KARAR", "KARGO", "KATIN",
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
    
    // 6 harfli Türkçe kelimeler
    private let turkceKelimeler6Harf = [
        "ABAJUR", "ABANOS", "ABDEST", "ABIDIN", "ACAYIP", "AÇGÖZL", "ADALET", "ADAMCI",
        "ADIPOZ", "ADRESI", "AFACAN", "AĞABEY", "AĞAÇLA", "AHBABI", "AHLAKI", "AKTUEL",
        "ALBÜM", "ALÇALT", "ALKIŞLA", "ALTINA", "AMACIM", "AMBALAJ", "ANADOL", "ANALIZ",
        "ANIDEN", "ANKETI", "ANTIKA", "ARABAM", "ARAMIZ", "ARAYAN", "ARKADAŞ", "ARMAĞAN",
        "ASALET", "ASISTAN", "ATEŞLI", "ATILIB", "AVANAK", "AVUKAT", "AYAKLI", "AYDINS",
        "BABASI", "BAĞDAT", "BAHÇEM", "BAKICI", "BAKKAL", "BALKON", "BAMBAŞ", "BANYOD",
        "BARMEN", "BAŞÇAV", "BAŞKAN", "BAŞLAT", "BAVARI", "BAZALT", "BEĞEND", "BELIRL",
        "BENZET", "BERBER", "BEŞÇIK", "BEYLIK", "BIGUDI", "BILDIR", "BİLGİL", "BINDER",
        "BITKIM", "BITLIS", "BLOGAR", "BODRUM", "BÖBREK", "BÖĞÜRT", "BOYALI", "BÜFECI",
        "BÜLBÜL", "BÜROSÜ", "CABBAR", "CAFCAF", "CAMDAK", "CANCAN", "CANVAS", "CAZGIR",
        "CEYLAN", "ÇABALA", "ÇAĞDAŞ", "ÇALIŞT", "ÇALKAL", "ÇAMLAR", "ÇARMIH", "ÇAVUŞ",
        "ÇELIĞI", "ÇEMBER", "ÇENELI", "ÇEŞITL", "ÇEVRIM", "ÇEYREK", "ÇIÇEKL", "ÇIĞKÖF",
        "ÇILINGR", "ÇINICI", "DAĞÇIL", "DAIREM", "DALGIN", "DAMPER", "DANIŞM", "DARALT",
        "DAYANM", "DEDIKD", "DEFTERE", "DEĞIRL", "DEĞIŞT", "DEMIRC", "DENSIZ", "DERNEK",
        "DESTEK", "DETAYL", "DEVLET", "DEYIML", "DIBINE", "DIŞARI", "DIVERT", "DIZGIN",
        "DOKTOR", "DOKUMA", "DOMALT", "DOSYAL", "DOYUNÇ", "DRAMAT", "DÜBELL", "DÜKKAN",
        "DÜŞMAN", "DÜŞTÜ", "EĞITIM", "EKMEKÇ", "ELBEAT", "ELEKTR", "ELISIN", "EMBALI",
        "EMIRLE", "EMNIYT", "ENFLAT", "ENGELL", "ERKEKL", "ESARET", "EŞITSZ", "EVDEKL",
        "FAALIY", "FABRIK", "FAKTÖR", "FANATI", "FASULY", "FAZLAS", "FEDERAL", "FERYAL",
        "FESTIVAL", "FIATLA", "FIDANL", "FILMIN", "FINANS", "FIRMAY", "FOLKLOR", "FONKSIY",
        "GAMLSL", "GARAGJ", "GARDEN", "GAZETEC", "GEBERL", "GELECEK", "GELIŞT", "GEMIYL",
        "GERÇEK", "GIDIŞA", "GIYSIL", "GÖLLER", "GÖREVL", "GÖRÜNM", "GÖZLÜK", "GRAMER",
        "GRUPLA", "GÜÇLÜK", "GÜLERYÜ", "GÜNCEL", "GÜNDEM", "GÜNEYL", "GÜVENL", "HABERI",
        "HAFIFA", "HALKÇI", "HAMMAL", "HANGAR", "HARFLE", "HATIRL", "HEDİYE", "HENÜZ",
        "HESAPL", "HEYKEL", "HIRSIZ", "HIZMET", "HURDAT", "HUSUSI", "IHRACAT", "IKLIMB",
        "IMTINA", "INŞAAT", "ISTATÇ", "IŞÇIYI", "IŞLEMR", "IŞSIZL", "JANDARM", "JARDIN",
        "KAFTIK", "KALEMD", "KAMYON", "KANTRC", "KAPAÇA", "KAPUTÇ", "KARARL", "KARBON",
        "KARYOL", "KATALO", "KAVŞAK", "KEYIFL", "KIBRIS", "KIMYAN", "KIRALÇ", "KITAPL",
        "KLINIÇ", "KÖHNEK", "KÖMÜRÇ", "KÖPRÜL", "KÜLTÜR", "KURALL", "KUTSAK", "KÜTÜPH",
        "LAZERL", "LIDERŞ", "LISTEL", "LOKANT", "MAGAZN", "MAHALEL", "MAKINA", "MAKYAJ",
        "MAMULÇ", "MASAJÇ", "MATBAA", "MECLIS", "MEMURC", "METALL", "MEYVEL", "MIMARI",
        "MODERN", "MOTIFI", "MÜDIRL", "MÜSLEK", "MÜZEYI", "NAKARC", "NEDENG", "NETWORK",
        "NÖBETR", "ONAYLR", "ÖRGÜTÜ", "ÖZELLS", "PAKETI", "PANCAR", "PARKUR", "PASTEL",
        "PATIKA", "PAZARL", "PERŞEM", "PETROL", "PIKNIK", "PLASTK", "PRENSÇ", "PROGRAML",
        "RADYOL", "RANDEV", "REFORM", "RENKLR", "RESTAU", "REVIZE", "ROMAN", "SAATLE",
        "SABUNA", "SAĞLIK", "SALONC", "SANATÇ", "SARAYA", "SAYISL", "SEFERB", "SISTEM",
        "SONUÇL", "SPIKER", "ŞAHANE", "ŞANTIY", "ŞEHIRL", "ŞIKAYT", "TAKIMÜ", "TAKSIM",
        "TALEPS", "TARZEL", "TAŞINM", "TECRIT", "TEKNOL", "TELEFÖ", "TERMIN", "TICARL",
        "TOKMAK", "TURIST", "TÜRKÇE", "UÇUŞLA", "UMUMY", "UZMANL", "UZUNLU", "VASITA",
        "VECIZE", "VERIMLI", "VIDEON", "YABANA", "YAKALM", "YAPMCK", "YASALA", "YATAKL",
        "YAZIMV", "YETERL", "YOĞURT", "YÖNDER", "ZAFERL", "ZARARL", "ZEVCEY", "ZIRHLI"
    ]
    
    func getRandomWord(length: Int = 5) -> String {
        switch length {
        case 4:
            return turkceKelimeler4Harf.randomElement() ?? "ELMA"
        case 5:
            return turkceKelimeler5Harf.randomElement() ?? "ELMAS"
        case 6:
            return turkceKelimeler6Harf.randomElement() ?? "ELMASL"
        default:
            return turkceKelimeler5Harf.randomElement() ?? "ELMAS"
        }
    }
    
    func isValidWord(_ word: String, length: Int = 5) -> Bool {
        let uppercasedWord = word.uppercased()
        
        switch length {
        case 4:
            return turkceKelimeler4Harf.contains(uppercasedWord)
        case 5:
            return turkceKelimeler5Harf.contains(uppercasedWord)
        case 6:
            return turkceKelimeler6Harf.contains(uppercasedWord)
        default:
            return turkceKelimeler5Harf.contains(uppercasedWord)
        }
    }
    
    func getAllWords(length: Int = 5) -> [String] {
        switch length {
        case 4:
            return turkceKelimeler4Harf
        case 5:
            return turkceKelimeler5Harf
        case 6:
            return turkceKelimeler6Harf
        default:
            return turkceKelimeler5Harf
        }
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
