//
//  AppRootRouter.swift
//  MyRIBsApp
//
//  Created by 최민준(Minjun Choi) on 9/5/25.
//

import UIKit
import RIBs

protocol AppRootInteractable: Interactable, HomeListener, CalendarListener {
    var router: AppRootRouting? { get set }
    var listener: AppRootListener? { get set }
}

protocol AppRootViewControllable: ViewControllable {
    func setViewControllers(_ viewControllers: [UIViewController])
}

final class AppRootRouter: LaunchRouter<AppRootInteractable, AppRootViewControllable>, AppRootRouting {
  
    private let home: HomeBuildable
    private let calendar: CalendarBuildable
    
    private var homeRouting: ViewableRouting?
    private var calendarRouting: ViewableRouting?
    
    init(
        interactor: AppRootInteractable,
        viewController: AppRootViewControllable,
        home: HomeBuildable,
        calendar: CalendarBuildable
    ) {
        self.home = home
        self.calendar = calendar

        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func attachTabs() {
        let homeRouting = home.build(withListener: interactor)
        let calendarRouting = calendar.build(withListener: interactor)
        
        attachChild(homeRouting)
        attachChild(calendarRouting)
        
        let homeNavi = UINavigationController(rootViewController: homeRouting.viewControllable.uiviewController)
        homeNavi.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 1)
        
        let calendarNavi = UINavigationController(rootViewController: calendarRouting.viewControllable.uiviewController)
        calendarNavi.tabBarItem = UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), tag: 1)
        
        let viewControllers = [
            homeNavi,
            calendarNavi
        ]
        
        viewController.setViewControllers(viewControllers)
    }
}
