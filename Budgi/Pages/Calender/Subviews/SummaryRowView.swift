//
//  SummaryRowView.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/27/26.
//

import UIKit
import SnapKit

final class SummaryRowView: UIView {
    private let dotView = UIView()
    private let categoryLabel = UILabel()
    private let memoLabel = UILabel()
    private let amountLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    private let selectOverlayButton = UIButton(type: .custom)
    
    var onTapDelete: (() -> Void)?
    var onTapRow: (() -> Void)?
    
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
            $0.numberOfLines = 1
            // 카테고리는 최대한 보이고, 메모가 먼저 잘리도록 함
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        self.memoLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .regular)
            $0.textColor = .tertiaryLabel
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
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
        
        let leftStack = UIStackView(arrangedSubviews: [dotView, categoryLabel, memoLabel])
        leftStack.axis = .horizontal
        leftStack.alignment = .center
        // 카테고리와 메모는 더 촘촘하게 붙임
        leftStack.spacing = 4
        // 왼쪽 스택이 내용을 유지하면서 오른쪽(금액)과 간격을 확보하도록 우선순위 설정
        leftStack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        leftStack.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let hStack = UIStackView(arrangedSubviews: [leftStack, amountLabel, deleteButton])
        hStack.axis = .horizontal
        hStack.alignment = .center
        // 왼쪽 묶음과 금액 사이 기본 간격을 넉넉히 확보
        hStack.spacing = 12

        // 금액/삭제 버튼은 붙어있고, 왼쪽과는 여유 간격이 생기도록 설정
        self.amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        
        self.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        }

        // 상위 레이어 투명 버튼: 삭제 버튼 영역은 제외하여 겹치지 않도록 처리
        self.addSubview(selectOverlayButton)
        self.selectOverlayButton.backgroundColor = .clear
        self.selectOverlayButton.addTarget(self, action: #selector(didTapRow), for: .touchUpInside)
        self.selectOverlayButton.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(self.deleteButton.snp.leading).offset(-8)
        }
    }
    
    func configure(category: String, amountText: String, memo: String?, tint: UIColor) {
        self.dotView.backgroundColor = tint
        self.categoryLabel.text = category
        let trimmed = memo?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self.memoLabel.isHidden = false
        self.memoLabel.text = trimmed.isEmpty ? "" : trimmed
        self.amountLabel.text = amountText
        self.amountLabel.textColor = tint
    }
    
    @objc private func didTapDelete() {
        onTapDelete?()
    }

    @objc private func didTapRow() {
        onTapRow?()
    }
}
