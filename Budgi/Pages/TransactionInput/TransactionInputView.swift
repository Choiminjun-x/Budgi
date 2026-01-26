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

protocol TransactionInputViewEventLogic where Self: NSObject {
    var saveButtonDidTap: PassthroughSubject<Int64, Never> { get }
}

// MARK: ViewDisplayLogic

protocol TransactionInputViewDisplayLogic where Self: NSObject {
    func displayPageInfo(_ model: TransactionInputViewModel.PageInfo)
}

enum TransactionInputViewModel {
    struct PageInfo {
   
    }
}


final class TransactionInputView: UIView, TransactionInputViewEventLogic, TransactionInputViewDisplayLogic {
    
    private var amountTextField: UITextField!
    private var expenseButton: UIButton!
    private var incomeButton: UIButton!
    private var typeButtonStackView: UIStackView!
    private var saveButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
    private var isExpenseSelected = true
    
    
    // MARK: EventLogic
    
    var saveButtonDidTap: PassthroughSubject<Int64, Never> = .init()
    
    
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
            
            $0.becomeFirstResponder()
        }
        
        self.expenseButton = UIButton(type: .system).do {
            $0.setTitle("지출", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .systemGray6
            $0.setTitleColor(.label, for: .normal)
            $0.layer.cornerRadius = 12
        }
        
        self.incomeButton = UIButton(type: .system).do {
            $0.setTitle("수입", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .systemGray6
            $0.setTitleColor(.label, for: .normal)
            $0.layer.cornerRadius = 12
        }
        
        self.typeButtonStackView = UIStackView(arrangedSubviews: [self.expenseButton, self.incomeButton]).do {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 12
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.amountTextField.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(48)
            }
        }
        
        self.saveButton = UIButton(type: .system).do {
            $0.setTitle("저장", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .systemBlue
            $0.setTitleColor(.white, for: .normal)
            $0.layer.cornerRadius = 12
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.typeButtonStackView.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
            }
        }
        
        self.updateTypeSelection(isExpense: true)
    }
    
    
    // MARK: MakeViewEvents
    
    private func makeEvents() {
        self.expenseButton.addTarget(self, action: #selector(self.didTapExpense), for: .touchUpInside)
        self.incomeButton.addTarget(self, action: #selector(self.didTapIncome), for: .touchUpInside)
        
        self.saveButton.do {
            $0.tapPublisher
                .sink { _ in
                    let rawAmount = Int64(self.amountTextField.text ?? "0") ?? 0
                    if rawAmount <= 0 {
                        self.amountTextField.layer.borderColor = UIColor.systemRed.cgColor
                        return
                    }
                    self.amountTextField.layer.borderColor = UIColor.separator.cgColor
                    let signedAmount = self.isExpenseSelected ? -abs(rawAmount) : abs(rawAmount)
                    self.saveButtonDidTap.send(signedAmount)
                }.store(in: &cancellables)
        }
    }
    
    // MARK: displayPageInfo
    
    func displayPageInfo(_ model: TransactionInputViewModel.PageInfo) {
        
    }
    
    @objc
    private func didTapExpense() {
        self.updateTypeSelection(isExpense: true)
    }
    
    @objc
    private func didTapIncome() {
        self.updateTypeSelection(isExpense: false)
    }
    
    private func updateTypeSelection(isExpense: Bool) {
        self.isExpenseSelected = isExpense
        
        let selectedColor = UIColor.systemBlue
        let deselectedColor = UIColor.systemGray6
        let selectedTitleColor = UIColor.white
        let deselectedTitleColor = UIColor.label
        
        let expenseSelected = isExpense
        self.expenseButton.backgroundColor = expenseSelected ? selectedColor : deselectedColor
        self.expenseButton.setTitleColor(expenseSelected ? selectedTitleColor : deselectedTitleColor, for: .normal)
        
        let incomeSelected = !isExpense
        self.incomeButton.backgroundColor = incomeSelected ? selectedColor : deselectedColor
        self.incomeButton.setTitleColor(incomeSelected ? selectedTitleColor : deselectedTitleColor, for: .normal)
    }
}
