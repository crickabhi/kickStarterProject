//
//  ViewController.swift
//  KickStarter
//
//  Created by Abhinav Mathur on 07/05/17.
//  Copyright © 2017 Abhinav Mathur. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortView: UIView!
    
    var projectsArray       : Array<AnyObject>?
    var searchActive        : Bool = false
    var searching_data      : NSMutableArray = []
    var filteredProjects    : Array<AnyObject>?
    var start               : Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        searchBar.delegate = self
        searchBar.text = .none
        searchBar.showsCancelButton = false
        searchBar.returnKeyType = .default
        searchActive = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRecords()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        
        //self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(ViewController.sortProjects)),UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(ViewController.filterProjects))]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "sort"), style: .plain, target: self, action: #selector(ViewController.sortProjects)),UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(ViewController.filterProjects))]

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.showsCancelButton = false
        searchBar.text = .none
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchActive = false;
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text!.isEmpty{
            searchActive = false
            tableView.reloadData()
        } else {
            print(" search text %@ ",searchBar.text! as NSString)
            searchActive = true
            searching_data.removeAllObjects()
            for index in 0 ..< projectsArray!.count
            {
                let currentString = projectsArray?[index].value(forKey: "title") as! String
                if currentString.lowercased().range(of: searchText.lowercased())  != nil {
                    searching_data.add(projectsArray![index])
                    
                }
            }
            tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive
        {
            return searching_data.count
        }
        else if filteredProjects != nil && filteredProjects!.count > 0
        {
            return filteredProjects!.count
        }
        else if self.projectsArray != nil
        {
            return self.projectsArray!.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        print(indexPath.row)
        let lastRowIndex = tableView.numberOfRows(inSection: 0)
        if indexPath.row == lastRowIndex - 1
        {
            self.callTableViewReload()
        }
    }
    
    func callTableViewReload()
    {
        start += 10
        let recordsFetched = QueryHandler().returnProjectsUsingPaging(count: 10, serialNumber: start)
        for projectRecord in recordsFetched
        {
            self.projectsArray?.append(projectRecord)
        }
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projects") as! ProjectTableViewCell
        
        var playerInfo : AnyObject
        if searchActive
        {
            playerInfo = searching_data[indexPath.row] as AnyObject
        }
        else if filteredProjects != nil && filteredProjects!.count > 0
        {
            playerInfo = filteredProjects?[indexPath.row] as AnyObject
        }
        else
        {
            playerInfo = self.projectsArray?[indexPath.row] as AnyObject
        }

        cell.projectName.text = playerInfo.value(forKey: "title") as? String
        cell.projectCost.text = "Pledged: " + String(describing: playerInfo["amt.pledged"]!!)
        cell.projectBackers.text = "Backers: " + (playerInfo.value(forKey: "num.backers") as? String)!
        cell.projectDays.text = "End date: " + (QueryHandler().dayMonthYearFromStringDate(dateString: playerInfo.value(forKey: "end.time") as! String))

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "projectDetail", sender: indexPath)
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "projectDetail"
        {
            if searchActive
            {
                let vc = segue.destination as! ProjectInformationViewController
                vc.playerDetail = self.searching_data[(sender as! IndexPath).row] as! Dictionary<String, AnyObject>
            }
            else
            {
                let vc = segue.destination as! ProjectInformationViewController
                if filteredProjects != nil && filteredProjects!.count > 0
                {
                    vc.playerDetail = self.filteredProjects?[(sender as! IndexPath).row] as! Dictionary<String, AnyObject>
                }
                else if self.projectsArray != nil
                {
                    vc.playerDetail = self.projectsArray?[(sender as! IndexPath).row] as! Dictionary<String, AnyObject>
                }
            }
        }
        
    }
    // MARK: - Utility function
    
    func getRecords()
    {
        let localRecords = QueryHandler().returnProjectsUsingPaging(count: 10, serialNumber: start)
        if localRecords.count > 0
        {
            self.projectsArray = localRecords
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            })
        }
        else
        {
            let url = URL(string: "http://starlord.hackerearth.com/kickstarter")
            
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                self.projectsArray = (json as! Array<AnyObject>)
                for i in 0 ..< self.projectsArray!.count
                {
                    QueryHandler().setProjectInformation(info: self.projectsArray![i],
                                                         sno : self.projectsArray![i].value(forKey: "s.no") as! Int,
                                                         backers : self.projectsArray![i].value(forKey: "num.backers") as! String,
                                                         time : self.projectsArray![i].value(forKey: "end.time") as! String,
                                                         title : self.projectsArray![i].value(forKey: "title") as! String)
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                })
            }
            
            task.resume()
 
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func filterProjects() {
        self.projectsArray?.removeAll()
        self.filteredProjects = QueryHandler().returnFilteredProjects()
        self.tableView.reloadData()
    }
    
    func sortProjects() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let oneWayGroup = UIAlertAction(title: "Sort by time", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sortByTime(sortKey: "end.time")
        })
        optionMenu.addAction(oneWayGroup)
        let twoWayGroup = UIAlertAction(title: "Sort by A-Z", style: .default, handler: {
        (alert: UIAlertAction!) -> Void in
        self.sortByTime(sortKey: "title")
        })
        
        optionMenu.addAction(twoWayGroup)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(cancelAction)
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = self.sortView
            popoverController.sourceRect = self.sortView.bounds
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func sortByTime(sortKey : String) {
        self.filteredProjects?.removeAll()
        self.projectsArray = QueryHandler().returnAllProjects()
        self.projectsArray!.sort(by: {String(describing: $0.value(forKey: sortKey)).compare(String(describing: $1.value(forKey: sortKey))) == .orderedAscending})
        self.tableView.reloadData()
    }
}

