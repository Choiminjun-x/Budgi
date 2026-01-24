//
//  DateCell.swift
//  iOS-StudyHub
//
//  Created by 최민준 on 1/21/26.
//

import UIKit
import SnapKit

class DateCell: UICollectionViewCell {
    
    private var dayLabel: UILabel!
    
    private var transactionList: UIStackView!
    private var desc1: UILabel!
    private var desc2: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.makeViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func makeViewLayout() {
        self.dayLabel = UILabel().do {
            $0.textAlignment = .center
            
            contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
            }
        }
        
        self.transactionList = UIStackView().do { mainStack in
            mainStack.axis = .vertical
            
            contentView.addSubview(mainStack)
            mainStack.snp.makeConstraints {
                $0.top.equalTo(self.dayLabel.snp.bottom).inset(2)
                $0.leading.trailing.equalToSuperview().inset(2)
                $0.bottom.equalToSuperview().inset(2)
            }
            
            UILabel().do {
                $0.text = "45,000"
                $0.textColor = .red
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 12, weight: .regular)
                $0.setContentCompressionResistancePriority(.required, for: .vertical)
                
                mainStack.addArrangedSubview($0)
            }
            
            UILabel().do {
                $0.text = "45,000"
                $0.textColor = .blue
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 12, weight: .regular)
                $0.setContentCompressionResistancePriority(.required, for: .vertical)
                
                mainStack.addArrangedSubview($0)
            }
        }
    }
    
    func displayCellInfo(with day: CalendarDay) {
        let dayNumber = Calendar.current.component(.day, from: day.date)
        self.dayLabel.text = "\(dayNumber)"
        self.dayLabel.font = .systemFont(ofSize: 14, weight: day.isToday ? .bold : .regular)
        
        let weekday = Calendar.current.component(.weekday, from: day.date)
        if day.isToday {
            self.dayLabel.textColor = .red
        } else {
            if !day.isInCurrentMonth {
                self.dayLabel.textColor = .lightGray
            } else if weekday == 1 {
                self.dayLabel.textColor = .red
            } else if weekday == 7 {
                self.dayLabel.textColor = .blue
            } else {
                self.dayLabel.textColor = .label
            }
        }
      
    }
    
    func displaySelectedStyle(_ isSelected: Bool) {
        self.backgroundColor = isSelected ? .gray.withAlphaComponent(0.4) : .white
    }
}
