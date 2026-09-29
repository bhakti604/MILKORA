abstract class AppStrings {
  // Navigation & Headers
  String get appTitle;
  String get navHome;
  String get navCans;
  String get navAlerts;
  String get navHistory;
  String get navProfile;
  String get smartMilkMonitoring;
  String get monitorAllCans;
  String get realTimeNotifications;
  String get trackTrends;

  // Common Statuses
  String get safe;
  String get warning;
  String get critical;
  String get low;
  String get connected;
  String get disconnected;
  String get scanning;
  String get sensorLost;
  String get offline;
  String get withinSafeRange;
  String get safeRangeLabel;

  // Home Screen: Milk Safety Score & Hero Can
  String get milkSafetyScore;
  String get excellentColdChain;
  String get chilledDeepCold;
  String get elevatedRisk;
  String get criticalSpoilage;
  String get lastUpdated;
  String get liveSensor;
  String get safeTimeLeft;
  String get milkIsSafeNow;
  String get milkQuantity;
  String get battery;
  String get lidStatus;
  String get lidClosed;
  String get lidOpen;
  String get closedDemo;

  // Fleet Overview
  String get todaysMilkSafety;
  String cansMonitored(int count);
  String safeCount(int count);
  String warningCount(int count);
  String criticalCount(int count);

  // Cans Screen
  String get milkCansTitle;
  String get milkCansSubtitle;
  String get total;
  String get collectNow;
  String get checkSoon;

  // Can Details Screen
  String get liveMonitoring;
  String get tabLive;
  String get tabDetails;
  String get tabLocation;
  String get milkTemperature;
  String get farmer;
  String get bay;
  String get viewHistoryBtn;
  String get markCollectedBtn;

  // Cold-Chain Journey
  String get coldChainJourney;
  String get stageFarm;
  String get stageCollection;
  String get stageTransport;
  String get stageChilling;
  String get stageDairy;
  String get currentStageInTransit;

  // Alerts Screen
  String get alertsTitle;
  String get alertsSubtitle;
  String get filterAll;
  String get filterCritical;
  String get filterWarning;
  String get filterSafe;
  String get callDriver;
  String get viewDetails;
  String get alertWhat;
  String get alertWhere;
  String get alertTemp;
  String get alertWhy;
  String get alertAction;
  String get tempRecoveredTitle;
  String get tempRecoveredDesc;

  // History Screen
  String get historyTitle;
  String get historySubtitle;
  String get periodToday;
  String get periodYesterday;
  String get periodThisWeek;
  String get timeInSafeZone;
  String get coldChainHealth;
  String get optimalLabel;
  String get highest;
  String get lowest;
  String get average;
  String get lidOpened;
  String get overallResultGood;

  // BLE Panel & Sheet
  String get bleCenterTitle;
  String get bleCenterSubtitle;
  String get signalQuality;
  String get hardwareId;
  String get probeLatency;
  String get lastReading;
  String get scanAndConnect;
  String get disconnectBtn;
  String get detailsBtn;
  String get justNow;
  String secAgo(int sec);

  // Profile Screen
  String get profileTitle;
  String get manageAccount;
  String get projectDirector;
  String get milkoraTeam;
  String get languageSection;
  String get accountSettings;
  String get notifications;
  String get appTheme;
  String get themeLight;
  String get aboutMilkora;
  String get helpSupport;
  String get feedback;
  String get privacyPolicy;
  String get logout;
  String get nationalMission;
  String get version;

  // Welcome Screen
  String get welcomeTitle;
  String get welcomeSubtitle;
  String get welcomeTagline;
  String get monitorTempTitle;
  String get monitorTempDesc;
  String get preventSpoilageTitle;
  String get preventSpoilageDesc;
  String get ensureQualityTitle;
  String get ensureQualityDesc;
  String get getStartedBtn;
  String get techEcosystem;
}

