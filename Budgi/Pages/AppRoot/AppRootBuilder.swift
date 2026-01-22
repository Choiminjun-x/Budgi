//
//  AppRootBuilder.swift
//  RIBs
//
//  Created by 최민준(Minjun Choi) on 9/5/25.
//

import UIKit
import RIBs

protocol AppRootDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class AppRootComponent: Component<AppRootDependency>, HomeDependency, CalendarDependency {
    // Shared app-level dependencies
    let dateGenerator: DateGenerator = CalendarDateGenerator()
}

// MARK: - Builder

protocol AppRootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class AppRootBuilder: Builder<AppRootDependency>, AppRootBuildable {
    
    override init(dependency: AppRootDependency) {
        super.init(dependency: dependency)
    }
    
    func build() -> LaunchRouting {
        let component = AppRootComponent(dependency: dependency)
        let tabBar = MainTabBarController()
        let interactor = AppRootInteractor(presenter: tabBar)
        
        let home = HomeBuilder(dependency: component)
        let calendar = CalendarBuilder(dependency: component)
        
        let router = AppRootRouter(interactor: interactor,
                                   viewController: tabBar,
                                   home: home,
                                   calendar: calendar)
        
        return router
    }
}
