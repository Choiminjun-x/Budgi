//
//  TransactionDetailView.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/28/26.
//

import SnapKit
import UIKit

// MARK: ViewEventLogic

protocol TransactionDetailViewEventLogic {}

// MARK: ViewDisplayLogic

protocol TransactionDetailViewDisplayLogic where Self: NSObject {
    func displayPageInfo(_ model: TransactionDetailViewModel.PageInfo)
}

enum TransactionDetailViewModel {
    struct PageInfo {
        let categoryName: String
        let amountText: String
        let amountTint: UIColor
        let dateText: String
        let memoText: String?
    }
}

final class TransactionDetailView: UIView, TransactionDetailViewEventLogic,
                                   TransactionDetailViewDisplayLogic
{
    
    private var amountLabel: UILabel!
    private var categoryLabel: UILabel!
    private var dateLabel: UILabel!
    private var memoTitleLabel: UILabel!
    private var memoLabel: UILabel!
    
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
    
    // MARK: makeViewLayout
    
    private func makeViewLayout() {
        self.backgroundColor = .systemBackground
        
        self.amountLabel = UILabel().do {
            $0.font = .systemFont(ofSize: 34, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .left
            $0.setContentCompressionResistancePriority(
                .required,
                for: .vertical
            )
        }
        
        self.categoryLabel = UILabel().do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 1
        }
        
        self.dateLabel = UILabel().do {
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.textColor = .tertiaryLabel
            $0.numberOfLines = 1
        }
        
        self.memoTitleLabel = UILabel().do {
            $0.text = "메모"
            $0.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.textColor = .secondaryLabel
        }
        
        self.memoLabel = UILabel().do {
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
        
        let topStack = UIStackView(arrangedSubviews: [
            self.amountLabel, self.categoryLabel, self.dateLabel,
        ])
        topStack.axis = .vertical
        topStack.spacing = 6
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.layoutMargins = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 12,
            right: 20
        )
        
        let memoStack = UIStackView(arrangedSubviews: [
            memoTitleLabel, memoLabel,
        ])
        memoStack.axis = .vertical
        memoStack.spacing = 8
        memoStack.isLayoutMarginsRelativeArrangement = true
        memoStack.layoutMargins = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
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
    
    
    // MARK: makeEvents
    
    private func makeEvents() {
        
    }
    
    
    // MARK: displayPageInfo
    
    func displayPageInfo(_ model: TransactionDetailViewModel.PageInfo) {
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