/// =======================================================
/// ENGLISH TRANSLATION (Default)
/// =======================================================
class EnglishStrings implements AppStrings {
  @override
  String get appTitle => 'MILKORA';
  @override
  String get navHome => 'Home';
  @override
  String get navCans => 'Cans';
  @override
  String get navAlerts => 'Alerts';
  @override
  String get navHistory => 'History';
  @override
  String get navProfile => 'Profile';
  @override
  String get smartMilkMonitoring => 'Smart Milk Monitoring';
  @override
  String get monitorAllCans => 'Monitor all your milk cans';
  @override
  String get realTimeNotifications => 'Real-time notifications';
  @override
  String get trackTrends => 'Track and analyze trends';

  @override
  String get safe => 'SAFE';
  @override
  String get warning => 'WARNING';
  @override
  String get critical => 'CRITICAL';
  @override
  String get low => 'LOW';
  @override
  String get connected => 'Connected';
  @override
  String get disconnected => 'Disconnected';
  @override
  String get scanning => 'Scanning...';
  @override
  String get sensorLost => 'DATA STALE';
  @override
  String get offline => 'OFFLINE';
  @override
  String get withinSafeRange => 'Within safe range';
  @override
  String get safeRangeLabel => '4°C — 8°C';

  @override
  String get milkSafetyScore => 'MILK SAFETY SCORE';
  @override
  String get excellentColdChain => 'Excellent Cold-Chain Condition';
  @override
  String get chilledDeepCold => 'Chilled Deep Cold Condition';
  @override
  String get elevatedRisk => 'Elevated — Cold-Chain at Risk';
  @override
  String get criticalSpoilage => 'Critical — Spoilage Threshold';
  @override
  String get lastUpdated => 'Last updated';
  @override
  String get liveSensor => 'LIVE SENSOR';
  @override
  String get safeTimeLeft => 'Safe Time Left';
  @override
  String get milkIsSafeNow => 'Milk is safe right now';
  @override
  String get milkQuantity => 'Milk Quantity';
  @override
  String get battery => 'Battery';
  @override
  String get lidStatus => 'Lid Status';
  @override
  String get lidClosed => 'Closed';
  @override
  String get lidOpen => 'OPEN';
  @override
  String get closedDemo => 'Closed (Demo)';

  @override
  String get todaysMilkSafety => "TODAY'S MILK SAFETY";
  @override
  String cansMonitored(int count) => '$count Cans Monitored';
  @override
  String safeCount(int count) => '$count Safe';
  @override
  String warningCount(int count) => '$count Warning';
  @override
  String criticalCount(int count) => '$count Critical';

  @override
  String get milkCansTitle => 'Milk Cans';
  @override
  String get milkCansSubtitle => 'Monitor all your milk cans in real time';
  @override
  String get total => 'Total';
  @override
  String get collectNow => 'Collect Now';
  @override
  String get checkSoon => 'Check Soon';

  @override
  String get liveMonitoring => 'Live Monitoring';
  @override
  String get tabLive => 'Live';
  @override
  String get tabDetails => 'Details';
  @override
  String get tabLocation => 'Location';
  @override
  String get milkTemperature => 'Milk Temperature';
  @override
  String get farmer => 'Farmer';
  @override
  String get bay => 'Bay';
  @override
  String get viewHistoryBtn => 'View Temperature History';
  @override
  String get markCollectedBtn => 'Mark as Collected';

  @override
  String get coldChainJourney => 'COLD-CHAIN JOURNEY';
  @override
  String get stageFarm => 'FARM';
  @override
  String get stageCollection => 'COLLECTION';
  @override
  String get stageTransport => 'TRANSPORT';
  @override
  String get stageChilling => 'CHILLING';
  @override
  String get stageDairy => 'DAIRY';
  @override
  String get currentStageInTransit => 'Stage 3: Temperature Controlled Transit';

