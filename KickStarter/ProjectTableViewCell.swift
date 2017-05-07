//
//  ProjectTableViewCell.swift
//  KickStarter
//
//  Created by Abhinav Mathur on 07/05/17.
//  Copyright © 2017 Abhinav Mathur. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectCost: UILabel!
    @IBOutlet weak var projectBackers: UILabel!
    @IBOutlet weak var projectDays: UILabel!
    @IBOutlet weak var projectUrl: UILabel!
    @IBOutlet weak var projectFunded: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
