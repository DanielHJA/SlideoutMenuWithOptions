//
//  MenuTableviewCell.swift
//  TransitionDelegateWithDrag
//
//  Created by Daniel Hjärtström on 2018-07-02.
//  Copyright © 2018 Daniel Hjärtström. All rights reserved.
//

import UIKit

enum NavigationEndpoint {
    case one
    case two
    case three
}

class MenuTableviewCell: UITableViewCell {

    static let identifier = "MenuTableviewCell"
    var endPoint: NavigationEndpoint?
    
    private lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.textColor = UIColor.black
        temp.textAlignment = .center
        temp.font = UIFont(name: "Helvetica", size: 17.0)
        addSubview(temp)
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        temp.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        temp.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        temp.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        return temp
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setupWithMenuModel(_ model: MenuModel) {
        titleLabel.text = model.title
        endPoint = model.endPoint
        accessoryType = .disclosureIndicator
    }
    
}
