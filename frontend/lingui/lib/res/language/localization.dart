import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Localized {
  static const delegate = LocalizedDelegate();

  static Localized of(BuildContext context) {
    final localized = Localizations.of<Localized>(context, Localized);
    if (localized == null)
      throw Exception('Could not find a Localization with the given context.');
    return localized;
  }

  String get profile => Intl.message("Profil");
  String get languageLearning => Intl.message("Sprache lernen");
  String exploredWord({dynamic count}) =>
      Intl.message("$count gelernte Wörter");
  String get learnNewLanguage => Intl.message("Eine neue Sprache lernen");
  String get chooseNewLanguage =>
      Intl.message("Wähle die Sprache, die du lernen möchtest");
  String get chooseKnownWords =>
      Intl.message("Wähle die Wörter, die du kennst");
  String get next => Intl.message("Weiter");
  String get back => Intl.message("Zurück");
  String get done => Intl.message("Fertig");
  String get progress => Intl.message("Fortschritt");
  String get word => Intl.message("Wort");
  String get level => Intl.message("Level");
  String get dueDate => Intl.message("Fälligkeitsdatum");
  String get videos => Intl.message("Videos");
  String get showTranscript => Intl.message("Transkript anzeigen");
  String get dictionary => Intl.message("Wörterbuch");
  String get searchWord => Intl.message("Wort suchen");
  String get alreadyKnown => Intl.message("Bereits bekannt");
  String get addToList => Intl.message("Zur Liste hinzufügen");
  String get subtitle => Intl.message("Untertitel");
  String get previousVideo => Intl.message("Vorheriges Video");
  String get nextVideo => Intl.message("Nächstes Video");
  String get noQuestions => Intl.message("Keine Fragen gefunden");
  String get noVideos => Intl.message("Keine Videos gefunden");
  String get answer => Intl.message("Antwort");
  String get pass => Intl.message("Überspringen");
  String get signInWithGoogle => Intl.message("Mit Google anmelden");
  String get leaderboard => Intl.message("Bestenliste");
  String get noMoreQuestions => Intl.message("Alle Fragen abgeschlossen");
  String get de => Intl.message("Deutsch");
  String get en => Intl.message("Englisch");
  String get es => Intl.message("Spanisch");
  String get fr => Intl.message("Französisch");
  String get it => Intl.message("Italienisch");
  String get ja => Intl.message("Japanisch");
  String get ko => Intl.message("Koreanisch");
  String get pl => Intl.message("Polnisch");
  String get pt => Intl.message("Portugiesisch");
  String get ru => Intl.message("Russisch");
  String get sv => Intl.message("Schwedisch");
}

class LocalizedDelegate extends LocalizationsDelegate<Localized> {
  List<Locale> get supportedLocales => [
        Locale.fromSubtags(languageCode: "de"),
        Locale.fromSubtags(languageCode: "en"),
        Locale.fromSubtags(languageCode: "tr"),
      ];

