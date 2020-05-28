//
//  Mine.swift
//  I'm HUNGRY!
//
//  Created by ZYC on 2020/5/26.
//  Copyright © 2020 ZYC. All rights reserved.
//

import UIKit

class Mine: UITableViewController {
    var Infos:[String: String]!
    var infoKeys:[String]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let bundle=Bundle.main
        let plistURL=bundle.url(forResource:"Mine",withExtension:"plist")
        Infos=NSDictionary.init(contentsOf: (plistURL)!)as![String: String]
        infoKeys=Infos.keys.sorted()
        var database:OpaquePointer?=nil
        let databasePath=dataFilePath()
        var result=sqlite3_open(databasePath,&database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to open database")
            return
        }
        let createSQL="CREATE TABLE IF NOT EXISTS Mine (k TEXT PRIMARY KEY, d TEXT);"
        var err:UnsafeMutablePointer<Int8>?=nil
        result=sqlite3_exec(database, createSQL, nil, nil, &err)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to create table")
            return
        }
        for key in infoKeys{
            let dsp:String=Infos[key]!
            let insertSQL="INSERT OR REPLACE INTO Mine (k, d) VALUES ('\(key)', '\(String(describing: dsp))');"
            var errmsg:UnsafeMutablePointer<Int8>?=nil
            sqlite3_exec(database, insertSQL, nil, nil, &errmsg)
        }
        sqlite3_close(database)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var dsp:String=""
        let indexPath=tableView.indexPath(for: sender as! UITableViewCell)!
        let list=segue.destination as! About
        var database:OpaquePointer?=nil
        let databasePath=dataFilePath()
        let result=sqlite3_open(databasePath,&database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to open database")
            return
        }
        let query="SELECT d FROM Mine WHERE k='\(infoKeys[indexPath.row])'"
        var statement:OpaquePointer?=nil
        if(sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                let temp=sqlite3_column_text(statement, 0)
                dsp=String.init(cString:UnsafePointer<UTF8Char>(temp!))
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        list.dsp=dsp
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return infoKeys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mineIdentifier", for: indexPath)
        cell.textLabel?.text=infoKeys[indexPath.row]
        return cell
    }
    
    func dataFilePath() -> String {
        let urls=FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url=(urls.first?.appendingPathComponent("_______data.sqlite").path)!
        return url
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
