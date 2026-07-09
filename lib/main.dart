import 'package:flutter/material.dart';
import 'core/theme.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/mission/mission_screens.dart';
import 'screens/kiosk/cafe_kiosk_screen.dart';
import 'screens/kiosk/restaurant_kiosk_screen.dart';
import 'screens/kiosk/self_checkout_screen.dart';
import 'screens/reservation/hospital_screen.dart';
import 'screens/reservation/movie_ticket_screen.dart';

import 'screens/mission/train_ticket_screen.dart';
import 'screens/mission/package_tracking_screen.dart';
import 'screens/mission/online_shopping_screen.dart';
import 'screens/mission/food_delivery_screen.dart';

import 'screens/home/payment_screen.dart';
import 'screens/home/map_screen.dart';
import 'screens/home/my_info_screen.dart';
import 'screens/home/customer_center_screen.dart';
import 'screens/home/settings_screen.dart';

import 'screens/admin/admin_screens.dart';


void main() {
  runApp(const SeniorApp());
}

class SeniorApp extends StatelessWidget {
  const SeniorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '배움페이 - 시니어 디지털 생활 연습',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Pretendard', // Use Pretendard or system default
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textMain,
          elevation: 0,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signup_complete': (context) => const SignupCompleteScreen(),
        '/home': (context) => const HomeScreen(),
        '/mission_categories': (context) => const MissionCategoriesScreen(),
        '/mission_list': (context) => const MissionListScreen(),
        '/cafe_kiosk': (context) => const CafeKioskScreen(),
        '/restaurant_kiosk': (context) => const RestKioskScreen(),
        '/self_checkout': (context) => const SelfCheckoutScreen(),
        '/hospital': (context) => const HospitalScreen(),
        '/movie_ticket': (context) => const MovieTicketScreen(),
        '/train_ticket': (context) => const TrainTicketScreen(),
        '/online_shopping': (context) => const OnlineShoppingScreen(),
        '/food_delivery': (context) => const FoodDeliveryScreen(),
        '/package_tracking': (context) => const PackageTrackingScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/map': (context) => const MapScreen(),
        '/my_info': (context) => const MyInfoScreen(),
        '/point_history': (context) => const PointHistoryScreen(),
        '/mission_history': (context) => const MissionHistoryScreen(),
        '/customer_center': (context) => const CustomerCenterScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
        '/admin_signup': (context) => const AdminSignupScreen(),
        '/admin_signup_detail': (context) => const AdminSignupDetailScreen(),
        '/admin_members': (context) => const AdminMembersScreen(),
        '/admin_inquiry': (context) => const AdminInquiryScreen(),
        '/admin_inquiry_detail': (context) => const AdminInquiryDetailScreen(),
      },
    );
  }
}
