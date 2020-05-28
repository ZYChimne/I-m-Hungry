//
//  Cart.swift
//  I'm HUNGRY!
//
//  Created by ZYC on 2020/5/26.
//  Copyright © 2020 ZYC. All rights reserved.
//

import UIKit

class Cart: UITableViewController {
    var restaurants:[String]=[]
    var foods:[String]=[]
    var prices:[String]=[]
    var nos:[String]=[]
    
    @IBOutlet weak var toolBar: UITabBarItem!
    @IBOutlet weak var totalPrice: UITextView!
    
    @IBAction func commit(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return foods.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartIdentifier", for: indexPath)
        cell.textLabel?.text=foods[indexPath.row]+"-"+restaurants[indexPath.row]
        cell.imageView?.image=UIImage(named: "\(foods[indexPath.row])")
        cell.detailTextLabel?.text=nos[indexPath.row]
        return cell
    }
    
    func dataFilePath() -> String {
        let urls=FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url=(urls.first?.appendingPathComponent("_______data.sqlite").path)!
        return url
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var database:OpaquePointer?=nil
        let databasePath=dataFilePath()
        let result=sqlite3_open(databasePath,&database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to open database")
            return
        }
        let query="SELECT name, food, price, no FROM Restaurant"
        var statement:OpaquePointer?=nil
        if(sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                let no=String.init(cString:UnsafePointer<UTF8Char>(sqlite3_column_text(statement, 3)!))
                let foodName=String.init(cString:UnsafePointer<UTF8Char>(sqlite3_column_text(statement, 1)!))
                if(Int(no) != 0){
                    if(foods.contains(foodName)){
                        for cnt in 0 ... (foods.count-1){
                            if foodName==foods[cnt] {
                                nos[cnt]=no
                            }
                        }
                    }else{
                        restaurants.append(String.init(cString:UnsafePointer<UTF8Char>(sqlite3_column_text(statement, 0)!)))
                        foods.append(foodName)
                        prices.append(String.init(cString:UnsafePointer<UTF8Char>(sqlite3_column_text(statement, 2)!)))
                        nos.append(no)
                    }
                }
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)

        loadPrice()

        if(foods.count>0){
            toolBar.badgeValue=String(foods.count)
        }else {
            toolBar.badgeValue=nil
        }

        tableView.reloadData()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    //Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            var database:OpaquePointer?=nil
            let databasePath=dataFilePath()
            var result=sqlite3_open(databasePath,&database)
            if(result != SQLITE_OK){
                sqlite3_close(database)
                print("Fail to open database")
                return
            }
            let no=0
            let updateSQL="UPDATE restaurant SET no='\(no)' WHERE food='\(foods[indexPath.row])'"
            var err:UnsafeMutablePointer<Int8>?=nil
            result=sqlite3_exec(database, updateSQL, nil, nil, &err)
            if(result != SQLITE_OK){
                sqlite3_close(database)
                print("Fail to remove")
                return
            }
            sqlite3_close(database)
            
            foods.remove(at: indexPath.row)
            restaurants.remove(at: indexPath.row)
            nos.remove(at: indexPath.row)
            prices.remove(at: indexPath.row)
            loadPrice()
            if(foods.count>0){
                toolBar.badgeValue=String(foods.count)
            }else {
                toolBar.badgeValue=nil
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
//        else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }
    
    func loadPrice(){
        var total=0
        if(!foods.isEmpty){
            for cnt in 0 ... (foods.count-1){
                total += Int(nos[cnt])! * Int(prices[cnt])!
            }
        }
        totalPrice.text=String(total)+" CNY"
    }

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
