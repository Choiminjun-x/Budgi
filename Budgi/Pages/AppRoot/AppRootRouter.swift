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
        
        
        let viewControllers = [
            calendarNavi,
            settingNavi
        ]
        
        viewController.setViewControllers(viewControllers)
    }
}
