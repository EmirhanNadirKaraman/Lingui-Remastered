import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lingui/repositories/refresh_repo.dart';
import 'package:lingui/res/colors.dart';
import 'package:lingui/route/router.gr.dart';
import 'package:lingui/views/common/base/base_view.dart';
import 'package:lingui/views/home/home_model.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Widget _bottomNavBarItem(IconData icon) {
    return Icon(
      icon,
      color: AppColors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final refreshRepo = Provider.of<RefreshRepo>(context);
    return BaseView(
      createModel: (context) => HomeModel(),
      builder: (context, model, size, padding, language) {
        return AutoTabsScaffold(
          lazyLoad: false,
          navigatorObservers: () => [HeroController()],
          routes: const [
            SrsRoute(),
            BaseDictionaryRoute(),
            BaseVideosRoute(),
            ProgressRoute(),
            ProfileRoute()
          ],
          bottomNavigationBuilder: (context, tabsRouter) {
            return CupertinoTabBar(
              currentIndex: tabsRouter.activeIndex,
              backgroundColor: AppColors.background,
              onTap: tabsRouter.setActiveIndex,
              items: [
                BottomNavigationBarItem(
                    icon: _bottomNavBarItem(Icons.edit_outlined),
                    activeIcon: _bottomNavBarItem(Icons.edit)),
                BottomNavigationBarItem(
                  icon: Text(
                    String.fromCharCode(CupertinoIcons.search.codePoint),
                    style: TextStyle(
                      inherit: false,
                      fontSize: 30,
                      color: AppColors.white,
                      fontWeight: FontWeight.w200,
                      fontFamily: CupertinoIcons.search.fontFamily,
                      package: CupertinoIcons.search.fontPackage,
                    ),
                  ),
                  activeIcon: Text(
                    String.fromCharCode(CupertinoIcons.search.codePoint),
                    style: TextStyle(
                      inherit: false,
                      fontSize: 30,
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                      fontFamily: CupertinoIcons.search.fontFamily,
                      package: CupertinoIcons.search.fontPackage,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                    icon: _bottomNavBarItem(Icons.video_collection_outlined),
                    activeIcon:
                        _bottomNavBarItem(Icons.video_collection_rounded)),
                BottomNavigationBarItem(
                    icon: _bottomNavBarItem(Icons.text_snippet_outlined),
                    activeIcon: _bottomNavBarItem(Icons.text_snippet_rounded)),
                BottomNavigationBarItem(
                    icon: _bottomNavBarItem(CupertinoIcons.person_crop_circle),
                    activeIcon: _bottomNavBarItem(
                        CupertinoIcons.person_crop_circle_fill)),
              ],
            );
          },
        );
      },
    );
  }
}