  @override
  String get alertsTitle => 'Alerts';
  @override
  String get alertsSubtitle => 'Real-time safety notifications';
  @override
  String get filterAll => 'All';
  @override
  String get filterCritical => 'Critical';
  @override
  String get filterWarning => 'Warning';
  @override
  String get filterSafe => 'Safe';
  @override
  String get callDriver => 'Call Driver';
  @override
  String get viewDetails => 'View Details';
  @override
  String get alertWhat => 'WHAT:';
  @override
  String get alertWhere => 'WHERE:';
  @override
  String get alertTemp => 'TEMPERATURE:';
  @override
  String get alertWhy => 'WHY IT MATTERS:';
  @override
  String get alertAction => 'ACTION TO TAKE:';
  @override
  String get tempRecoveredTitle => 'TEMPERATURE RECOVERED';
  @override
  String get tempRecoveredDesc => 'Can M-002 back in safe zone (5.8°C). Chilling restored.';

  @override
  String get historyTitle => 'Temperature History';
  @override
  String get historySubtitle => 'Track and analyze milk temperature trends';
  @override
  String get periodToday => 'Today';
  @override
  String get periodYesterday => 'Yesterday';
  @override
  String get periodThisWeek => 'This Week';
  @override
  String get timeInSafeZone => 'Time in Safe Zone';
  @override
  String get coldChainHealth => 'COLD-CHAIN HEALTH';
  @override
  String get optimalLabel => 'Optimal';
  @override
  String get highest => 'Highest';
  @override
  String get lowest => 'Lowest';
  @override
  String get average => 'Average';
  @override
  String get lidOpened => 'Lid Opened';
  @override
  String get overallResultGood => 'OVERALL RESULT: GOOD';

  @override
  String get bleCenterTitle => 'BLE Connection Center';
  @override
  String get bleCenterSubtitle => 'Hardware Telemetry & Sensor Diagnostics';
  @override
  String get signalQuality => 'Signal Quality (RSSI)';
  @override
  String get hardwareId => 'Hardware ID';
  @override
  String get probeLatency => 'Probe Latency';
  @override
  String get lastReading => 'Last Reading';
  @override
  String get scanAndConnect => 'Scan & Connect';
  @override
  String get disconnectBtn => 'Disconnect';
  @override
  String get detailsBtn => 'Details';
  @override
  String get justNow => 'Just now';
  @override
  String secAgo(int sec) => '$sec sec ago';

  @override
  String get profileTitle => 'Profile';
  @override
  String get manageAccount => 'Manage your account';
  @override
  String get projectDirector => 'Project Director';
  @override
  String get milkoraTeam => 'MILKORA Team';
  @override
  String get languageSection => 'LANGUAGE / भाषा / भाषा निवडा';
  @override
  String get accountSettings => 'Account Settings';
  @override
  String get notifications => 'Notifications';
  @override
  String get appTheme => 'App Theme';
  @override
  String get themeLight => 'Light';
  @override
  String get aboutMilkora => 'About MILKORA';
  @override
  String get helpSupport => 'Help & Support';
  @override
  String get feedback => 'Feedback';
  @override
  String get privacyPolicy => 'Privacy Policy';
  @override
  String get logout => 'Logout';
  @override
  String get nationalMission => 'Safe Milk • Healthy Communities • Stronger India';
  @override
  String get version => 'Version 1.0.0';

  @override
  String get welcomeTitle => 'MILKORA';
  @override
  String get welcomeSubtitle => 'Smart Milk Monitoring\nfor a Healthier Tomorrow';
  @override
  String get welcomeTagline => 'Safe Milk • Healthy Communities • Stronger India';
  @override
  String get monitorTempTitle => 'Monitor Temperature';
  @override
  String get monitorTempDesc => 'Real-time DS18B20 cold-chain tracking';
  @override
  String get preventSpoilageTitle => 'Prevent Spoilage';
  @override
  String get preventSpoilageDesc => 'Instant alerts when threshold exceeded';
  @override
  String get ensureQualityTitle => 'Ensure Quality';
  @override
  String get ensureQualityDesc => 'Guaranteed fresh milk for communities';
  @override
  String get getStartedBtn => 'Get Started';
  @override
  String get techEcosystem => 'Technology for a Safer Dairy Ecosystem';
}

