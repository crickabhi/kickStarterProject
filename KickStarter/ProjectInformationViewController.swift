//
//  ProjectInformationViewController.swift
//  KickStarter
//
//  Created by Abhinav Mathur on 07/05/17.
//  Copyright © 2017 Abhinav Mathur. All rights reserved.
//

import UIKit

class ProjectInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var projectImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var playerDetail : Dictionary<String,AnyObject> = [:]
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Project Detail"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.layer.borderWidth = 1.5
        self.tableView.layer.borderColor = UIColor.blue.cgColor
        self.tableView.layer.cornerRadius = 10
        self.tableView.clipsToBounds = true
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        if  self.playerDetail["url"] != nil
        {
            self.projectImage.sd_setImage(with: NSURL(string:(self.playerDetail["url"])! as! String)! as URL, placeholderImage: UIImage(named:"kickstarter-logo.jpg"))
        }
        else
        {
            self.projectImage.image = UIImage(named: "kickstarter-logo.jpg")
        }
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projects") as! ProjectTableViewCell
        
        cell.projectName.text = self.playerDetail["title"] as? String
        cell.projectCost.text = "Pledged: " + String(describing: self.playerDetail["amt.pledged"]!)
        cell.projectBackers.text = "Backers: " + (self.playerDetail["num.backers"] as? String)!
        cell.projectDays.text = "End date: " + (QueryHandler().dayMonthYearFromStringDate(dateString: playerDetail["end.time"] as! String))
        cell.projectUrl.text = "Url: " + "https://www.kickstarter.com/" + (playerDetail["url"] as! String)
        cell.projectFunded.text = "Funded %: " + String(Float(String(describing: self.playerDetail["percentage.funded"]!))!/100)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func shareDetails()
    {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
