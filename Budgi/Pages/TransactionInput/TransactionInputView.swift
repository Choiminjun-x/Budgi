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
    var saveButtonDidTap: PassthroughSubject<(Int64, String?, String?), Never> { get }
}

// MARK: ViewDisplayLogic

protocol TransactionInputViewDisplayLogic where Self: NSObject {
    func displayPageInfo(_ model: TransactionInputViewModel.PageInfo)
}

enum TransactionInputViewModel {
    struct PageInfo {
        
    }
}


// MARK: - Category Model

fileprivate struct Category: Hashable {
    enum Kind { case expense, income }
    
    let id: String
    let name: String
    let type: Kind
}

final class TransactionInputView: UIView, TransactionInputViewEventLogic, TransactionInputViewDisplayLogic {

    private var amountTitleLabel: UILabel!
    private var amountTextFieldContainer: UIView!
    private var amountTextField: UITextField!
    
    private var typeTitleLabel: UILabel!
    private var typeButtonStackView: UIStackView!
    private var expenseButton: UIButton!
    private var incomeButton: UIButton!
    
    private var categoryTitleLabel: UILabel!
    private var categoryCollectionView: UICollectionView!
    private var categoryCollectionHeight: Constraint?
    
    private var memoTitleLabel: UILabel!
    private var memoTextView: UITextView!
    private var memoPlaceholderLabel: UILabel!
    private var memoHeight: Constraint?
    
    private var saveButton: UIButton!
    private var saveButtonBottom: Constraint?
    
    private var isExpenseSelected = true
    
    private var categories: [Category] = []
    private var allExpenseCategories: [Category] = [] // 지출
    private var allIncomeCategories: [Category] = [] // 수입
    private var selectedCategoryId: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: EventLogic
    
    var saveButtonDidTap: PassthroughSubject<(Int64, String?, String?), Never> = .init()
    
    
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
    
    
    // MARK: layoutSubviews
    
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
    
    private func setupCategories() {
        self.allExpenseCategories = [
            Category(id: "food", name: "식비", type: .expense),
            Category(id: "transport", name: "교통", type: .expense),
            Category(id: "hobby", name: "취미", type: .expense),
            Category(id: "shopping", name: "쇼핑", type: .expense),
            Category(id: "life", name: "생활", type: .expense),
            Category(id: "health", name: "의료", type: .expense),
            Category(id: "etc_exp", name: "기타", type: .expense)
        ]
        self.allIncomeCategories = [
            Category(id: "salary", name: "급여", type: .income),
            Category(id: "bonus", name: "보너스", type: .income),
            Category(id: "gift", name: "용돈", type: .income),
            Category(id: "etc_inc", name: "기타", type: .income)
        ]
    }
    
    
    // MARK: makeViewLayout
    
    private func makeViewLayout() {
        self.backgroundColor = .systemGroupedBackground
        
        self.amountTitleLabel = UILabel().do {
            $0.text = "금액"
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .secondaryLabel
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(12)
                $0.leading.trailing.equalToSuperview().inset(20)
            }
        }
        