/// =======================================================
/// HINDI TRANSLATION (हिन्दी)
/// =======================================================
class HindiStrings implements AppStrings {
  @override
  String get appTitle => 'मिल्कोरा';
  @override
  String get navHome => 'होम';
  @override
  String get navCans => 'कैन्स';
  @override
  String get navAlerts => 'अलर्ट';
  @override
  String get navHistory => 'इतिहास';
  @override
  String get navProfile => 'प्रोफ़ाइल';
  @override
  String get smartMilkMonitoring => 'स्मार्ट दुग्ध निगरानी प्रणाली';
  @override
  String get monitorAllCans => 'सभी दूध के कैन्स की निगरानी करें';
  @override
  String get realTimeNotifications => 'रीयल-टाइम सुरक्षा सूचनाएं';
  @override
  String get trackTrends => 'तापमान रुझानों का विश्लेषण करें';

  @override
  String get safe => 'सुरक्षित';
  @override
  String get warning => 'चेतावनी';
  @override
  String get critical => 'गंभीर';
  @override
  String get low => 'कम';
  @override
  String get connected => 'कनेक्टेड';
  @override
  String get disconnected => 'डिस्कनेक्टेड';
  @override
  String get scanning => 'खोज जारी है...';
  @override
  String get sensorLost => 'डेटा अनुपलब्ध';
  @override
  String get offline => 'ऑफलाइन';
  @override
  String get withinSafeRange => 'सुरक्षित सीमा में';
  @override
  String get safeRangeLabel => '4°C — 8°C';

  @override
  String get milkSafetyScore => 'मिल्क सेफ्टी स्कोर';
  @override
  String get excellentColdChain => 'उत्कृष्ट कोल्ड-चेन स्थिति';
  @override
  String get chilledDeepCold => 'अत्यधिक ठंडा तापमान स्थिति';
  @override
  String get elevatedRisk => 'तापमान बढ़ा — कोल्ड-चेन जोखिम में';
  @override
  String get criticalSpoilage => 'गंभीर — दूध खराब होने का खतरा';
  @override
  String get lastUpdated => 'अंतिम अपडेट';
  @override
  String get liveSensor => 'लाइव सेंसर';
  @override
  String get safeTimeLeft => 'सुरक्षित समय शेष';
  @override
  String get milkIsSafeNow => 'दूध अभी पूरी तरह सुरक्षित है';
  @override
  String get milkQuantity => 'दूध की मात्रा';
  @override
  String get battery => 'बैटरी';
  @override
  String get lidStatus => 'ढक्कन स्थिति';
  @override
  String get lidClosed => 'बंद';
  @override
  String get lidOpen => 'खुला';
  @override
  String get closedDemo => 'बंद (डेमो)';

  @override
  String get todaysMilkSafety => 'आज की दूध सुरक्षा स्थिति';
  @override
  String cansMonitored(int count) => '$count कैन्स सक्रिय';
  @override
  String safeCount(int count) => '$count सुरक्षित';
  @override
  String warningCount(int count) => '$count चेतावनी';
  @override
  String criticalCount(int count) => '$count गंभीर';

  @override
  String get milkCansTitle => 'दूध के कैन्स';
  @override
  String get milkCansSubtitle => 'सभी कैन्स का वास्तविक समय में निरीक्षण करें';
  @override
  String get total => 'कुल';
  @override
  String get collectNow => 'तुरंत उठाएं';
  @override
  String get checkSoon => 'जल्द जांचें';

