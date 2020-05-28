//
//  Menu.swift
//  I'm HUNGRY!
//
//  Created by ZYC on 2020/5/20.
//  Copyright © 2020 ZYC. All rights reserved.
//

import UIKit


class Menu: UITableViewController {
    
    let identifier="restaurantIdentifier"
    private var Restaurants:[String:[String:[String]]]!
    private var AllRestaurants:[String]=[]
    var searchController:UISearchController!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AllRestaurants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell=tableView.dequeueReusableCell(withIdentifier: identifier)
        if(cell==nil){
            cell=UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
        }
        cell?.textLabel?.text=AllRestaurants[indexPath.row]
        cell?.imageView?.image=UIImage(named: "\(AllRestaurants[indexPath.row])")
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var foodNames:[String]=[]
        let indexPath=tableView.indexPath(for: sender as! UITableViewCell)!
        let list=segue.destination as! Food

        var database:OpaquePointer?=nil
        let databasePath=dataFilePath()
        let result=sqlite3_open(databasePath,&database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to open database")
            return
        }

        let query="SELECT food FROM Restaurant WHERE name='\(AllRestaurants[indexPath.row])'"
        var statement:OpaquePointer?=nil
        if(sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                let temp=sqlite3_column_text(statement, 0)
                let restaurantName=String.init(cString:UnsafePointer<UTF8Char>(temp!))
                foodNames.append(restaurantName)
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        list.foodNames=foodNames
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bundle=Bundle.main
        let plistURL=bundle.url(forResource:"Restaurants",withExtension:"plist")
        Restaurants=NSDictionary.init(contentsOf: (plistURL)!)as![String:[String:[String]]]
        let allRestaurants=Restaurants.keys.sorted()

        var database:OpaquePointer?=nil
        let databasePath=dataFilePath()
        var result=sqlite3_open(databasePath,&database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to open database")
            return
        }

        let createSQL="CREATE TABLE IF NOT EXISTS Restaurant (name TEXT, food TEXT PRIMARY KEY, price TEXT, description TEXT, no TEXT);"
        var err:UnsafeMutablePointer<Int8>?=nil
        result=sqlite3_exec(database, createSQL, nil, nil, &err)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to create table")
            return
        }
        for restaurantSQL in allRestaurants{
            let foodName:[String]=Restaurants![restaurantSQL]!.keys.sorted()
            for foodSQL in foodName{
                let name=restaurantSQL
                let food=foodSQL
                let price=Restaurants[restaurantSQL]![foodSQL]![0]
                let dsp=Restaurants[restaurantSQL]![foodSQL]![1]
                let no=0
                let insertSQL="INSERT OR REPLACE INTO Restaurant (name, food, price, description, no) VALUES ('\(name)', '\(food)', '\(price)', '\(dsp)', '\(no)');"
                var errmsg:UnsafeMutablePointer<Int8>?=nil
                sqlite3_exec(database, insertSQL, nil, nil, &errmsg)
            }
        }
        
        let query="SELECT DISTINCT name FROM Restaurant"
        var statement:OpaquePointer?=nil
        if(sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                let temp=sqlite3_column_text(statement, 0)
                let restaurantName=String.init(cString:UnsafePointer<UTF8Char>(temp!))
                AllRestaurants.append(restaurantName)
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        let resultsController=SearchResultsController()
        resultsController.restaurants=AllRestaurants
        searchController=UISearchController(searchResultsController: resultsController)
        let searchBar=searchController.searchBar
        searchBar.placeholder = "输入餐厅的名字"
        searchBar.sizeToFit()
        tableView.tableHeaderView=searchBar
        searchController.searchResultsUpdater=resultsController
    }
    
    func dataFilePath() -> String {
        let urls=FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url=(urls.first?.appendingPathComponent("_______data.sqlite").path)!
        return url
    }
}

