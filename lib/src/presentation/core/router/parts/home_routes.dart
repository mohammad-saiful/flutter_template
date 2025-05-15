part of '../router.dart';

List<GoRoute> _homeRoutes(ref) {
  return [
    GoRoute(
      path: Routes.homeTab,
      name: Routes.homeTab,
      pageBuilder: (context, state) => const MaterialPage(
        child: HomePage(),
      ),
      routes: [
        GoRoute(
          path: Routes.profile,
          name: Routes.profile,
          pageBuilder: (context, state) => const MaterialPage(
            child: ProfilePage(),
          ),
        ),
        GoRoute(
          path: Routes.report,
          name: Routes.report,
          pageBuilder: (context, state) => const MaterialPage(
            child: ReportPage(),
          ),
        ),
      ],
    ),
  ];
}