  @override
  String get liveMonitoring => 'लाइव निगरानी';
  @override
  String get tabLive => 'लाइव';
  @override
  String get tabDetails => 'विवरण';
  @override
  String get tabLocation => 'स्थान';
  @override
  String get milkTemperature => 'दूध का तापमान';
  @override
  String get farmer => 'किसान';
  @override
  String get bay => 'बे';
  @override
  String get viewHistoryBtn => 'तापमान इतिहास देखें';
  @override
  String get markCollectedBtn => 'दूध संकलित चिह्नित करें';

  @override
  String get coldChainJourney => 'कोल्ड-चेन यात्रा';
  @override
  String get stageFarm => 'फार्म';
  @override
  String get stageCollection => 'संग्रहण';
  @override
  String get stageTransport => 'परिवहन';
  @override
  String get stageChilling => 'शीतलन';
  @override
  String get stageDairy => 'डेयरी';
  @override
  String get currentStageInTransit => 'चरण 3: तापमान नियंत्रित परिवहन जारी';

  @override
  String get alertsTitle => 'अलर्ट';
  @override
  String get alertsSubtitle => 'रीयल-टाइम सुरक्षा सूचनाएं';
  @override
  String get filterAll => 'सभी';
  @override
  String get filterCritical => 'गंभीर';
  @override
  String get filterWarning => 'चेतावनी';
  @override
  String get filterSafe => 'सुरक्षित';
  @override
  String get callDriver => 'चालक को कॉल करें';
  @override
  String get viewDetails => 'विवरण देखें';
  @override
  String get alertWhat => 'क्या हुआ:';
  @override
  String get alertWhere => 'कहाँ:';
  @override
  String get alertTemp => 'तापमान:';
  @override
  String get alertWhy => 'यह क्यों महत्वपूर्ण है:';
  @override
  String get alertAction => 'आवश्यक कार्रवाई:';
  @override
  String get tempRecoveredTitle => 'तापमान सुरक्षित स्तर पर लौटा';
  @override
  String get tempRecoveredDesc => 'कैन M-002 वापस सुरक्षित क्षेत्र (5.8°C) में है। शीतलन बहाल।';

  @override
  String get historyTitle => 'तापमान इतिहास';
  @override
  String get historySubtitle => 'दूध तापमान के रुझानों का विश्लेषण करें';
  @override
  String get periodToday => 'आज';
  @override
  String get periodYesterday => 'कल';
  @override
  String get periodThisWeek => 'इस सप्ताह';
  @override
  String get timeInSafeZone => 'सुरक्षित क्षेत्र में समय';
  @override
  String get coldChainHealth => 'कोल्ड-चेन स्वास्थ्य';
  @override
  String get optimalLabel => 'उत्कृष्ट';
  @override
  String get highest => 'अधिकतम';
  @override
  String get lowest => 'न्यूनतम';
  @override
  String get average => 'औसत';
  @override
  String get lidOpened => 'ढक्कन खुला';
  @override
  String get overallResultGood => 'समग्र परिणाम: उत्तम';

  @override
  String get bleCenterTitle => 'BLE कनेक्शन केंद्र';
  @override
  String get bleCenterSubtitle => 'हार्डवेयर टेलीमेट्री एवं सेंसर निदान';
  @override
  String get signalQuality => 'सिग्नल गुणवत्ता (RSSI)';
  @override
  String get hardwareId => 'हार्डवेयर आईडी';
  @override
  String get probeLatency => 'सेंसर विलंबता';
  @override
  String get lastReading => 'अंतिम रीडिंग';
  @override
  String get scanAndConnect => 'स्कैन और कनेक्ट करें';
  @override
  String get disconnectBtn => 'डिस्कनेक्ट करें';
  @override
  String get detailsBtn => 'विवरण';
  @override
  String get justNow => 'अभी-अभी';
  @override
  String secAgo(int sec) => '$sec सेकंड पहले';

