/// System-wide constants for BISHE Car Wash Service
class AppConstants {
  AppConstants._();

  static const String appName = 'BISHE Car Wash';
  static const String appTagline = 'Premier Auto Care in Bishoftu, Oromia';
  static const String appLocation = 'Bishoftu (Debre Zeyit), Oromia, Ethiopia';

  // Currency
  static const String currencyCode = 'ETB';
  static const String currencySymbol = 'Br'; // Ethiopian Birr

  // Station Capacity Specifications
  static const int totalStationBays = 2; // Bay 1 & Bay 2
  static const int totalMobileVans = 1;  // At-Home Mobile Van

  // Commission default
  static const double defaultCommissionRate = 0.15; // 15% commission per wash

  // Station GPS & Contact
  static const String stationName = 'BISHE CAR WASH service';
  static const String stationGpsCoordinates = '8°44\'57.2"N 38°58\'02.4"E';
  static const String stationGpsDecimal = '8.749222, 38.967333';
  static const String googleMapsLocationUrl = 'https://www.google.com/maps/search/?api=1&query=8%C2%B044%2757.2%22N+38%C2%B058%2702.4%22E';
  static const String stationPhoneNumber = '+251911234567';

  // Live Supabase Backend Configuration (Project: bishe car wash)
  static const String supabaseUrl = 'https://siioobajphmwzwwarlrr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpaW9vYmFqcGhtd3p3d2FybHJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1OTA3MjksImV4cCI6MjEwODE2NjcyOX0.7ilkYS4N8m_b-uy3ExxnE-SJidumg-Zk8hkHP8CgD4U';
  static const String supabasePublishableKey = 'sb_publishable_U_PZ2VeYiYpeR6CdFbbFfQ_dNVpdDzl';

  // Bishoftu Popular Service Areas for Mobile Van
  static const List<String> bishoftuAreas = [
    'Bishoftu City Center (Kebele 01)',
    'Lake Babogaya Area',
    'Lake Bishoftu Resort Corridor',
    'Kuriftu Area (Kebele 04)',
    'Lake Hora Ras Side',
    'Meda Welabu Area',
    'Addis-Bishoftu Expressway Gate',
    'Industrial Park Road',
  ];
}
