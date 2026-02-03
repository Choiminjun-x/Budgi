//
//  AppRootRouter.swift
//  MyRIBsApp
//
//  Created by 최민준(Minjun Choi) on 9/5/25.
//

import UIKit
import RIBs

protocol AppRootInteractable: Interactable, SettingListener, CalendarListener {
    var router: AppRootRouting? { get set }
    var listener: AppRootListener? { get set }
}

protocol AppRootViewControllable: ViewControllable {
    func setViewControllers(_ viewControllers: [UIViewController])
}

final class AppRootRouter: LaunchRouter<AppRootInteractable, AppRootViewControllable>, AppRootRouting {
    
    private let calendar: CalendarBuildable
    private let setting: SettingBuildable
    
    private var homeRouting: ViewableRouting?
    private var calendarRouting: ViewableRouting?
    
    init(
        interactor: AppRootInteractable,
        viewController: AppRootViewControllable,
        calendar: CalendarBuildable,
        setting: SettingBuildable
    ) {
        self.calendar = calendar
        self.setting = setting
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func attachTabs() {
        let settingRouting = setting.build(withListener: interactor)
        let calendarRouting = calendar.build(withListener: interactor)
        
        attachChild(calendarRouting)
        attachChild(settingRouting)
        
        let calendarNavi = UINavigationController(rootViewController: calendarRouting.viewControllable.uiviewController)
        calendarNavi.tabBarItem = UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), tag: 1)
        
        let settingNavi = UINavigationController(rootViewController: settingRouting.viewControllable.uiviewController)
        settingNavi.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gearshape"), tag: 1)
        
        // 탭별 네비게이션 바 색상
        let calendarTapAppearance = makeNavAppearance(bgColor: UIColor.systemGreen.withAlphaComponent(0.4))
        calendarNavi.navigationBar.standardAppearance = calendarTapAppearance
        calendarNavi.navigationBar.scrollEdgeAppearance = calendarTapAppearance
        calendarNavi.navigationBar.compactAppearance = calendarTapAppearance
        calendarNavi.navigationBar.tintColor = .white
        
        let settingTapAppearance = makeNavAppearance(bgColor: .white)
        settingNavi.navigationBar.standardAppearance = settingTapAppearance
        settingNavi.navigationBar.scrollEdgeAppearance = settingTapAppearance
        settingNavi.navigationBar.compactAppearance = settingTapAppearance
        settingNavi.navigationBar.tintColor = .white
        
        let viewControllers = [
            calendarNavi,
            settingNavi
        ]
        
        viewController.setViewControllers(viewControllers)
    }
    
    private func makeNavAppearance(bgColor: UIColor) -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bgColor
        appearance.shadowColor = .separator
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        return appearance
    }
}
