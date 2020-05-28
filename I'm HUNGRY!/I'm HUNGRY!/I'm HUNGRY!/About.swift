//
//  About.swift
//  I'm HUNGRY!
//
//  Created by ZYC on 2020/5/27.
//  Copyright © 2020 ZYC. All rights reserved.
//

import UIKit

class About: UIViewController {
    var dsp:String=""
    @IBOutlet weak var detail: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        detail.text=dsp
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
