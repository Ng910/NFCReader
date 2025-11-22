//
//  FelicaDetailCell.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/22.
//

import UIKit
import Anchorage

final class FelicaDetailCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    var date: String = "" {
        didSet {
            dateLabel.text = date
        }
    }
    
    var balance: Int = 0 {
        didSet {
            balanceLabel.text = "残高: \(balance) 円"
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    private func setupLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(dateLabel)
        dateLabel.topAnchor == contentView.topAnchor + 8
        dateLabel.leftAnchor == contentView.leftAnchor + 24
        dateLabel.rightAnchor == contentView.rightAnchor - 24
        
        contentView.addSubview(balanceLabel)
        balanceLabel.topAnchor == dateLabel.bottomAnchor + 16
        balanceLabel.leftAnchor == contentView.leftAnchor + 24
        balanceLabel.rightAnchor == contentView.rightAnchor - 24
        balanceLabel.bottomAnchor == contentView.bottomAnchor - 8
    }
}