        self.amountTextFieldContainer = UIView().do { container in
            container.backgroundColor = .secondarySystemGroupedBackground
            container.layer.cornerRadius = 14
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor.separator.cgColor
            
            self.addSubview(container)
            container.snp.makeConstraints {
                $0.top.equalTo(self.amountTitleLabel.snp.bottom).offset(6)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(72)
            }
            
            let currencyLabel = UILabel().do {
                $0.text = "₩"
                $0.textColor = .secondaryLabel
                $0.font = .systemFont(ofSize: 18, weight: .regular)
                container.addSubview($0)
                $0.snp.makeConstraints {
                    $0.leading.equalToSuperview().inset(16)
                    $0.centerY.equalToSuperview()
                }
            }
            
            self.amountTextField = UITextField().do {
                $0.placeholder = "0"
                $0.keyboardType = .numberPad
                $0.textAlignment = .right
                let base = UIFont.systemFont(ofSize: 34, weight: .semibold)
                $0.font = UIFont.monospacedDigitSystemFont(ofSize: base.pointSize, weight: .semibold)
                $0.textColor = .label
                $0.backgroundColor = .clear
                $0.borderStyle = .none
                $0.addTarget(self, action: #selector(self.amountEditingChanged), for: .editingChanged)
                
                container.addSubview($0)
                $0.snp.makeConstraints {
                    $0.leading.greaterThanOrEqualTo(currencyLabel.snp.trailing).offset(8)
                    $0.trailing.equalToSuperview().inset(16)
                    $0.centerY.equalToSuperview()
                }
                
                $0.becomeFirstResponder()
            }
        }
        
        self.typeTitleLabel = UILabel().do {
            $0.text = "유형"
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .secondaryLabel
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.amountTextFieldContainer.snp.bottom).offset(14)
                $0.leading.trailing.equalToSuperview().inset(20)
            }
        }
        
        self.expenseButton = UIButton(type: .system).do {
            $0.setTitle("지출", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .tertiarySystemFill
            $0.setTitleColor(.label, for: .normal)
            $0.layer.cornerRadius = 12
        }
        
        self.incomeButton = UIButton(type: .system).do {
            $0.setTitle("수입", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.backgroundColor = .tertiarySystemFill
            $0.setTitleColor(.label, for: .normal)
            $0.layer.cornerRadius = 12
        }
        
        self.typeButtonStackView = UIStackView(arrangedSubviews: [self.expenseButton, self.incomeButton]).do {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 12
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.typeTitleLabel.snp.bottom).offset(6)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(48)
            }
        }
   
        let layout = UICollectionViewFlowLayout().do {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 8
            $0.minimumInteritemSpacing = 8
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            $0.sectionInset = .zero
        }
        self.categoryTitleLabel = UILabel().do {
            $0.text = "카테고리"
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .secondaryLabel
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.typeButtonStackView.snp.bottom).offset(14)
                $0.leading.trailing.equalToSuperview().inset(20)
            }
        }
        
        self.categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.isScrollEnabled = false
            $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            $0.register(CategoryChipCell.self, forCellWithReuseIdentifier: CategoryChipCell.reusableId)
            $0.dataSource = self
            $0.delegate = self
            $0.allowsMultipleSelection = false
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.categoryTitleLabel.snp.bottom).offset(6)
                $0.leading.trailing.equalToSuperview()
                self.categoryCollectionHeight = $0.height.equalTo(44).priority(.high).constraint
            }
        }
        
        self.memoTitleLabel = UILabel().do {
            $0.text = "메모"
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textColor = .secondaryLabel
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.categoryCollectionView.snp.bottom).offset(14)
                $0.leading.trailing.equalToSuperview().inset(20)
            }
        }
        
        self.memoTextView = UITextView().do {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .label
            $0.backgroundColor = .tertiarySystemGroupedBackground
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.separator.cgColor
            $0.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            $0.isScrollEnabled = false
            $0.delegate = self
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.memoTitleLabel.snp.bottom).offset(6)
                $0.leading.trailing.equalToSuperview().inset(20)
                self.memoHeight = $0.height.equalTo(44).priority(.high).constraint
            }
        }
        
        self.memoPlaceholderLabel = UILabel().do {
            $0.text = "메모(선택)"
            $0.textColor = .placeholderText
            $0.font = .systemFont(ofSize: 16)
            self.memoTextView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().inset(10)
                $0.leading.equalToSuperview().inset(16)
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
                $0.top.equalTo(self.memoTextView.snp.bottom).offset(12)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(52)
            }
        }
    }
    
    
    // MARK: makeEvents
    
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
                    let memo = self.memoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    let memoOrNil = memo.isEmpty ? nil : memo
                    self.saveButtonDidTap.send((signedAmount, self.selectedCategoryId, memoOrNil))
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
        
        self.categories = isExpense ? self.allExpenseCategories : self.allIncomeCategories
        self.categoryCollectionView.reloadData()
        
        if let first = self.categories.first {
            self.selectedCategoryId = first.id
            let indexPath = IndexPath(item: 0, section: 0)
            self.categoryCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            self.selectedCategoryId = nil
        }
    
        DispatchQueue.main.async { [weak self] in
            self?.updateCategoryCollectionHeight()
        }
        
        self.updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let rawAmount = Int64(self.amountTextField.text ?? "0") ?? 0
        let enabled = rawAmount > 0
        self.saveButton.isEnabled = enabled
        UIView.animate(withDuration: 0.2) {
            self.saveButton.backgroundColor = enabled ? .systemBlue : .systemGray4
        }
    }
    
    @objc private func amountEditingChanged() {
        self.amountTextField.layer.borderColor = UIColor.separator.cgColor
        self.updateSaveButtonState()
    }
}


// MARK: - Data / CollectionView

extension TransactionInputView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = self.categories[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryChipCell.reusableId, for: indexPath) as! CategoryChipCell
        cell.displayCell(title: category.name)
        let isSelected = category.id == self.selectedCategoryId
        cell.isSelected = isSelected
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = self.categories[indexPath.item]
        self.selectedCategoryId = category.id
    }
}


// MARK: - UITextViewDelegate

extension TransactionInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.memoPlaceholderLabel.isHidden = !textView.text.isEmpty
        let targetWidth = textView.bounds.width
        let size = textView.sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude))
        let clamped = min(max(44, size.height), 120)
        self.memoHeight?.update(offset: clamped)
        self.layoutIfNeeded()
    }
}
