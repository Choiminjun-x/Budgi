//
//  CalendarInteractor.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import Foundation
import RIBs

protocol CalendarRouting: ViewableRouting {
    func attachTransactionInput(selectedDate: Date)
    func detachTransactionInput()
    func attachTransactionDetail(id: UUID)
    func detachTransactionDetail()
}

protocol CalendarPresentable: Presentable {
    var listener: CalendarPresentableListener? { get set }
    
    func presentPageInfo(pageInfo: CalendarViewModel.PageInfo)
    func presentPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date, transactionsByDay: [Date: [DayTransaction]])
    func presentNextMonthInfo(newDays: [CalendarDay], newMonth: Date, transactionsByDay: [Date: [DayTransaction]])
    func presentUpdatedTransactions(transactionsByDay: [Date: [DayTransaction]])
}

public protocol CalendarListener: AnyObject {
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
    
    
    // MARK: - Calendar Page Info Requests
    
    /// 최초 캘린더 페이지 로딩 시 전체(현재+-2) 월 데이터 및 거래 정보 요청
    func requestPageInfo() {
        let pageInfo = self.loadMonths(around: Date())
        let transactionsByDay = self.makeTransactionsByDay(for: pageInfo.monthBases)
        var updatedPageInfo = pageInfo
        updatedPageInfo.transactionsByDay = transactionsByDay
        self.presenter.presentPageInfo(pageInfo: updatedPageInfo)
    }
    
    /// 이전 달 요청 시, 해당 월의 날짜 및 거래 정보 전달
    func requestPreviousMonthInfo(_ newMonth: Date) {
        let newDays = self.dateGenerator.generateMonthDays(for: newMonth)
        let transactionsByDay = self.makeTransactionsByDay(for: [newMonth])
        self.presenter.presentPreviousMonthInfo(newDays: newDays,
                                                newMonth: newMonth,
                                                transactionsByDay: transactionsByDay)
    }
    
    /// 다음 달 요청 시, 해당 월의 날짜 및 거래 정보 전달
    func requestNewMonthInfo(_ newMonth: Date) {
        let newDays = self.dateGenerator.generateMonthDays(for: newMonth)
        let transactionsByDay = self.makeTransactionsByDay(for: [newMonth])
        self.presenter.presentNextMonthInfo(newDays: newDays,
                                            newMonth: newMonth,
                                            transactionsByDay: transactionsByDay)
    }
    
    
    // MARK: User Actions
    
    /// '+' 버튼 탭 시, 지출 입력 화면 라우팅 요청
    /// - Parameter selectedDate: 선택된 날짜
    func didTapPlusButton(selectedDate: Date) {
        self.router?.attachTransactionInput(selectedDate: selectedDate)
    }
    
    /// 거래 항목 탭 시, 상세 화면 라우팅 요청
    /// - Parameter id: 선택된 거래의 UUID
    func didTapTransactionDetail(id: UUID) {
        self.router?.attachTransactionDetail(id: id)
    }
    
    /// 거래 삭제 시 CoreData에서 삭제 후, 해당 날짜에 대한 거래 내역 갱신
    /// - Parameters:
    ///   - id: 삭제할 거래의 UUID
    ///   - date: 해당 거래가 속한 날짜
    func didTapDeleteTransaction(id: UUID, date: Date) {
        CoreDataManager.shared.deleteTransaction(id: id)
        let transactionsByDay = self.makeTransactionsByDay(for: [date])
        self.presenter.presentUpdatedTransactions(transactionsByDay: transactionsByDay)
    }
}


// MARK: - Data Loading & Mapping

extension CalendarInteractor {
    
    /// 기준 날짜를 중심으로 ±range 개월의 날짜 데이터를 생성합니다.
    /// - Parameters:
    ///   - centerDate: 기준이 되는 날짜
    ///   - range: 앞뒤로 몇 개월을 포함할지 (기본: 2)
    /// - Returns: View에 필요한 월별 날짜 정보 및 섹션 기준 날짜들
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
                     monthBases: monthBases,
                     transactionsByDay: [:])
    }
    
    /// 지정한 월 목록에 대해 CoreData에서 거래 데이터를 불러오고 날짜별로 정리합니다.
    /// - Parameter months: 기준이 되는 각 월의 첫 날짜 배열
    /// - Returns: 날짜별 거래 내역 맵
    private func makeTransactionsByDay(for months: [Date]) -> [Date: [DayTransaction]] {
        var result: [Date: [DayTransaction]] = [:]
        let calendar = Calendar.current
        
        for month in months {
            let transactions = CoreDataManager.shared.fetchTransactions(for: month)
            for transaction in transactions {
                guard let date = transaction.date else { continue }
                let dayKey = calendar.startOfDay(for: date)
                guard let id = transaction.id else { continue }
                let item = DayTransaction(id: id, amount: transaction.amount,
                                          categoryId: transaction.categoryId,
                                          memo: transaction.memo)
                result[dayKey, default: []].append(item)
            }
        }
        
        return result
    }
}


// MARK: - Child RIB Callbacks (Transaction Input)
///
/// 거래 입력 RIB에서 발생하는 이벤트 처리
/// - 입력 화면 종료 처리
/// - 저장 완료 후 캘린더 거래 데이터 갱신
extension CalendarInteractor: TransactionInputListener {
    
    func transactionInputDidClose() {
        self.router?.detachTransactionInput()
    }
    
    /// 거래 저장 완료 시 호출
    /// - Parameter savedDate: 저장된 거래가 속한 날짜
    ///   → 해당 날짜의 거래 목록만 갱신
    func transactionInputDidSave(savedDate: Date) {
        let transactionsByDay = self.makeTransactionsByDay(for: [savedDate])
        self.presenter.presentUpdatedTransactions(transactionsByDay: transactionsByDay)
    }
}


// MARK: - Child RIB Callbacks (Transaction Detail)
///
/// 거래 상세 RIB에서 발생하는 이벤트 처리
/// - 상세 화면 종료 시 detach 처리
extension CalendarInteractor: TransactionDetailListener {
    
    func transactionDetailDidClose() {
        self.router?.detachTransactionDetail()
    }
}
