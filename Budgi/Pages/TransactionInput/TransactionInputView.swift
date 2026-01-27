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
    var saveButtonDidTap: PassthroughSubject<(Int64, String?), Never> { get }
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
    
    private var typeButtonStackView: UIStackView!
    private var expenseButton: UIButton!
    private var incomeButton: UIButton!
    
    private var categoryCollectionView: UICollectionView!
    private var categoryCollectionHeight: Constraint?
    
    private var saveButton: UIButton!
    
    private var isExpenseSelected = true
    
    private var categories: [Category] = []
    private var allExpenseCategories: [Category] = [] // 지출
    private var allIncomeCategories: [Category] = [] // 수입
    private var selectedCategoryId: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: EventLogic
    
    var saveButtonDidTap: PassthroughSubject<(Int64, String?), Never> = .init()
    
    
    // MARK: instantiate
    
    required init() {
        super.init(frame: .zero)
        
        self.makeViewLayout()
        self.setupCategories()
        self.updateTypeSelection(isExpense: true)
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

        // Category chips collection view (horizontal)
        let layout = UICollectionViewFlowLayout().do {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 8
            $0.minimumInteritemSpacing = 8
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            $0.sectionInset = .zero
        }
        self.categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.isScrollEnabled = false
            $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            $0.register(CategoryChipCell.self, forCellWithReuseIdentifier: CategoryChipCell.reuseId)
            $0.dataSource = self
            $0.delegate = self
            $0.allowsMultipleSelection = false
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.typeButtonStackView.snp.bottom).offset(8)
                $0.leading.trailing.equalToSuperview()
                self.categoryCollectionHeight = $0.height.equalTo(44).priority(.high).constraint
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
                $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
            }
        }
    }
    
    
    // MARK: MakeViewEvents
    
    private func makeEvents() {
        self.expenseButton.do {
            $0.tapPublisher
                .sink { _ in
                    self.updateTypeSelection(isExpense: true)
                }.store(in: &cancellables)
        }
        
        self.incomeButton.do {
            $0.tapPublisher
                .sink { _ in
                    self.updateTypeSelection(isExpense: false)
                }.store(in: &cancellables)
        }
        
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
                    self.saveButtonDidTap.send((signedAmount, self.selectedCategoryId))
                }.store(in: &cancellables)
        }
    }
    
    // MARK: displayPageInfo
    
    func displayPageInfo(_ model: TransactionInputViewModel.PageInfo) {
        
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

        // Update categories for selected type
        self.categories = isExpense ? self.allExpenseCategories : self.allIncomeCategories
        self.categoryCollectionView.reloadData()
        // Select first item by default if available
        if let first = self.categories.first {
            self.selectedCategoryId = first.id
            let indexPath = IndexPath(item: 0, section: 0)
            self.categoryCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            self.selectedCategoryId = nil
        }
        // Update height after layout
        DispatchQueue.main.async { [weak self] in
            self?.updateCategoryCollectionHeight()
        }
    }
}

// MARK: - Category Model

fileprivate struct Category: Hashable {
    enum Kind { case expense, income }
    
    let id: String
    let name: String
    let kind: Kind
}


// MARK: - Data / CollectionView

extension TransactionInputView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    private func setupCategories() {
        self.allExpenseCategories = [
            Category(id: "food", name: "식비", kind: .expense),
            Category(id: "transport", name: "교통", kind: .expense),
            Category(id: "hobby", name: "취미", kind: .expense),
            Category(id: "shopping", name: "쇼핑", kind: .expense),
            Category(id: "life", name: "생활", kind: .expense),
            Category(id: "health", name: "의료", kind: .expense),
            Category(id: "etc_exp", name: "기타", kind: .expense)
        ]
        self.allIncomeCategories = [
            Category(id: "salary", name: "급여", kind: .income),
            Category(id: "bonus", name: "보너스", kind: .income),
            Category(id: "gift", name: "용돈", kind: .income),
            Category(id: "etc_inc", name: "기타", kind: .income)
        ]
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = self.categories[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryChipCell.reuseId, for: indexPath) as! CategoryChipCell
        cell.configure(title: category.name)
        // Apply selection state
        let isSelected = category.id == self.selectedCategoryId
        cell.isSelected = isSelected
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = self.categories[indexPath.item]
        self.selectedCategoryId = category.id
    }
}


// MARK: - Layout Helpers

extension TransactionInputView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep collection height in sync with content
        self.updateCategoryCollectionHeight()
    }

    private func updateCategoryCollectionHeight() {
        self.categoryCollectionView.collectionViewLayout.invalidateLayout()
        self.categoryCollectionView.layoutIfNeeded()
        var height = self.categoryCollectionView.collectionViewLayout.collectionViewContentSize.height
        if height < 44 { height = 44 }
        self.categoryCollectionHeight?.update(offset: height)
    }
}
