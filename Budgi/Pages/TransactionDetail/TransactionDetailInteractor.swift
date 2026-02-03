//
//  TransactionDetailInteractor.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/28/26.
//

import Foundation
import UIKit
import RIBs

protocol TransactionDetailRouting: ViewableRouting {
}

protocol TransactionDetailPresentable: Presentable {
    var listener: TransactionDetailPresentableListener? { get set }
    func presentPageInfo(_ transaction: Transaction)
}

public protocol TransactionDetailListener: AnyObject {
    func transactionDetailDidClose()
}

class TransactionDetailInteractor: PresentableInteractor<TransactionDetailPresentable>, TransactionDetailInteractable, TransactionDetailPresentableListener {
    
    var router: TransactionDetailRouting?
    var listener: TransactionDetailListener?
    private let transactionId: UUID
    
    init(presenter: TransactionDetailPresentable, transactionId: UUID) {
        self.transactionId = transactionId
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        self.requestPageInfo()
    }
    
    func requestPageInfo() {
        guard let transaction = CoreDataManager.shared.fetchTransaction(id: transactionId) else {
            return
        }
        
        self.presenter.presentPageInfo(transaction)
    }
    
    func didTapClose() {
        self.listener?.transactionDetailDidClose()
    }
}
