//
//  HomeViewController.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import UIKit
import Combine

protocol HomePresentableListener: AnyObject {
    func requestPageInfo()

//    func didTapRefreshButton()
//    func didTapTodoItem(todo: Todo?)
//    func didToggleTodo(id: Int)
}

final class HomeViewController: UIViewController, HomeViewControllable {
    
    var listener: HomePresentableListener?
    
    var viewController: UIViewController { return self }
    
    // MARK: View Event Handling
    
    private var viewEventLogic: HomeViewEventLogic { self.view as! HomeViewEventLogic }
    private var viewDisplayLogic: HomeViewDisplayLogic { self.view as! HomeViewDisplayLogic }
    
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
        self.view = HomeView.create()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


// MARK: - Presentable

extension HomeViewController: HomePresentable {

}