  @override
  String get profileTitle => 'प्रोफ़ाइल';
  @override
  String get manageAccount => 'अपना खाता प्रबंधित करें';
  @override
  String get projectDirector => 'प्रोजेक्ट डायरेक्टर';
  @override
  String get milkoraTeam => 'मिल्कोरा टीम';
  @override
  String get languageSection => 'भाषा चुनें (LANGUAGE)';
  @override
  String get accountSettings => 'खाता सेटिंग्स';
  @override
  String get notifications => 'सूचनाएं';
  @override
  String get appTheme => 'ऐप थीम';
  @override
  String get themeLight => 'लाइट';
  @override
  String get aboutMilkora => 'मिल्कोरा के बारे में';
  @override
  String get helpSupport => 'सहायता और समर्थन';
  @override
  String get feedback => 'प्रतिक्रिया दें';
  @override
  String get privacyPolicy => 'गोपनीयता नीति';
  @override
  String get logout => 'लॉग आउट';
  @override
  String get nationalMission => 'सुरक्षित दूध • स्वस्थ समुदाय • सशक्त भारत';
  @override
  String get version => 'संस्करण 1.0.0';

  @override
  String get welcomeTitle => 'मिल्कोरा';
  @override
  String get welcomeSubtitle => 'स्वस्थ कल के लिए\nस्मार्ट दुग्ध निगरानी';
  @override
  String get welcomeTagline => 'सुरक्षित दूध • स्वस्थ समुदाय • सशक्त भारत';
  @override
  String get monitorTempTitle => 'तापमान निगरानी';
  @override
  String get monitorTempDesc => 'DS18B20 द्वारा रीयल-टाइम कोल्ड चेन ट्रैकिंग';
  @override
  String get preventSpoilageTitle => 'दूध खराब होने से रोकें';
  @override
  String get preventSpoilageDesc => 'तापमान सीमा पार होते ही त्वरित अलर्ट';
  @override
  String get ensureQualityTitle => 'गुणवत्ता सुनिश्चित करें';
  @override
  String get ensureQualityDesc => 'समुदायों के लिए स्वच्छ और सुरक्षित दूध';
  @override
  String get getStartedBtn => 'शुरू करें';
  @override
  String get techEcosystem => 'सुरक्षित दुग्ध पारिस्थितिकी तंत्र के लिए प्रौद्योगिकी';
}

/// =======================================================
/// MARATHI TRANSLATION (मराठी)
/// =======================================================
class MarathiStrings implements AppStrings {
  @override
  String get appTitle => 'मिल्कोरा';
  @override
  String get navHome => 'मुख्यपृष्ठ';
  @override
  String get navCans => 'कॅन्स';
  @override
  String get navAlerts => 'सूचना';
  @override
  String get navHistory => 'इतिहास';
  @override
  String get navProfile => 'प्रोफाइल';
  @override
  String get smartMilkMonitoring => 'स्मार्ट दूध संनियंत्रण प्रणाली';
  @override
  String get monitorAllCans => 'सर्व दूध कॅन्सचे निरीक्षण करा';
  @override
  String get realTimeNotifications => 'थेट सुरक्षा सूचना';
  @override
  String get trackTrends => 'तापमान कल आणि विश्लेषण पहा';

  @override
  String get safe => 'सुरक्षित';
  @override
  String get warning => 'इशारा';
  @override
  String get critical => 'गंभीर';
  @override
  String get low => 'कमी';
  @override
  String get connected => 'जोडलेले';
  @override
  String get disconnected => 'जोडणी तुटली';
  @override
  String get scanning => 'शोध सुरू आहे...';
  @override
  String get sensorLost => 'माहिती उपलब्ध नाही';
  @override
  String get offline => 'ऑफलाइन';
  @override
  String get withinSafeRange => 'सुरक्षित कक्षेत';
  @override
  String get safeRangeLabel => '4°C — 8°C';

