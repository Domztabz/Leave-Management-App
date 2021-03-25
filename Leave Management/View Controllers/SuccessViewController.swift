//
//  SuccessViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 24/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    
    var message: String?

    @IBOutlet weak var messageUILabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _message = message {
            messageUILabel.text = message
        }
      //  self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, //alpha: 1.0)

    }
    
    @IBAction func goBack(_ sender: GoBackbutton) {
        self.navigationController?.popToRootViewController(animated: true)

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
