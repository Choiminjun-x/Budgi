//
//  TranscationInputInteractor.swift
//  Budgi
//
//  Created by 최민준 on 1/24/26.
//

import Foundation
import RIBs

protocol TransactionInputRouting: ViewableRouting {
}

protocol TransactionInputPresentable: Presentable {
    var listener: TransactionInputPresentableListener? { get set }
    
    func presentPageInfo(_ date: Date)
}

public protocol TransactionInputListener: AnyObject {
    func transactionInputDidClose()
    func transactionInputDidSave(savedDate: Date)
}

class TransactionInputInteractor: PresentableInteractor<TransactionInputPresentable>, TransactionInputInteractable, TransactionInputPresentableListener {
    
    var router: TransactionInputRouting?
    var listener: TransactionInputListener?
    
    private let selectedDate: Date
    
    init(presenter: TransactionInputPresentable, selectedDate: Date) {
        self.selectedDate = selectedDate
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        self.requestPageInfo()
    }
    
    func requestPageInfo() {
        self.presenter.presentPageInfo(self.selectedDate)
    }

    func didTapSaveButton(amount: Int64, categoryId: String?, memo: String?) {
        /// 1. 생성 - context에 자동 등록
        let transaction = Transaction(context: CoreDataManager.shared.context)
        /// 2. 수정 - context 내부 객체 상태 변경
        transaction.id = UUID()
        transaction.amount = amount
        transaction.categoryId = (categoryId?.isEmpty == false ? categoryId : nil) ?? "uncat"
        transaction.date = self.selectedDate
        transaction.memo = memo
        
        /// 3. 저장 - context에 있는 모든 변경 사항을 저장소에 반영
        CoreDataManager.shared.saveContext()
        
        /// 4. 변경사항 업데이트 - 캘린더
        self.listener?.transactionInputDidSave(savedDate: self.selectedDate)
        
        self.didTapClose()
    }
    
    func didTapClose() {
        self.listener?.transactionInputDidClose()
    }
}