  const LocalizedDelegate();

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  Future<Localized> load(Locale locale) async {
    final String localeName = Intl.canonicalizedLocale(locale.toString());
    Intl.defaultLocale = localeName;
    switch (localeName) {
      case "de":
        return new DE();
      case "en":
        return new EN();
      case "tr":
        return new TR();
      default:
        throw Exception('Could not find the locale: ' + localeName);
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localized> old) {
    return true;
  }
}

class DE extends Localized {
  @override
  String get profile => Intl.message("Profil");
  @override
  String get languageLearning => Intl.message("Sprache lernen");
  @override
  String exploredWord({dynamic count}) =>
      Intl.message("$count gelernte Wörter");
  @override
  String get learnNewLanguage => Intl.message("Eine neue Sprache lernen");
  @override
  String get chooseNewLanguage =>
      Intl.message("Wähle die Sprache, die du lernen möchtest");
  @override
  String get chooseKnownWords =>
      Intl.message("Wähle die Wörter, die du kennst");
  @override
  String get next => Intl.message("Weiter");
  @override
  String get back => Intl.message("Zurück");
  @override
  String get done => Intl.message("Fertig");
  @override
  String get progress => Intl.message("Fortschritt");
  @override
  String get word => Intl.message("Wort");
  @override
  String get level => Intl.message("Level");
  @override
  String get dueDate => Intl.message("Fälligkeitsdatum");
  @override
  String get videos => Intl.message("Videos");
  @override
  String get showTranscript => Intl.message("Transkript anzeigen");
  @override
  String get dictionary => Intl.message("Wörterbuch");
  @override
  String get searchWord => Intl.message("Wort suchen");
  @override
  String get alreadyKnown => Intl.message("Bereits bekannt");
  @override
  String get addToList => Intl.message("Zur Liste hinzufügen");
  @override
  String get subtitle => Intl.message("Untertitel");
  @override
  String get previousVideo => Intl.message("Vorheriges Video");
  @override
  String get nextVideo => Intl.message("Nächstes Video");
  @override
  String get noQuestions => Intl.message("Keine Fragen gefunden");
  @override
  String get noVideos => Intl.message("Keine Videos gefunden");
  @override
  String get answer => Intl.message("Antwort");
  @override
  String get pass => Intl.message("Überspringen");
  @override
  String get signInWithGoogle => Intl.message("Mit Google anmelden");
  @override
  String get leaderboard => Intl.message("Bestenliste");
  @override
  String get noMoreQuestions => Intl.message("Alle Fragen abgeschlossen");
  @override
  String get de => Intl.message("Deutsch");
  @override
  String get en => Intl.message("Englisch");
  @override
  String get es => Intl.message("Spanisch");
  @override
  String get fr => Intl.message("Französisch");
  @override
  String get it => Intl.message("Italienisch");
  @override
  String get ja => Intl.message("Japanisch");
  @override
  String get ko => Intl.message("Koreanisch");
  @override
  String get pl => Intl.message("Polnisch");
  @override
  String get pt => Intl.message("Portugiesisch");
  @override
  String get ru => Intl.message("Russisch");
  @override
  String get sv => Intl.message("Schwedisch");
}

class EN extends Localized {
  @override
  String get profile => Intl.message("Profile");
  @override
  String get languageLearning => Intl.message("Learning Language");
  @override
  String exploredWord({dynamic count}) => Intl.message("$count words learned");
  @override
  String get learnNewLanguage => Intl.message("Learn a new language");
  @override
  String get chooseNewLanguage =>
      Intl.message("Choose the language you want to learn");
  @override
  String get chooseKnownWords => Intl.message("Choose the words you know");
  @override
  String get next => Intl.message("Next");
  @override
  String get back => Intl.message("Back");
  @override
  String get done => Intl.message("Done");
  @override
  String get progress => Intl.message("Progress");
  @override
  String get word => Intl.message("Word");
  @override
  String get level => Intl.message("Level");
  @override
  String get dueDate => Intl.message("Due Date");
  @override
  String get videos => Intl.message("Videos");
  @override
  String get showTranscript => Intl.message("Show Transcript");
  @override
  String get dictionary => Intl.message("Dictionary");
  @override
  String get searchWord => Intl.message("Search Word");
  @override
  String get alreadyKnown => Intl.message("Already Know");
  @override
  String get addToList => Intl.message("Add To List");
  @override
  String get subtitle => Intl.message("Captions");
  @override
  String get previousVideo => Intl.message("Previous Video");
  @override
  String get nextVideo => Intl.message("Next Video");
  @override
  String get noQuestions => Intl.message("Couldnt Find Any Questions");
  @override
  String get noVideos => Intl.message("Couldnt Find Any Videos");
  @override
  String get answer => Intl.message("Answer");
  @override
  String get pass => Intl.message("Pass");
  @override
  String get signInWithGoogle => Intl.message("Sign In With Google");
  @override
  String get leaderboard => Intl.message("Leaderboard");
  @override
  String get noMoreQuestions => Intl.message("Completed All Questions");
  @override
  String get de => Intl.message("German");
  @override
  String get en => Intl.message("English");
  @override
  String get es => Intl.message("Spanish");
  @override
  String get fr => Intl.message("French");
  @override
  String get it => Intl.message("Italian");
  @override
  String get ja => Intl.message("Japanese");
  @override
  String get ko => Intl.message("Korean");
  @override
  String get pl => Intl.message("Polish");
  @override
  String get pt => Intl.message("Portuguese");
  @override
  String get ru => Intl.message("Russian");
  @override
  String get sv => Intl.message("Swedish");
}

class TR extends Localized {
  @override
  String get profile => Intl.message("Profil");
  @override
  String get languageLearning => Intl.message("Öğrenilen Dil");
  @override
  String exploredWord({dynamic count}) =>
      Intl.message("$count keşfedilmiş kelime");
  @override
  String get learnNewLanguage => Intl.message("Yeni bir dil öğren");
  @override
  String get chooseNewLanguage => Intl.message("Öğrenmek istediğin dili seç");
  @override
  String get chooseKnownWords => Intl.message("Bildiğin kelimeleri seç");
  @override
  String get next => Intl.message("İleri");
  @override
  String get back => Intl.message("Geri");
  @override
  String get done => Intl.message("Bitti");
  @override
  String get progress => Intl.message("Gelişim");
  @override
  String get word => Intl.message("Kelime");
  @override
  String get level => Intl.message("Seviye");
  @override
  String get dueDate => Intl.message("Erişim Tarihi");
  @override
  String get videos => Intl.message("Videolar");
  @override
  String get showTranscript => Intl.message("Metni Görüntüle");
  @override
  String get dictionary => Intl.message("Sözlük");
  @override
  String get searchWord => Intl.message("Kelime ara");
  @override
  String get alreadyKnown => Intl.message("Zaten Biliyorum");
  @override
  String get addToList => Intl.message("Listeye Ekle");
  @override
  String get subtitle => Intl.message("Altyazı");
  @override
  String get previousVideo => Intl.message("Önceki Video");
  @override
  String get nextVideo => Intl.message("Sonraki Video");
  @override
  String get noQuestions => Intl.message("Soru Bulunamadı");
  @override
  String get noVideos => Intl.message("Video Bulunamadı");
  @override
  String get answer => Intl.message("Cevap");
  @override
  String get pass => Intl.message("Geç");
  @override
  String get signInWithGoogle => Intl.message("Google ile giriş yap");
  @override
  String get de => Intl.message("Almanca");
  @override
  String get en => Intl.message("İngilizce");
  @override
  String get es => Intl.message("İspanyolca");
  @override
  String get fr => Intl.message("Fransızca");
  @override
  String get it => Intl.message("İtalyanca");
  @override
  String get ja => Intl.message("Japonca");
  @override
  String get ko => Intl.message("Korece");
  @override
  String get pl => Intl.message("Lehçe");
  @override
  String get pt => Intl.message("Portekizce");
  @override
  String get ru => Intl.message("Rusça");
  @override
  String get sv => Intl.message("İsveççe");
  @override
  String get leaderboard => Intl.message("Lider Tablosu");
  @override
  String get noMoreQuestions => Intl.message("Sorular bitti");
}
