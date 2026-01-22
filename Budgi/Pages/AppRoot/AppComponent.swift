//
//  AppComponent.swift
//  MyRIBsApp
//
//  Created by 최민준(Minjun Choi) on 9/5/25.
//

import Foundation
import RIBs

final class AppComponent: Component<EmptyDependency>, AppRootDependency {
    
    init() {
        super.init(dependency: EmptyComponent())
    }
}
