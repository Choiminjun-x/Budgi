//
//  CategoryChipCell.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/27/26.
//

import SnapKit
import UIKit

final class CategoryChipCell: UICollectionViewCell {
    static let reusableId = "CategoryChipCell"
    
    private var titleLabel: UILabel!
    
    private let hPadding: CGFloat = 14
    private let vPadding: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeViewLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    
    // MARK: makeViewLayout
    
    private func makeViewLayout() {
        self.contentView.backgroundColor = .systemGray6
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        self.titleLabel = UILabel().do {
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .label
            contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(
                    UIEdgeInsets(
                        top: self.vPadding,
                        left: self.hPadding,
                        bottom: self.vPadding,
                        right: self.hPadding
                    )
                )
            }
        }
    }
    
    
    // MARK: displayCell
    
    func displayCell(title: String) {
        self.titleLabel.text = title
        self.updateSelectionAppearance()
    }
    
    override var isSelected: Bool {
        didSet { self.updateSelectionAppearance() }
    }
    
    private func updateSelectionAppearance() {
        self.contentView.backgroundColor = self.isSelected ? .systemBlue : .tertiarySystemFill
        self.titleLabel.textColor = self.isSelected ? .white : .label
    }
}
