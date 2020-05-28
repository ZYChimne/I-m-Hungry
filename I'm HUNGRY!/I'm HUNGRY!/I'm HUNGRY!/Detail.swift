//
//  Detail.swift
//  I'm HUNGRY!
//
//  Created by ZYC on 2020/5/26.
//  Copyright © 2020 ZYC. All rights reserved.
//

import UIKit

class Detail: UIViewController {
    var foodName=""
    var dsp=""
    var price=0

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var text1: UITextView!
    @IBOutlet weak var text2: UITextView!
    
    @IBAction func addToCart(_ sender: UIButton) {
        var no=""

        var database:OpaquePointer?=nil
        let databasePath=dataFilePath()
        var result=sqlite3_open(databasePath,&database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to open database")
            return
        }
        let query="SELECT no FROM Restaurant WHERE food='\(foodName)'"
        var statement:OpaquePointer?=nil
        if(sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                let temp=sqlite3_column_text(statement, 0)
                no=String.init(cString:UnsafePointer<UTF8Char>(temp!))
            }
            sqlite3_finalize(statement)
        }

        no=String(Int(no)!+1)
        let updateSQL="UPDATE restaurant SET no='\(no)' WHERE food='\(foodName)'"
        var err:UnsafeMutablePointer<Int8>?=nil
        result=sqlite3_exec(database, updateSQL, nil, nil, &err)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to add to cart")
            return
        }
        sqlite3_close(database)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        var database:OpaquePointer?=nil
        let databasePath=dataFilePath()
        let result=sqlite3_open(databasePath,&database)
        if(result != SQLITE_OK){
            sqlite3_close(database)
            print("Fail to open database")
            return
        }
        let query="SELECT price, description FROM Restaurant WHERE food='\(foodName)'"
        var statement:OpaquePointer?=nil
        if(sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                let priceTemp=sqlite3_column_text(statement, 0)
                price=Int(String.init(cString:UnsafePointer<UTF8Char>(priceTemp!)))!
                let temp=sqlite3_column_text(statement, 1)
                dsp=String.init(cString:UnsafePointer<UTF8Char>(temp!))
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        imageView.image=UIImage(named: "\(foodName)")
        text1.text=String(price)+" CNY"
        text2.text=dsp
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
