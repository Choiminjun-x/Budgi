//
//  CategoryChipCell.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/27/26.
//

import UIKit
import SnapKit

final class CategoryChipCell: UICollectionViewCell {
    static let reuseId = "CategoryChipCell"
    
    private var titleLabel: UILabel!
    
    private let hPadding: CGFloat = 14
    private let vPadding: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setup() {
        self.contentView.backgroundColor = .systemGray6
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        self.titleLabel = UILabel().do {
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .label
            contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(UIEdgeInsets(top: self.vPadding, left: self.hPadding, bottom: self.vPadding, right: self.hPadding))
            }
        }
    }
    
    func configure(title: String) {
        self.titleLabel.text = title
        self.updateSelectionAppearance()
    }
    
    override var isSelected: Bool {
        didSet { self.updateSelectionAppearance() }
    }
    
    private func updateSelectionAppearance() {
        if self.isSelected {
            self.contentView.backgroundColor = .systemBlue
            self.titleLabel.textColor = .white
        } else {
            self.contentView.backgroundColor = .systemGray6
            self.titleLabel.textColor = .label
        }
    }
}