  @override
  String get milkSafetyScore => 'दूध सुरक्षा गुण';
  @override
  String get excellentColdChain => 'उत्कृष्ट कोल्ड-चेन स्थिती';
  @override
  String get chilledDeepCold => 'अत्यंत थंड तापमान स्थिती';
  @override
  String get elevatedRisk => 'तापमान वाढले — कोल्ड-चेन धोक्यात';
  @override
  String get criticalSpoilage => 'गंभीर — दूध नासण्याचा धोका';
  @override
  String get lastUpdated => 'शेवटचे अद्यतन';
  @override
  String get liveSensor => 'थेट सेन्सर';
  @override
  String get safeTimeLeft => 'सुरक्षित वेळ शिल्लक';
  @override
  String get milkIsSafeNow => 'दूध सध्या पूर्णपणे सुरक्षित आहे';
  @override
  String get milkQuantity => 'दुधाचे प्रमाण';
  @override
  String get battery => 'बॅटरी';
  @override
  String get lidStatus => 'झाकणाची स्थिती';
  @override
  String get lidClosed => 'बंद';
  @override
  String get lidOpen => 'उघडे';
  @override
  String get closedDemo => 'बंद (डेमो)';

  @override
  String get todaysMilkSafety => 'आजची दूध सुरक्षा स्थिती';
  @override
  String cansMonitored(int count) => '$count कॅन्स निरीक्षण';
  @override
  String safeCount(int count) => '$count सुरक्षित';
  @override
  String warningCount(int count) => '$count इशारा';
  @override
  String criticalCount(int count) => '$count गंभीर';

  @override
  String get milkCansTitle => 'दूध कॅन्स';
  @override
  String get milkCansSubtitle => 'सर्व कॅन्सचे थेट निरीक्षण करा';
  @override
  String get total => 'एकूण';
  @override
  String get collectNow => 'त्वरीत उचला';
  @override
  String get checkSoon => 'लवकर तपासा';

  @override
  String get liveMonitoring => 'थेट निरीक्षण';
  @override
  String get tabLive => 'थेट';
  @override
  String get tabDetails => 'तपशील';
  @override
  String get tabLocation => 'स्थान';
  @override
  String get milkTemperature => 'दुधाचे तापमान';
  @override
  String get farmer => 'शेतकरी';
  @override
  String get bay => 'बे';
  @override
  String get viewHistoryBtn => 'तापमान इतिहास पहा';
  @override
  String get markCollectedBtn => 'संकलित म्हणून नोंदवा';

  @override
  String get coldChainJourney => 'कोल्ड-चेन प्रवास';
  @override
  String get stageFarm => 'शेत';
  @override
  String get stageCollection => 'संकलन';
  @override
  String get stageTransport => 'वाहतूक';
  @override
  String get stageChilling => 'शीतकरण';
  @override
  String get stageDairy => 'डेअरी';
  @override
  String get currentStageInTransit => 'टप्पा 3: तापमान नियंत्रित वाहतूक सुरू';

  @override
  String get alertsTitle => 'सूचना';
  @override
  String get alertsSubtitle => 'थेट सुरक्षा सूचना';
  @override
  String get filterAll => 'सर्व';
  @override
  String get filterCritical => 'गंभीर';
  @override
  String get filterWarning => 'इशारा';
  @override
  String get filterSafe => 'सुरक्षित';
  @override
  String get callDriver => 'चालकाला फोन करा';
  @override
  String get viewDetails => 'तपशील पहा';
  @override
  String get alertWhat => 'काय घडले:';
  @override
  String get alertWhere => 'कुठे:';
  @override
  String get alertTemp => 'तापमान:';
  @override
  String get alertWhy => 'हे महत्त्वाचे का आहे:';
  @override
  String get alertAction => 'करावयाची कृती:';
  @override
  String get tempRecoveredTitle => 'तापमान सुरक्षित पातळीवर परतले';
  @override
  String get tempRecoveredDesc => 'कॅन M-002 पुन्हा सुरक्षित क्षेत्रात (5.8°C). शीतकरण पूर्ववत.';

