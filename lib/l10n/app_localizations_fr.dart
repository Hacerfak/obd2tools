// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'OBD2 Tools';

  @override
  String get tabSensors => 'Capteurs';

  @override
  String get tabHud => 'Tableau de Bord';

  @override
  String get tabTests => 'Tests';

  @override
  String get tabFaults => 'Défauts';

  @override
  String get tabMore => 'Plus';

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnSave => 'Enregistrer';

  @override
  String get btnSend => 'Envoyer';

  @override
  String get btnRefresh => 'Actualiser';

  @override
  String get connTitle => 'Se connecter au Scanner';

  @override
  String get connPaired => 'Appareils Associés';

  @override
  String get connNearby => 'Appareils à proximité';

  @override
  String get connNoDevices => 'Aucun appareil trouvé.';

  @override
  String get connSearching => 'Recherche...';

  @override
  String get connSearchNew => 'Rechercher Nouveaux Appareils';

  @override
  String get connEstablishing => 'Établissement d\'une connexion sécurisée...';

  @override
  String get connWaitKey =>
      'Mettez le contact pour allumer le tableau de bord.';

  @override
  String get connMapping => 'Cartographie des capteurs pris en charge...';

  @override
  String get connSuccess => 'Connexion Réussie !';

  @override
  String get sensTitle => 'Capteurs Cartographiés';

  @override
  String get sensNone => 'Aucun capteur trouvé.';

  @override
  String get sensInstant => 'Valeur Instantanée';

  @override
  String get sensRecent => 'Comportement Récent';

  @override
  String get sensReading => 'Lecture des données du bus CAN...';

  @override
  String get sensNoHistory => 'Historique non applicable pour l\'état textuel.';

  @override
  String get hudManage => 'Gérer les Capteurs';

  @override
  String get hudFullscreen => 'Plein Écran';

  @override
  String get hudImmersive => 'Mode Immersif';

  @override
  String get hudImmersiveDesc =>
      'Appuyez deux fois sur l\'écran pour entrer ou sortir du mode Plein Écran.';

  @override
  String get hudGotIt => 'Compris';

  @override
  String get hudConfig => 'Configurer le Tableau de Bord';

  @override
  String get hudSelected => 'Capteurs Sélectionnés';

  @override
  String get hudAvailable => 'DISPONIBLES';

  @override
  String get hudSearch => 'Rechercher un capteur...';

  @override
  String get testTitle => 'Résultats des tests ECU';

  @override
  String get testConsulting =>
      'Consultation des moniteurs et des limites de test...\nVeuillez patienter.';

  @override
  String get testNone => 'Aucun test interne trouvé.';

  @override
  String get testWaiting => 'Attente du cycle de conduite';

  @override
  String get testPassed => 'Réussi';

  @override
  String get testFailed => 'Échec de la Limite';

  @override
  String get faultTitle => 'Diagnostics (DTC)';

  @override
  String get faultClearMil => 'Effacer le voyant moteur (MIL) ?';

  @override
  String get faultClearDesc =>
      'Cette action réinitialisera la mémoire des défauts et le Freeze Frame. Assurez-vous que le CONTACT est MIS et le MOTEUR COUPÉ.';

  @override
  String get faultYesClear => 'Oui, effacer !';

  @override
  String get faultAll => 'Tous';

  @override
  String get faultConfirmed => 'Confirmés';

  @override
  String get faultPending => 'En attente';

  @override
  String get faultPermanent => 'Permanents';

  @override
  String get faultReading =>
      'Lecture de la mémoire de l\'ECU et des données figées...\nVeuillez patienter.';

  @override
  String get faultNone => 'Aucun défaut trouvé !';

  @override
  String get infoTitle => 'Informations du Véhicule';

  @override
  String get infoConsulting =>
      'Consultation des modules de l\'ECU et des calibrations...\nVeuillez patienter.';

  @override
  String get infoNone =>
      'Aucune information trouvée.\nLe véhicule peut ne pas prendre en charge le Mode 09.';

  @override
  String get setTitle => 'Paramètres du Système';

  @override
  String get setColor => 'Palette de Couleurs';

  @override
  String get setThemeLight => 'Thème Clair';

  @override
  String get setThemeDark => 'Thème Sombre';

  @override
  String get setMainColor => 'Couleur Principale (Thème/Neutres)';

  @override
  String get setNormalColor => 'Statut Normal (Sain)';

  @override
  String get setWarningColor => 'Statut d\'Avertissement (Alerte)';

  @override
  String get setCriticalColor => 'Statut Critique (Danger)';

  @override
  String get setRestoreColors => 'Restaurer les couleurs par défaut';

  @override
  String get setPerf => 'Performance et Batterie';

  @override
  String get setRate => 'Taux de rafraîchissement des capteurs';

  @override
  String get setRateDesc => 'Augmentez le temps si le téléphone chauffe';

  @override
  String get setRateMax => 'Maximum';

  @override
  String get setRateFast => 'Rapide (250ms)';

  @override
  String get setRateNormal => 'Normal (0.5s)';

  @override
  String get setRateEco => 'Éco (1s)';

  @override
  String get dbgTitle => 'Terminal de Diagnostic';

  @override
  String get dbgHeader => 'Header (Opt)';

  @override
  String get dbgCommand => 'Commande (PID/AT)';

  @override
  String get dbgFormula => 'Formule Personnalisée';

  @override
  String get dbgStop => 'Arrêter la recherche';

  @override
  String get dbgScan => 'Recherche par Force Brute';

  @override
  String get dbgClear => 'Effacer le Terminal';

  @override
  String get dbgExport => 'Exporter les Journaux';

  @override
  String get dbgEmpty => 'Le terminal est vide. Rien à exporter.';

  @override
  String get dbgSaved => 'Fichier enregistré avec succès sous :';
}
