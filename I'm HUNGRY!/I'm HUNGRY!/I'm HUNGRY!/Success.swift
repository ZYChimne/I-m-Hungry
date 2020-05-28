//
//  Success.swift
//  I'm HUNGRY!
//
//  Created by ZYC on 2020/5/28.
//  Copyright © 2020 ZYC. All rights reserved.
//

import UIKit

class Success: UIViewController {


    @IBAction func Confirm(_ sender: Any) {
        var database:OpaquePointer?=nil
        let databasePath=dataFilePath()
        var result=sqlite3_open(databasePath,&database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to open database")
            return
        }
        let no=0
        let updateSQL="UPDATE restaurant SET no='\(no)'"
        var err:UnsafeMutablePointer<Int8>?=nil
        result=sqlite3_exec(database, updateSQL, nil, nil, &err)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to commit")
            return
        }
        sqlite3_close(database)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func dataFilePath() -> String {
        let urls=FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url=(urls.first?.appendingPathComponent("_______data.sqlite").path)!
        return url
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
