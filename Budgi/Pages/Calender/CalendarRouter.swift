//
//  CalendarRouter.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import Foundation
import RIBs
import UIKit

protocol CalendarInteractable: Interactable, TransactionInputListener, TransactionDetailListener {
    var router: CalendarRouting? { get set }
    var listener: CalendarListener? { get set }
}

protocol CalendarViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CalendarRouter: ViewableRouter<CalendarInteractable, CalendarViewControllable>, CalendarRouting {
    
    private let transactionInputBuilder: TransactionInputBuildable
    private var transactionInputRouting: ViewableRouting?
    
    private let transactionDetailBuilder: TransactionDetailBuildable
    private var transactionDetailRouting: ViewableRouting?
    
    init(interactor: CalendarInteractable,
         viewController: CalendarViewControllable,
         transactionInputBuilder: TransactionInputBuildable,
         transactionDetailBuilder: TransactionDetailBuildable) {
        self.transactionInputBuilder = transactionInputBuilder
        self.transactionDetailBuilder = transactionDetailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    
    // MARK: 내역 입력
    
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
    
    
    // MARK: 내역 상세
    
    func attachTransactionDetail(id: UUID) {
        guard transactionDetailRouting == nil else { return }
        
        let routing = transactionDetailBuilder.build(withListener: interactor, transactionId: id)
        transactionDetailRouting = routing
        attachChild(routing)
        let transactionDetailNavi = UINavigationController(rootViewController: routing.viewControllable.uiviewController)
        transactionDetailNavi.modalPresentationStyle = .fullScreen
        viewController.uiviewController.present(transactionDetailNavi, animated: true)
    }
    
    func detachTransactionDetail() {
        guard let transactionDetailRouting = transactionDetailRouting else { return }
        viewController.uiviewController.dismiss(animated: true)
        detachChild(transactionDetailRouting)
        self.transactionDetailRouting = nil
    }
}
