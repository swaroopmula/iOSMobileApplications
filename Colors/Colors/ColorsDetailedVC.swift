//
//  ColorsDetailedVC.swift
//  Colors
//
//  Created by Swaroop Mula on 8/19/24.
//

import UIKit

class ColorsDetailedVC: UIViewController {
    
    var color: UIColor? 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color ?? .black
    }
}
