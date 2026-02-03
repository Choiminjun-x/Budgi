//
//  TransactionDetailBuilder.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/28/26.
//

import Foundation
import RIBs

protocol TransactionDetailDependency: Dependency {
    
}

final class TransactionDetailComponent: Component<TransactionDetailDependency> {
    
}

public protocol TransactionDetailBuildable: Buildable {
    func build(withListener listener: TransactionDetailListener, transactionId: UUID) -> ViewableRouting
}

class TransactionDetailBuilder: Builder<TransactionDetailDependency>, TransactionDetailBuildable {
    
    public override init(dependency: TransactionDetailDependency) {
        super.init(dependency: dependency)
    }
    
    public func build(withListener listener: TransactionDetailListener, transactionId: UUID) -> ViewableRouting {
        let _ = TransactionDetailComponent(dependency: dependency)
        let viewController = TransactionDetailViewController()
        let interactor = TransactionDetailInteractor(presenter: viewController, transactionId: transactionId)
        interactor.listener = listener
        
        return TransactionDetailRouter(interactor: interactor,
                                       viewController: viewController)
    }
}
