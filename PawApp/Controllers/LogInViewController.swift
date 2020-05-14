//
//  LogInViewController.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 13.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actionLogInButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueShowWebView", sender: nil)
    }
}
