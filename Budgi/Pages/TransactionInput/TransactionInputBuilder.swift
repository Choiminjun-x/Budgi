//
//  TransactionInputBuilder.swift
//  Budgi
//
//  Created by 최민준 on 1/24/26.
//

import Foundation
import RIBs

protocol TransactionInputDependency: Dependency {
    
}

final class TransactionInputComponent: Component<TransactionInputDependency> {
    
}

public protocol TransactionInputBuildable: Buildable {
    func build(withListener listener: TransactionInputListener, selectedDate: Date) -> ViewableRouting
}

class TransactionInputBuilder: Builder<TransactionInputDependency>, TransactionInputBuildable {
    
    public override init(dependency: TransactionInputDependency) {
        super.init(dependency: dependency)
    }
    
    public func build(withListener listener: TransactionInputListener, selectedDate: Date) -> ViewableRouting {
        let _ = TransactionInputComponent(dependency: dependency)
        let viewController = TransactionInputViewController()
        let interactor = TransactionInputInteractor(presenter: viewController, selectedDate: selectedDate)
        interactor.listener = listener
        
        return TransactionInputRouter(interactor: interactor,
                                      viewController: viewController)
    }
}
