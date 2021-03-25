//
//  CompletionViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 13/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit

class CompletionViewController: UIViewController {

    @IBOutlet weak var successImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        successImage.layer.cornerRadius = successImage.frame.height/2
        successImage.clipsToBounds = true
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
