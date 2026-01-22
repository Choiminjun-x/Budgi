//
//  SettingViewController.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import UIKit
import Combine

protocol SettingPresentableListener: AnyObject {
    func requestPageInfo()

//    func didTapRefreshButton()
//    func didTapTodoItem(todo: Todo?)
//    func didToggleTodo(id: Int)
}

final class SettingViewController: UIViewController, SettingViewControllable {
    
    var listener: SettingPresentableListener?
    
    var viewController: UIViewController { return self }
    
    // MARK: View Event Handling
    
    private var viewEventLogic: SettingViewEventLogic { self.view as! SettingViewEventLogic }
    private var viewDisplayLogic: SettingViewDisplayLogic { self.view as! SettingViewDisplayLogic }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: instantiate
    
    deinit {
        print(type(of: self), #function)
    }
    
    // MARK: Setup Navigation
    
    private func setupNavigation() {
        
    }
    
    // MARK: View lifecycle
    
    override func loadView() {
        self.view = SettingView.create()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


// MARK: - Presentable

extension SettingViewController: SettingPresentable {

}
