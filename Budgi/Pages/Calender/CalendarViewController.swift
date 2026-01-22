//
//  CalendarViewController.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import UIKit
import Combine

protocol CalendarPresentableListener: AnyObject {
    func requestPageInfo()
    func requestPreviousMonthInfo(_ newMonth: Date)
    func requestNewMonthInfo(_ newMonth: Date)

//    func didTapRefreshButton()
//    func didTapTodoItem(todo: Todo?)
//    func didToggleTodo(id: Int)
}

final class CalendarViewController: UIViewController, CalendarViewControllable {
    
    var listener: CalendarPresentableListener?
    
    var viewController: UIViewController { return self }

    
    // MARK: View Event Handling
    
    private var viewEventLogic: CalendarViewEventLogic { self.view as! CalendarViewEventLogic }
    private var viewDisplayLogic: CalendarViewDisplayLogic { self.view as! CalendarViewDisplayLogic }
    
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: instantiate
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setupNavigation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    deinit {
        print(type(of: self), #function)
    }
    
    
    // MARK: Setup Navigation
    
    private func setupNavigation() {
        
    }
    
    
    // MARK: View lifecycle
    
    override func loadView() {
        self.view = CalendarView.create()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewEventLogic.do {
            $0.requestPreviousMonthInfo.sink { newMonth in
                self.listener?.requestPreviousMonthInfo(newMonth)
            }.store(in: &cancellables)
            
            $0.requestNextMonthInfo.sink { newMonth in
                self.listener?.requestNewMonthInfo(newMonth)
            }.store(in: &cancellables)
        }
        
        self.viewDisplayLogic.do {
            $0.displayNaviTitle.sink { text in
                self.navigationItem.title = text
            }.store(in: &cancellables)
        }
    }
}


// MARK: - Presentable

extension CalendarViewController: CalendarPresentable {
    
    func presentPageInfo(pageInfo: CalendarViewModel.PageInfo) {
        self.viewDisplayLogic.displayPageInfo(pageInfo)
    }
    
    func presentPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date) {
        self.viewDisplayLogic.displayPreviousMonthInfo(newDays: newDays,
                                                       newMonth: newMonth)
    }
    
    func presentNextMonthInfo(newDays: [CalendarDay], newMonth: Date) {
        self.viewDisplayLogic.displayNextMonthInfo(newDays: newDays,
                                                   newMonth: newMonth)
    }
}
