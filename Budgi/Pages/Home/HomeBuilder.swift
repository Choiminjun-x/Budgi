//
//  HomeBuilder.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/22/26.
//

import Foundation
import RIBs

protocol HomeDependency: Dependency {
    
}

final class HomeComponent: Component<HomeDependency> {
    
}

public protocol HomeBuildable: Buildable {
    func build(withListener listener: HomeListener) -> ViewableRouting
}

class HomeBuilder: Builder<HomeDependency>, HomeBuildable {
    
    public override init(dependency: HomeDependency) {
      super.init(dependency: dependency)
    }
    
    public func build(withListener listener: HomeListener) -> ViewableRouting {
        let component = HomeComponent(dependency: dependency)
        let viewController = HomeViewController()
        let interactor = HomeInteractor(presenter: viewController)
        interactor.listener = listener
        
        return HomeRouter(interactor: interactor,
                              viewController: viewController)
    }
}
