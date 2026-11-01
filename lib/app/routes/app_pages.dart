import 'package:elbabor/app/bindings/auth_binding.dart';
import 'package:elbabor/app/bindings/create_trip_binding.dart';
import 'package:elbabor/app/bindings/driver_dashboard_binding.dart';
import 'package:elbabor/app/bindings/passenger_dashboard_binding.dart';
import 'package:elbabor/app/bindings/profile_binding.dart';
import 'package:elbabor/app/bindings/signin_binding.dart';
import 'package:elbabor/app/bindings/splash_binding.dart';
import 'package:elbabor/app/bindings/trip_management_binding.dart';
import 'package:elbabor/modules/auth/views/auth_view.dart';
import 'package:elbabor/modules/auth/views/driver_details_screen.dart';
import 'package:elbabor/modules/common/profile/view/profile_view.dart';
import 'package:elbabor/modules/driver/create_trip/views/create_trip_screen.dart';
import 'package:elbabor/modules/driver/create_trip/views/trip_preview_view.dart';
import 'package:elbabor/modules/driver/trip_managment/views/trip_management_view.dart';
import 'package:elbabor/modules/driver/views/driver_info_view.dart';
import 'package:elbabor/modules/home/views/tabs/passenger_home_tab.dart';
import 'package:elbabor/modules/rating/view/rating_view.dart';
import 'package:elbabor/modules/rating/viewmodel/rating_viewmodel.dart';
import 'package:get/get.dart';
import '../../modules/auth/viewmodels/auth_viewmodel.dart';
import '../../modules/auth/views/forgot_password_screen.dart';
import '../../modules/common/message/view/chat_detail_view.dart';
import '../../modules/driver/trip_details/views/trip_detail_view.dart';
import '../../modules/driver/viewmodels/driver_info_viewmodel.dart';
import '../../modules/onboarding/viewmodels/language_selection_viewmodel.dart';
import '../../modules/onboarding/viewmodels/onboarding_viewmodel.dart';
import '../../modules/onboarding/viewmodels/role_selection_viewmodel.dart';
import '../../modules/onboarding/views/language_selection_view.dart';
import '../../modules/onboarding/views/splash_screen.dart';
import '../../modules/onboarding/views/onboarding_screen.dart';
import '../../modules/onboarding/views/role_selection_screen.dart';
import '../../modules/auth/views/signin_screen.dart';
import '../../modules/auth/views/signup_screen.dart';
import '../../modules/home/views/driver_dashboard_view.dart';
import '../../modules/home/views/passenger_dashboard_view.dart';
import '../../modules/passenger/viewmodels/passenger_info_viewmodel.dart';
import '../../modules/passenger/views/passenger_info_view.dart';
import '../../modules/passenger/views/passenger_trip_detail_view.dart';
import '../../modules/passenger/views/search_trip/search_trip_view.dart';
import '../bindings/driver_details_binding.dart';
import '../bindings/forgot_password_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../bindings/passenger_trip_detail_binding.dart';
import '../bindings/role_binding.dart';
import '../bindings/search_trip_binding.dart';
import '../bindings/signup_binding.dart';
import '../bindings/trip_detail_binding.dart';
import '../bindings/trip_preview_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
        name: Routes.SPLASH,
        page: () => const SplashScreen(),
        binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => OnBoardingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingViewModel>(() => OnboardingViewModel());
      }),
    ),
    GetPage(
      name: Routes.LANGUAGE_SELECTION,
      page: () => LanguageSelectionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LanguageSelectionViewModel>(() => LanguageSelectionViewModel());
      }),
    ),
    GetPage(
      name: Routes.ROLE,
      page: () => const RoleSelectionScreen(),
      binding: RoleSelectionBinding(),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => AuthView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthViewModel>(() => AuthViewModel());
      }),
    ),
    GetPage(
        name: Routes.SIGNIN,
        page: () =>  SigninView(),
        binding: SigninBinding()
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () =>  SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.RATING,
      page: () => const RatingView(),

      binding: BindingsBuilder(() {
        Get.lazyPut<RatingViewModel>(() => RatingViewModel());
      }),
    ),
    GetPage(
      name: Routes.DRIVER_DETAILS,
      page: () =>  DriverDetailsView(),
      binding: DriverDetailsBinding(),
    ),
    GetPage(
        name: Routes.DRIVER_HOME,
        page: () =>  DriverDashboardView(),
        binding: DriverDashboardBinding()
    ),
    GetPage(
        name: Routes.DRIVER_CREATE_TRIP,
        page: () =>  CreateTripScreen(),
        binding: CreateTripBinding()
    ),
    GetPage(
        name: Routes.DRIVER_INFO,
        page: () =>  DriverInfoView(),
        binding: BindingsBuilder(() {
        Get.put(DriverInfoViewModel());
        }),
    ),

    GetPage(
        name: Routes.PASSENGER_INFO,
        page: () =>  PassengerInfoView(),
        binding: BindingsBuilder(() {
        Get.put(PassengerInfoViewModel());
        }),
    ),
    GetPage(
        name: Routes.TRIP_PREVIEW,
        page: () =>  TripPreviewView(),
        binding: TripPreviewBinding()
    ),
    GetPage(
      name: Routes.TRIP_MANAGEMENT,
      page: () => TripManagementView(),
      binding: TripManagementBinding(),
    ),
    GetPage(
      name: Routes.TRIP_DETAIL,
      page: () => const TripDetailView(),
      binding: TripDetailBinding(),
    ),

    GetPage(
      name: Routes.PASSENGER_TRIP_DETAIL,
      page: () => const PassengerTripDetailView(),
      binding: PassengerTripDetailBinding(),
    ),

    GetPage(
        name: Routes.PASSENGER_HOME,
        page: () =>  PassengerDashboardView(),
        binding: PassengerDashboardBinding()
    ),
    GetPage(
        name: Routes.SEARCH_TRIP,
        page: () =>  SearchTripView(),
        binding: SearchTripBinding()
    ),

    GetPage(
        name: Routes.PROFILE,
        page: () =>  ProfileView(),
        binding: ProfileBinding()
    ),
    GetPage(
      name: Routes.CHAT_DETAIL,
      page: () => ChatDetailView(),
    ),
  ];
}
