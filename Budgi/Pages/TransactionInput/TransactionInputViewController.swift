//
//  TranscationInputViewController.swift
//  Budgi
//
//  Created by 최민준 on 1/24/26.
//

import Combine
import UIKit

protocol TransactionInputPresentableListener: AnyObject {
    func requestPageInfo()

    func didTapClose()
    func didTapSaveButton(amount: Int64, categoryId: String?, memo: String?)
}

final class TransactionInputViewController: UIViewController,
    TransactionInputViewControllable
{

    var listener: TransactionInputPresentableListener?

    var viewController: UIViewController { return self }

    // MARK: View Event Handling

    private var viewEventLogic: TransactionInputViewEventLogic {
        self.view as! TransactionInputViewEventLogic
    }
    private var viewDisplayLogic: TransactionInputViewDisplayLogic {
        self.view as! TransactionInputViewDisplayLogic
    }

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
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        closeButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = closeButton
    }

    @objc private func didTapClose() {
        self.listener?.didTapClose()
    }

    // MARK: View lifecycle

    override func loadView() {
        self.view = TransactionInputView.create()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewEventLogic.do {
            $0.saveButtonDidTap
                .sink { [weak self] (amount, categoryId, memo) in
                    self?.listener?.didTapSaveButton(
                        amount: amount,
                        categoryId: categoryId,
                        memo: memo
                    )
                }.store(in: &cancellables)
        }
    }
}

// MARK: - Presentable

extension TransactionInputViewController: TransactionInputPresentable {
    
    func presentPageInfo(_ date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy/MM/dd"
        let dateTitle = formatter.string(from: date)
        let dateItem = UIBarButtonItem(
            title: dateTitle,
            style: .plain,
            target: nil,
            action: nil
        )
        dateItem.isEnabled = false
        dateItem.tintColor = .black
        
        self.navigationItem.leftBarButtonItem = dateItem
    }
}
