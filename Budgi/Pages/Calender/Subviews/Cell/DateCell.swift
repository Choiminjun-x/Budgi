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
    private var todayCircleView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.makeViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func makeViewLayout() {
        self.todayCircleView = UIView().do {
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .systemBlue
            $0.isHidden = true
            
            contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.height.equalTo(32)
            }
        }
        
        self.dayLabel = UILabel().do {
            $0.textAlignment = .center
            
            contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    func displayCellInfo(with day: CalendarDay) {
        self.todayCircleView.isHidden = !day.isToday
        
        let dayNumber = Calendar.current.component(.day, from: day.date)
        self.dayLabel.text = "\(dayNumber)"
        self.dayLabel.textColor = day.isToday ? .white : day.isInCurrentMonth ? .label : .lightGray
    }
    
    func displaySelectedStyle(_ isSelected: Bool) {
        self.backgroundColor = isSelected ? .gray.withAlphaComponent(0.4) : .white
    }
}
