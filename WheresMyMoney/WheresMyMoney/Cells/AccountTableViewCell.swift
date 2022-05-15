//
//  CustomUniversalTableViewCell.swift
//  CourseProjectTry
//
//  Created by Анна Шербицкая on 12.04.22.
//

import UIKit



class AccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountOfMoneyLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.image = UIImage(systemName: "plus.circle")
        nameLabel.text = "Create"
        amountOfMoneyLabel.text = "New account"
        deleteButton.titleLabel?.text = nil
        editButton.titleLabel?.text = nil

    }
    
}
