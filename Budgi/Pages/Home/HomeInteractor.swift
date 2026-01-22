//
//  HomeInteractor.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/22/26.
//

import Foundation
import RIBs

protocol HomeRouting: ViewableRouting {
    //    func attachTodoListDetail()
    //    func detachTodoListDetail()
}

protocol HomePresentable: Presentable {
    var listener: HomePresentableListener? { get set }
    
//    func presentPageInfo(pageInfo: CalendarViewModel.PageInfo)
//    func presentPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date)
//    func presentNextMonthInfo(newDays: [CalendarDay], newMonth: Date)
}

public protocol HomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

class HomeInteractor: PresentableInteractor<HomePresentable>, HomeInteractable, HomePresentableListener {
    
    var router: HomeRouting?
    var listener: HomeListener?
    
    override init(presenter: HomePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        self.requestPageInfo()
    }
    
    func requestPageInfo() {
        
    }
}
