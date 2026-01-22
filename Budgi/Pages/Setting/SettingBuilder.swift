//
//  SettingBuilder.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/22/26.
//

import Foundation
import RIBs

protocol SettingDependency: Dependency {
    
}

final class SettingComponent: Component<SettingDependency> {
    
}

public protocol SettingBuildable: Buildable {
    func build(withListener listener: SettingListener) -> ViewableRouting
}

class SettingBuilder: Builder<SettingDependency>, SettingBuildable {
    
    public override init(dependency: SettingDependency) {
      super.init(dependency: dependency)
    }
    
    public func build(withListener listener: SettingListener) -> ViewableRouting {
        let component = SettingComponent(dependency: dependency)
        let viewController = SettingViewController()
        let interactor = SettingInteractor(presenter: viewController)
        interactor.listener = listener
        
        return SettingRouter(interactor: interactor,
                              viewController: viewController)
    }
}
