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
  String get setRateFast => 'Rapide';

  @override
  String get setRateNormal => 'Normal';

  @override
  String get setRateEco => 'Éco';

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

  @override
  String connSensorsMapped(int count) {
    return '$count capteurs cartographiés';
  }

  @override
  String get connSnackSavedNotFound =>
      'Scanner enregistré introuvable. Veuillez sélectionner dans la liste.';

  @override
  String get connSnackConnFailed =>
      'Échec de la connexion. Essayez de redémarrer le Bluetooth.';

  @override
  String get themeSystemTooltip => 'Thème : Système';

  @override
  String get themeLightTooltip => 'Thème : Clair';

  @override
  String get themeDarkTooltip => 'Thème : Sombre';

  @override
  String get statusDisconnected => 'Déconnecté';

  @override
  String get statusConnected => 'ECU en ligne';

  @override
  String get statusHibernating => 'ECU en veille (Contact coupé)';

  @override
  String get btnDisconnect => 'Déconnecter';

  @override
  String get moreMenuTitle => 'Plus d\'options';

  @override
  String get moreDiagSection => 'DIAGNOSTIC AVANCÉ';

  @override
  String get moreInfoDesc => 'VIN, CVN, Moniteurs Mode 09';

  @override
  String get moreTerminalDesc => 'Envoyer PIDs manuels et commandes AT';

  @override
  String get moreAppSection => 'APPLICATION';

  @override
  String get moreSettings => 'Paramètres';

  @override
  String get moreSettingsDesc => 'Connexion, Protocoles et Préférences';

  @override
  String setChooseColor(String colorName) {
    return 'Choisir la couleur : $colorName';
  }

  @override
  String get btnApply => 'Appliquer';

  @override
  String get testValue => 'Valeur';

  @override
  String get testMin => 'Min';

  @override
  String get testMax => 'Max';

  @override
  String get sensWaitGraph => '(Attendez que le graphique se remplisse)';

  @override
  String get faultDetailsTitle => 'Détails du Défaut';

  @override
  String get faultDescConfirmed =>
      'Allume le voyant moteur. Le problème est en cours ou vient de se produire.';

  @override
  String get faultDescPending =>
      'L\'ECU a détecté une anomalie mais nécessite plus de cycles pour confirmer.';

  @override
  String get faultDescPermanent =>
      'Défaut grave. Ne s\'efface qu\'après réparation et conduite du véhicule.';

  @override
  String get faultFreezeFrameTitle => 'Données Figées (Freeze Frame) :';

  @override
  String dbgExportError(String error) {
    return 'Erreur d\'exportation : $error';
  }

  @override
  String get dbgScanTitle => 'Recherche de PIDs (Force Brute)';

  @override
  String get dbgScanHeaderHint => 'En-tête (Optionnel, ex: 7E0)';

  @override
  String get dbgScanPrefixHint => 'Mode/Préfixe (ex: 22)';

  @override
  String get dbgScanStartHint => 'Début Hex (ex: 1100)';

  @override
  String get dbgScanEndHint => 'Fin Hex (ex: 11FF)';

  @override
  String get dbgScanWarning =>
      '⚠️ Attention : La recherche enverra des requêtes séquentielles continues. Les grandes plages peuvent prendre plusieurs minutes.';

  @override
  String get btnStart => 'Démarrer';

  @override
  String get dbgErrorBounds => 'Le début est supérieur à la fin';

  @override
  String dbgScanStarting(String start, String end) {
    return 'Démarrage de la recherche de $start à $end...';
  }

  @override
  String get dbgErrorHex =>
      'Erreur dans les paramètres hexadécimaux ! Vérifiez votre saisie.';

  @override
  String get dbgScanComplete => 'Recherche terminée !';

  @override
  String dbgFormulaResult(String result) {
    return 'Résultat (Formule) : $result';
  }

  @override
  String get dbgFormulaError =>
      'Erreur : Échec de l\'interprétation de la formule. Vérifiez la syntaxe.';

  @override
  String get dbgScanCancelled => 'Recherche annulée par l\'utilisateur.';

  @override
  String get techLibTitle => 'Bibliothèque Technique';

  @override
  String get techHowItWorks => 'Comment fonctionne ce capteur ?';

  @override
  String get techWhatIsIt => 'Qu\'est-ce que c\'est ?';

  @override
  String get techFunction => 'Fonction';

  @override
  String get techImpact => 'Impact sur le Système';

  @override
  String get dtcSymptoms => 'Symptômes Courants';

  @override
  String get dtcCauses => 'Causes Possibles';

  @override
  String get dtcResolution => 'Comment Tester et Résoudre';

  @override
  String get errBleDisconnected => 'Connexion Bluetooth perdue !';

  @override
  String get aboutTitle => 'À propos de l\'application';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutTheProjectTitle => 'Le Projet';

  @override
  String get aboutTheProjectDesc =>
      'OBD2 Tools a été développé dans le but de démocratiser le diagnostic automobile. Alliant une interface moderne à la télémétrie en temps réel, cette application transforme votre smartphone en un scanner professionnel, permettant aux passionnés et aux mécaniciens de comprendre l\'état de santé du véhicule de manière claire, rapide et objective.';

  @override
  String get aboutDeveloperTitle => 'Développeur';

  @override
  String get aboutDeveloperRole => 'Apprenti';

  @override
  String get aboutDeveloperDesc =>
      'Passionné par la technologie et le monde de l\'automobile. Créer des solutions pour simplifier le quotidien.';

  @override
  String get unitCounts => 'comptes';

  @override
  String midO2Sensor(Object hex) {
    return 'Sonde Lambda - Capteur 0x$hex';
  }

  @override
  String midCatalyst(Object bank) {
    return 'Catalyseur - Banque $bank';
  }

  @override
  String midEgr(Object bank) {
    return 'Système EGR - Banque $bank';
  }

  @override
  String midVvt(Object bank) {
    return 'Système VVT - Banque $bank';
  }

  @override
  String get midEvapGeneral => 'EVAP - Moniteur Général du Réservoir';

  @override
  String get midEvapVacuumInit => 'EVAP - Étanchéité / Vide Initial';

  @override
  String get midEvapGrossLeak => 'EVAP - Fuite Majeure (0.090\")';

  @override
  String get midEvapMedLeak => 'EVAP - Fuite Moyenne (0.040\")';

  @override
  String get midEvapSmallLeak => 'EVAP - Micro Fuite (0.020\")';

  @override
  String get midEvapPurgeValve => 'EVAP - Électrovanne de Purge';

  @override
  String get midEvapVentValve => 'EVAP - Vanne de Mise à l\'Air';

  @override
  String midO2Heater(Object hex) {
    return 'Chauffage Sonde Lambda - Capteur 0x$hex';
  }

  @override
  String midSecAir(Object bank) {
    return 'Air Secondaire - Banque $bank';
  }

  @override
  String midFuelSystem(Object bank) {
    return 'Circuit de Carburant - Banque $bank';
  }

  @override
  String midMisfireCylinder(Object cylinder) {
    return 'Raté d\'Allumage - Cylindre $cylinder';
  }

  @override
  String get midMisfireAll => 'Raté d\'Allumage - Tous les Cylindres';

  @override
  String midProprietary(Object hex) {
    return 'Moniteur Propriétaire (0x$hex)';
  }

  @override
  String midObd(Object hex) {
    return 'Moniteur OBD (0x$hex)';
  }

  @override
  String get tidO2RichToLean => 'Temps de Réponse (Riche à Pauvre)';

  @override
  String get tidO2LeanToRich => 'Temps de Réponse (Pauvre à Riche)';

  @override
  String get tidO2MinVoltage => 'Tension Minimale Mesurée';

  @override
  String get tidO2MaxVoltage => 'Tension Maximale Mesurée';

  @override
  String get tidMisfireEwma => 'Nombre de Ratés (Moyenne EWMA)';

  @override
  String get tidMisfireCurrent => 'Nombre de Ratés (Cycle Actuel)';

  @override
  String get tidEvapPurgeRate => 'Taux de Purge/Fuite EVAP';

  @override
  String get tidEvapInitGrad => 'Gradient de Pression Initial EVAP';

  @override
  String get tidEvapTankDelta => 'Variation de Pression Réservoir';

  @override
  String get tidEvapVacDecay => 'Maintien de Vide EVAP';

  @override
  String get tidEvapInitStab => 'Stabilité Pression Initiale Réservoir';

  @override
  String get tidEvapCanisterVac => 'Maintien Vide Residual Canister';

  @override
  String get tidEvapVentFlow => 'Débit Vanne de Mise à l\'Air';

  @override
  String get tidEvapSolResponse => 'Réponse Solénoïde de Purge';

  @override
  String get tidEvapLinePress => 'Pression Ligne de Purge sous Charge';

  @override
  String get tidEvapSensorResp => 'Temps Réponse Capteur Pression EVAP';

  @override
  String get tidEvapSmallDecay => 'Chute de Vide (Micro Fuite 0.020\")';

  @override
  String get tidEvapMedDecay => 'Variation Pression (Fuite Moyenne 0.040\")';

  @override
  String get tidEvapGrossHold => 'Maintien de Vide (Fuite Majeure 0.090\")';

  @override
  String get tidEvapMinPurgePress => 'Pression Minimale Atteinte Purge';

  @override
  String tidGeneric(Object hex) {
    return 'Test 0x$hex';
  }
}
