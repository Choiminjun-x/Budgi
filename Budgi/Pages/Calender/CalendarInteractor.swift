//
//  CalendarInteractor.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import Foundation
import RIBs

protocol CalendarRouting: ViewableRouting {
    //    func attachTodoListDetail()
    //    func detachTodoListDetail()
}

protocol CalendarPresentable: Presentable {
    var listener: CalendarPresentableListener? { get set }
    
    func presentPageInfo(pageInfo: CalendarViewModel.PageInfo)
    func presentPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date)
    func presentNextMonthInfo(newDays: [CalendarDay], newMonth: Date)
}

public protocol CalendarListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

class CalendarInteractor: PresentableInteractor<CalendarPresentable>, CalendarInteractable, CalendarPresentableListener {
    
    var router: CalendarRouting?
    var listener: CalendarListener?
    
    private let dateGenerator: DateGenerator
    
    init(presenter: CalendarPresentable, dateGenerator: DateGenerator) {
        self.dateGenerator = dateGenerator
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        self.requestPageInfo()
    }
    
    func requestPageInfo() {
        let pageInfo = self.loadMonths(around: Date())
        self.presenter.presentPageInfo(pageInfo: pageInfo)
    }
    
    func requestPreviousMonthInfo(_ newMonth: Date) {
        let newDays = self.dateGenerator.generateMonthDays(for: newMonth)
        self.presenter.presentPreviousMonthInfo(newDays: newDays,
                                                newMonth: newMonth)
    }
    
    func requestNewMonthInfo(_ newMonth: Date) {
        let newDays = self.dateGenerator.generateMonthDays(for: newMonth)
        self.presenter.presentNextMonthInfo(newDays: newDays,
                                            newMonth: newMonth)
    }
    
    private func loadMonths(around centerDate: Date, range: Int = 2) -> CalendarViewModel.PageInfo {
        var months = [[CalendarDay]]()
        var monthBases = [Date]() // 각 섹션에 해당하는 월의 첫날들
        
        // 최초 ±2개월 (총 5개월) 로드
        for offset in -range...range {
            if let monthStart = Calendar.current.date(byAdding: .month, value: offset, to: centerDate) {
                monthBases.append(monthStart)
                months.append(self.dateGenerator.generateMonthDays(for: monthStart))
            }
        }
        
        return .init(months: months,
                     monthBases: monthBases)
    }
}