  @override
  String get historyTitle => 'तापमान इतिहास';
  @override
  String get historySubtitle => 'दुधाच्या तापमानाचा कल तपासा';
  @override
  String get periodToday => 'आज';
  @override
  String get periodYesterday => 'काल';
  @override
  String get periodThisWeek => 'या आठवड्यात';
  @override
  String get timeInSafeZone => 'सुरक्षित तापमानातील वेळ';
  @override
  String get coldChainHealth => 'कोल्ड-चेन आरोग्य';
  @override
  String get optimalLabel => 'उत्तम';
  @override
  String get highest => 'कमाल';
  @override
  String get lowest => 'किमान';
  @override
  String get average => 'सरासरी';
  @override
  String get lidOpened => 'झाकण उघडले';
  @override
  String get overallResultGood => 'एकूण निकाल: उत्तम';

  @override
  String get bleCenterTitle => 'BLE जोडणी केंद्र';
  @override
  String get bleCenterSubtitle => 'हार्डवेअर टेलिमेट्री व सेन्सर तपासणी';
  @override
  String get signalQuality => 'सिग्नल गुणवत्ता (RSSI)';
  @override
  String get hardwareId => 'हार्डवेअर आयडी';
  @override
  String get probeLatency => 'सेन्सर प्रतिसाद वेळ';
  @override
  String get lastReading => 'शेवटची नोंद';
  @override
  String get scanAndConnect => 'स्कॅन करा आणि जोडा';
  @override
  String get disconnectBtn => 'डिस्कनेक्ट करा';
  @override
  String get detailsBtn => 'तपशील';
  @override
  String get justNow => 'आत्ताच';
  @override
  String secAgo(int sec) => '$sec सेकंदांपूर्वी';

  @override
  String get profileTitle => 'प्रोफाइल';
  @override
  String get manageAccount => 'आपले खाते व्यवस्थापित करा';
  @override
  String get projectDirector => 'प्रकल्प संचालक';
  @override
  String get milkoraTeam => 'मिल्कोरा संघ';
  @override
  String get languageSection => 'भाषा निवडा (LANGUAGE)';
  @override
  String get accountSettings => 'खाते सेटिंग्ज';
  @override
  String get notifications => 'सूचना';
  @override
  String get appTheme => 'ॲप थीम';
  @override
  String get themeLight => 'लाइट';
  @override
  String get aboutMilkora => 'मिल्कोरा बद्दल';
  @override
  String get helpSupport => 'मदत आणि सहाय्य';
  @override
  String get feedback => 'प्रतिक्रिया द्या';
  @override
  String get privacyPolicy => 'गोपनीयता धोरण';
  @override
  String get logout => 'लॉग आउट';
  @override
  String get nationalMission => 'सुरक्षित दूध • निरोगी समाज • सक्षम भारत';
  @override
  String get version => 'आवृत्ती 1.0.0';

  @override
  String get welcomeTitle => 'मिल्कोरा';
  @override
  String get welcomeSubtitle => 'निरोगी उद्यासाठी\nस्मार्ट दूध संनियंत्रण';
  @override
  String get welcomeTagline => 'सुरक्षित दूध • निरोगी समाज • सक्षम भारत';
  @override
  String get monitorTempTitle => 'तापमान संनियंत्रण';
  @override
  String get monitorTempDesc => 'DS18B20 द्वारे थेट कोल्ड-चेन ट्रॅकिंग';
  @override
  String get preventSpoilageTitle => 'दूध नासण्यापासून रोखा';
  @override
  String get preventSpoilageDesc => 'तापमान मर्यादा ओलांडताच तात्काळ इशारा';
  @override
  String get ensureQualityTitle => 'गुणवत्ता निश्चित करा';
  @override
  String get ensureQualityDesc => 'समाजासाठी खात्रीशीर ताजे आणि सुरक्षित दूध';
  @override
  String get getStartedBtn => 'सुरू करा';
  @override
  String get techEcosystem => 'सुरक्षित दुग्ध परिसंस्थेसाठी तंत्रज्ञान';
}
