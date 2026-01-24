//
//  CalendarRouter.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import Foundation
import RIBs

protocol CalendarInteractable: Interactable, TransactionInputListener {
    var router: CalendarRouting? { get set }
    var listener: CalendarListener? { get set }
}

protocol CalendarViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CalendarRouter: ViewableRouter<CalendarInteractable, CalendarViewControllable>, CalendarRouting {

    private let transactionInputBuilder: TransactionInputBuildable
    private var transactionInputRouting: ViewableRouting?

    init(interactor: CalendarInteractable,
                  viewController: CalendarViewControllable,
                  transactionInputBuilder: TransactionInputBuildable) {
        self.transactionInputBuilder = transactionInputBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func attachTransactionInput(selectedDate: Date) {
        guard transactionInputRouting == nil else { return }

        let transactionInput = transactionInputBuilder.build(withListener: interactor, selectedDate: selectedDate)
        transactionInputRouting = transactionInput
        attachChild(transactionInput)
        let transactionInputNavi = UINavigationController(rootViewController: transactionInput.viewControllable.uiviewController)
        transactionInputNavi.modalPresentationStyle = .fullScreen
        viewController.uiviewController.present(transactionInputNavi, animated: true)
    }

    func detachTransactionInput() {
        guard let transactionInputRouting = transactionInputRouting else { return }
        viewController.uiviewController.dismiss(animated: true)
        detachChild(transactionInputRouting)
        self.transactionInputRouting = nil
    }
}
