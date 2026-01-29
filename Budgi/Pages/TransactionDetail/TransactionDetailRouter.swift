//
//  TransactionDetailRouter.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/28/26.
//

import Foundation
import RIBs

protocol TransactionDetailInteractable: Interactable {
    var router: TransactionDetailRouting? { get set }
    var listener: TransactionDetailListener? { get set }
}

protocol TransactionDetailViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TransactionDetailRouter: ViewableRouter<TransactionDetailInteractable, TransactionDetailViewControllable>, TransactionDetailRouting {
    
    override init(interactor: TransactionDetailInteractable,
                  viewController: TransactionDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
