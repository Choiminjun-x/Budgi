//
//  TransactionDetailView.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/28/26.
//

import UIKit
import SnapKit

// MARK: ViewEventLogic

protocol TransactionDetailViewEventLogic { }

// MARK: ViewDisplayLogic

protocol TransactionDetailViewDisplayLogic where Self: NSObject {
    func displayDetail(_ model: TransactionDetailViewModel.Detail)
}

enum TransactionDetailViewModel {
    struct Detail {
        let categoryName: String
        let amountText: String
        let amountTint: UIColor
        let dateText: String
        let memoText: String?
    }
}

final class TransactionDetailView: UIView, TransactionDetailViewEventLogic, TransactionDetailViewDisplayLogic {
    
    private let amountLabel = UILabel()
    private let categoryLabel = UILabel()
    private let dateLabel = UILabel()
    private let memoTitleLabel = UILabel()
    private let memoLabel = UILabel()
    
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
    
    static func create() -> TransactionDetailView {
        return TransactionDetailView()
    }
    
    // MARK: MakeViewLayout
    
    private func makeViewLayout() {
        self.backgroundColor = .systemBackground
        
        self.amountLabel.do {
            $0.font = .systemFont(ofSize: 34, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .left
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        self.categoryLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 1
        }
        
        self.dateLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.textColor = .tertiaryLabel
            $0.numberOfLines = 1
        }
        
        self.memoTitleLabel.do {
            $0.text = "메모"
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.textColor = .secondaryLabel
        }
        
        self.memoLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        let topStack = UIStackView(arrangedSubviews: [amountLabel, categoryLabel, dateLabel])
        topStack.axis = .vertical
        topStack.spacing = 6
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 12, right: 20)
        
        let memoStack = UIStackView(arrangedSubviews: [memoTitleLabel, memoLabel])
        memoStack.axis = .vertical
        memoStack.spacing = 8
        memoStack.isLayoutMarginsRelativeArrangement = true
        memoStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        memoStack.backgroundColor = .secondarySystemBackground
        memoStack.layer.cornerRadius = 12
        
        let container = UIStackView(arrangedSubviews: [topStack, memoStack])
        container.axis = .vertical
        container.spacing = 16
        
        self.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    
    // MARK: MakeViewEvents
    
    private func makeEvents() {
        
    }
    
    // MARK: Display
    func displayDetail(_ model: TransactionDetailViewModel.Detail) {
        self.amountLabel.text = model.amountText
        self.amountLabel.textColor = model.amountTint
        self.categoryLabel.text = model.categoryName
        self.dateLabel.text = model.dateText
        if let memo = model.memoText, memo.isEmpty == false {
            self.memoLabel.text = memo
            self.memoLabel.textColor = .label
        } else {
            self.memoLabel.text = "메모 없음"
            self.memoLabel.textColor = .tertiaryLabel
        }
    }
}
