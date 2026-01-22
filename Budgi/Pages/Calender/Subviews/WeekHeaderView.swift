//
//  WeekHeaderView.swift
//  iOS-StudyHub
//
//  Created by 최민준 on 1/21/26.
//

import UIKit

final class WeekHeaderView: UIView {
    
    private let days = ["일", "월", "화", "수", "목", "금", "토"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeViewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func makeViewLayout() {
        UIStackView().do { hStack in
            hStack.axis = .horizontal
            hStack.distribution = .fillEqually
            
            self.addSubview(hStack)
            hStack.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            for (index, day) in days.enumerated() {
                UILabel().do {
                    $0.text = day
                    $0.font = .systemFont(ofSize: 13, weight: .medium)
                    $0.textAlignment = .center
                    $0.textColor = index == 0 ? .systemRed : (index == 6 ? .systemBlue : .secondaryLabel)
                    
                    hStack.addArrangedSubview($0)
                }
            }
        }
    }
}
