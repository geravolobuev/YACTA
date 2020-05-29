//
//  CustomWidgetTableCell.swift
//  TodayExtensionYACTA
//
//  Created by MAC on 25/11/2019.
//  Copyright © 2019 Gera Volobuev. All rights reserved.
//

import UIKit

class CustomWidgetTableCell: UITableViewCell {
    @IBOutlet weak var WidgetDateLabel: UILabel!
    @IBOutlet weak var WidgetDaysLeftLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
