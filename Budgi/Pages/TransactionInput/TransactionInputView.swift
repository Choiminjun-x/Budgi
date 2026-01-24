//
//  TransactionInputView.swift
//  Budgi
//
//  Created by 최민준 on 1/24/26.
//

import UIKit
import Combine
import SnapKit

// MARK: ViewEventLogic

protocol TransactionInputViewEventLogic {
    
}

// MARK: ViewDisplayLogic

protocol TransactionInputViewDisplayLogic {
    func focusAmountInput()
}

final class TransactionInputView: UIView, TransactionInputViewEventLogic, TransactionInputViewDisplayLogic {
    
    private var amountTextField: UITextField!
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: instantiate
    
    required init() {
        super.init(frame: .zero)
        
        self.makeViewLayout()
        self.makeEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        print(type(of: self), #function)
    }
    
    static func create() -> TransactionInputView {
        return TransactionInputView()
    }
    
    // MARK: MakeViewLayout
    
    private func makeViewLayout() {
        self.backgroundColor = .white
        
        self.amountTextField = UITextField().do {
            $0.placeholder = "금액 입력"
            $0.keyboardType = .numberPad
            $0.textAlignment = .right
            $0.font = .systemFont(ofSize: 34, weight: .semibold)
            $0.textColor = .label
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.separator.cgColor
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
            $0.leftViewMode = .always
            $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
            $0.rightViewMode = .always
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(16)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(88)
            }
        }
    }

    func focusAmountInput() {
        self.amountTextField.becomeFirstResponder()
    }
    
    
    // MARK: MakeViewEvents
    
    private func makeEvents() {
        
    }
}
