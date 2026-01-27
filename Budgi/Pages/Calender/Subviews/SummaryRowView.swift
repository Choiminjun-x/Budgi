//
//  SummaryRowView.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/27/26.
//

import UIKit

final class SummaryRowView: UIView {
    private let dotView = UIView()
    private let categoryLabel = UILabel()
    private let amountLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    
    var onTapDelete: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { nil }
    
    private func setup() {
        self.backgroundColor = UIColor.secondarySystemBackground
        self.layer.cornerRadius = 12
        
        self.dotView.do {
            $0.layer.cornerRadius = 4
            $0.snp.makeConstraints { $0.size.equalTo(CGSize(width: 8, height: 8)) }
        }
        
        self.categoryLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        self.amountLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .label
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        self.deleteButton.do {
            $0.setImage(UIImage(systemName: "trash"), for: .normal)
            $0.tintColor = .tertiaryLabel
            $0.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        }
        
        let leftStack = UIStackView(arrangedSubviews: [dotView, categoryLabel])
        leftStack.axis = .horizontal
        leftStack.alignment = .center
        leftStack.spacing = 8
        
        let hStack = UIStackView(arrangedSubviews: [leftStack, amountLabel, deleteButton])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 8
        
        self.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        }
    }
    
    func configure(category: String, amountText: String, tint: UIColor) {
        self.dotView.backgroundColor = tint
        self.categoryLabel.text = category
        self.amountLabel.text = amountText
        self.amountLabel.textColor = tint
    }
    
    @objc private func didTapDelete() {
        onTapDelete?()
    }
}
