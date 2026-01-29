//
//  TransactionDetailViewController.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/28/26.
//

import Foundation
import Combine
import RIBs

protocol TransactionDetailPresentableListener: AnyObject {
    func requestPageInfo()

    func didTapClose()
}

final class TransactionDetailViewController: UIViewController, TransactionDetailViewControllable {
    
    var listener: TransactionDetailPresentableListener?
    
    var viewController: UIViewController { return self }
    
    
    // MARK: View Event Handling
    
    private var viewEventLogic: TransactionDetailViewEventLogic { self.view as! TransactionDetailViewEventLogic }
    private var viewDisplayLogic: TransactionDetailViewDisplayLogic { self.view as! TransactionDetailViewDisplayLogic }
    
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
        self.navigationItem.title = "내역 상세"
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(didTapClose))
        closeButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func didTapClose() {
        self.listener?.didTapClose()
    }
    
    
    // MARK: View lifecycle
    
    override func loadView() {
        self.view = TransactionDetailView.create()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listener?.requestPageInfo()
    }
}


// MARK: - Presentable

extension TransactionDetailViewController: TransactionDetailPresentable {
    func presentDetail(_ info: TransactionDetailViewModel.Detail) {
        self.viewDisplayLogic.displayDetail(info)
    }
}
