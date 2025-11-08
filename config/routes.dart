import 'package:flutter/material.dart';
import 'package:admin_can_care/data/models/doctor_model.dart';
import 'package:admin_can_care/data/models/nurse_model.dart';
import 'package:admin_can_care/data/models/patient_model.dart';

// Screens
import 'package:admin_can_care/ui/screens/auth/admin_login_screen.dart';
import 'package:admin_can_care/ui/screens/auth/forgot_password_screen.dart';
import 'package:admin_can_care/ui/screens/dashboard/dashboard_screen.dart';
import 'package:admin_can_care/ui/screens/doctors/doctors_list_screen.dart';
import 'package:admin_can_care/ui/screens/doctors/doctor_details_screen.dart';
import 'package:admin_can_care/ui/screens/doctors/add_doctor_screen.dart';
import 'package:admin_can_care/ui/screens/nurses/nurses_list_screen.dart';
import 'package:admin_can_care/ui/screens/nurses/add_nurse_screen.dart';
import 'package:admin_can_care/ui/screens/patients/patients_list_screen.dart';
import 'package:admin_can_care/ui/screens/patients/add_patient_screen.dart';
import 'package:admin_can_care/ui/screens/publications/publications_screen.dart';
import 'package:admin_can_care/ui/screens/publications/create_publication_screen.dart';
import 'package:admin_can_care/ui/screens/notifications/create_notification_screen.dart';
import 'package:admin_can_care/ui/screens/transport/transport_requests_screen.dart';
import 'package:admin_can_care/ui/screens/profile/admin_profile_screen.dart';

// Routes Configuration - تكوين المسارات
class AppRoutes {
  // Route Names
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String dashboard = '/dashboard';
  
  // Doctors
  static const String doctors = '/doctors';
  static const String doctorDetails = '/doctors/:id';
  static const String addDoctor = '/doctors/add';
  
  // Nurses
  static const String nurses = '/nurses';
  static const String nurseDetails = '/nurses/:id';
  static const String addNurse = '/nurses/add';
  
  // Patients
  static const String patients = '/patients';
  static const String patientDetails = '/patients/:id';
  static const String addPatient = '/patients/add';
  
  // Publications
  static const String publications = '/publications';
  static const String createPublication = '/publications/create';
  
  // Notifications
  static const String createNotification = '/notifications/create';
  
  // Transport
  static const String transportRequests = '/transport/requests';
  static const String transportOverview = '/transport/overview';
  
  // Profile
  static const String profile = '/profile';

  // Generate Route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments
    final args = settings.arguments;

    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      // Doctors
      case doctors:
        return MaterialPageRoute(builder: (_) => const DoctorsListScreen());
      
      case addDoctor:
        return MaterialPageRoute(builder: (_) => const AddDoctorScreen());
      
      // Nurses
      case nurses:
        return MaterialPageRoute(builder: (_) => const NursesListScreen());
      
      case addNurse:
        return MaterialPageRoute(builder: (_) => const AddNurseScreen());
      
      // Patients
      case patients:
        return MaterialPageRoute(builder: (_) => const PatientsListScreen());
      
      case addPatient:
        return MaterialPageRoute(builder: (_) => const AddPatientScreen());
      
      // Publications
      case publications:
        return MaterialPageRoute(builder: (_) => const PublicationsScreen());
      
      case createPublication:
        return MaterialPageRoute(builder: (_) => const CreatePublicationScreen());
      
      // Notifications
      case createNotification:
        return MaterialPageRoute(builder: (_) => const CreateNotificationScreen());
      
      // Transport
      case transportRequests:
        return MaterialPageRoute(builder: (_) => const TransportRequestsScreen());
      
      // Profile
      case profile:
        return MaterialPageRoute(builder: (_) => const AdminProfileScreen());
      
      // Dynamic routes with parameters
      default:
        // Handle doctor details
        if (settings.name?.startsWith('/doctors/') == true &&
            settings.name != addDoctor) {
          if (args is DoctorModel) {
            return MaterialPageRoute(
              builder: (_) => DoctorDetailsScreen(doctor: args),
            );
          }
        }
        
        // Handle nurse details
        if (settings.name?.startsWith('/nurses/') == true &&
            settings.name != addNurse) {
          if (args is NurseModel) {
            // return MaterialPageRoute(
            //   builder: (_) => NurseDetailsScreen(nurse: args),
            // );
          }
        }
        
        // Handle patient details
        if (settings.name?.startsWith('/patients/') == true &&
            settings.name != addPatient) {
          if (args is PatientModel) {
            // return MaterialPageRoute(
            //   builder: (_) => PatientDetailsScreen(patient: args),
            // );
          }
        }

        // 404 - Not Found
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: const Center(
              child: Text('Page not found / الصفحة غير موجودة'),
            ),
          ),
        );
    }
  }
}

