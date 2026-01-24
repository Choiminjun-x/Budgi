//
//  TransactionInputRouter.swift
//  Budgi
//
//  Created by 최민준 on 1/24/26.
//

import Foundation
import RIBs

protocol TransactionInputInteractable: Interactable {
    var router: TransactionInputRouting? { get set }
    var listener: TransactionInputListener? { get set }
}

protocol TransactionInputViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TransactionInputRouter: ViewableRouter<TransactionInputInteractable, TransactionInputViewControllable>, TransactionInputRouting {
    
    override init(interactor: TransactionInputInteractable,
                  viewController: TransactionInputViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
