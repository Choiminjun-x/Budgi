//
//  TranscationInputInteractor.swift
//  Budgi
//
//  Created by 최민준 on 1/24/26.
//

import Foundation
import RIBs

protocol TransactionInputRouting: ViewableRouting {
    //    func attachTodoListDetail()
    //    func detachTodoListDetail()
}

protocol TransactionInputPresentable: Presentable {
    var listener: TransactionInputPresentableListener? { get set }
    func displaySelectedDate(_ date: Date)
//    func presentPageInfo(pageInfo: CalendarViewModel.PageInfo)
//    func presentPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date)
//    func presentNextMonthInfo(newDays: [CalendarDay], newMonth: Date)
}

public protocol TransactionInputListener: AnyObject {
    func transactionInputDidClose()
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
        
        self.presenter.displaySelectedDate(self.selectedDate)
        self.requestPageInfo()
    }
    
    func requestPageInfo() {
        
    }

    func didTapClose() {
        self.listener?.transactionInputDidClose()
    }
}
