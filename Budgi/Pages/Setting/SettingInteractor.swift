//
//  SettingInteractor.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/22/26.
//

import Foundation
import RIBs

protocol SettingRouting: ViewableRouting {
    //    func attachTodoListDetail()
    //    func detachTodoListDetail()
}

protocol SettingPresentable: Presentable {
    var listener: SettingPresentableListener? { get set }
    
//    func presentPageInfo(pageInfo: CalendarViewModel.PageInfo)
//    func presentPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date)
//    func presentNextMonthInfo(newDays: [CalendarDay], newMonth: Date)
}

public protocol SettingListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

class SettingInteractor: PresentableInteractor<SettingPresentable>, SettingInteractable, SettingPresentableListener {
    
    var router: SettingRouting?
    var listener: SettingListener?
    
    override init(presenter: SettingPresentable) {
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
