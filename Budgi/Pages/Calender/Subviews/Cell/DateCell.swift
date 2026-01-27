//
//  DateCell.swift
//  iOS-StudyHub
//
//  Created by 최민준 on 1/21/26.
//

import UIKit
import SnapKit

struct DateCellModel {
    var day: CalendarDay
    var amounts: [Int64]
}

class DateCell: UICollectionViewCell {
    
    private var dayLabel: UILabel!
    private var transactionList: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.makeViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func makeViewLayout() {
        self.layer.cornerRadius = 8
        
        self.dayLabel = UILabel().do {
            $0.font = .systemFont(ofSize: 13, weight: .regular)
            $0.textAlignment = .center
            $0.setContentHuggingPriority(.init(1000), for: .vertical)
            
            contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().inset(2)
                $0.centerX.equalToSuperview()
            }
        }
        
        self.transactionList = UIStackView().do { mainStack in
            mainStack.axis = .vertical
            mainStack.alignment = .fill
            mainStack.distribution = .fill
            mainStack.spacing = 2
            
            contentView.addSubview(mainStack)
            mainStack.snp.makeConstraints {
                $0.top.equalTo(self.dayLabel.snp.bottom).inset(-2)
                $0.leading.trailing.equalToSuperview().inset(2)
                $0.bottom.equalToSuperview().inset(2)
            }
        }
    }
    
    func displayCellInfo(cellModel: DateCellModel) {
        let dayNumber = Calendar.current.component(.day, from: cellModel.day.date)
        self.dayLabel.text = "\(dayNumber)"
        self.dayLabel.font = .systemFont(ofSize: 14, weight: cellModel.day.isToday ? .bold : .regular)
        
        let weekday = Calendar.current.component(.weekday, from: cellModel.day.date)
        if cellModel.day.isToday {
            self.dayLabel.textColor = .red
        } else {
            if !cellModel.day.isInCurrentMonth {
                self.dayLabel.textColor = .lightGray
            } else if weekday == 1 {
                self.dayLabel.textColor = .red
            } else if weekday == 7 {
                self.dayLabel.textColor = .blue
            } else {
                self.dayLabel.textColor = .label
            }
        }
        
        self.displayTransactionAmounts(cellModel.amounts)
    }
    
    func displaySelectedStyle(_ isSelected: Bool) {
        self.backgroundColor = isSelected ? UIColor.secondarySystemBackground : .white
    }

    private func displayTransactionAmounts(_ amounts: [Int64]) {
        self.transactionList.arrangedSubviews.forEach {
            self.transactionList.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        guard !amounts.isEmpty else { return }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        for amount in amounts.prefix(2) {
            let absoluteValue = abs(amount)
            let formatted = formatter.string(from: NSNumber(value: absoluteValue)) ?? "\(absoluteValue)"
            let isExpense = amount < 0
            let text = (isExpense ? "-" : "+") + formatted
            UILabel().do {
                $0.text = text
                $0.textColor = isExpense ? .systemBlue : .systemRed
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 11, weight: .regular)
                $0.setContentCompressionResistancePriority(.required, for: .vertical)
                
                self.transactionList.addArrangedSubview($0)
            }
        }
        
        // Spacer
        UIView().do {
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            self.transactionList.addArrangedSubview($0)
        }
    }
}
