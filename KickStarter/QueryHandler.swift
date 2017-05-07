//
//  QueryHandler.swift
//  KickStarter
//
//  Created by Abhinav Mathur on 07/05/17.
//  Copyright © 2017 Abhinav Mathur. All rights reserved.
//

import Foundation
import CoreData

class QueryHandler {
    
    func setProjectInformation(info : AnyObject, sno : Int, backers : String, time : String, title : String)
    {
        let managedContext = CoreDataStack.getInstance().managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Projects",in:managedContext)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        fetchRequest.predicate = NSPredicate(format:"details = %@", info as! CVarArg)
        do {
            let results = try managedContext.fetch(fetchRequest)
            let group = results as! [NSManagedObject]
            if group.count != 0{
                for i in 0  ..< group.count
                {
                    managedContext.delete(group[i])
                }
            }
            else
            {
                let msgupdate = NSManagedObject(entity: entity!,insertInto: managedContext)
                msgupdate.setValue(info,forKey: "details")
                msgupdate.setValue(sno,forKey: "sno")
                msgupdate.setValue(backers,forKey: "backers")
                msgupdate.setValue(time,forKey: "time")
                msgupdate.setValue(title,forKey: "title")

            }
            do {
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }  catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    func returnProjectsUsingPaging(count : Int , serialNumber : Int) -> Array<AnyObject>
    {
        var returnValue : Array<AnyObject> = []
        let managedContext = CoreDataStack.getInstance().managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        fetchRequest.predicate = NSPredicate(format: "sno >= %d", serialNumber)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sno", ascending: true)]
        fetchRequest.fetchLimit = count
        do {
            let results = try managedContext.fetch(fetchRequest)
            let group = results as! [NSManagedObject]
            if group.count != 0{
                for i in 0  ..< group.count
                {
                    returnValue.append(group[i].value(forKey: "details") as AnyObject)
                }
            }
        }  catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return returnValue
    }

    func returnAllProjects() -> Array<AnyObject>
    {
        var returnValue : Array<AnyObject> = []
        let managedContext = CoreDataStack.getInstance().managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        do {
            let results = try managedContext.fetch(fetchRequest)
            let group = results as! [NSManagedObject]
            if group.count != 0{
                for i in 0  ..< group.count
                {
                    returnValue.append(group[i].value(forKey: "details") as AnyObject)
                }
            }
        }  catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return returnValue
    }
    
    func returnFilteredProjects() -> Array<AnyObject>
    {
        var returnValue : Array<AnyObject> = []
        let managedContext = CoreDataStack.getInstance().managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Projects")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "backers", ascending: true)]
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            let group = results as! [NSManagedObject]
            if group.count != 0{
                for i in 0  ..< group.count
                {
                    returnValue.append(group[i].value(forKey: "details") as AnyObject)
                    
                }
            }
        }  catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return returnValue
    }
    
    func dayMonthYearFromStringDate(dateString : String)-> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let dateObj = dateFormatter.date(from: dateString)
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let strDate = dateFormatter.string(from: dateObj!)
        return strDate        
    }

}
