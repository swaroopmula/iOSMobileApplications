//
//  DetailViewController.swift
//  HW8
//
//  Created by Swaroop Mula on 3/4/24.
//

import UIKit

class FlagViewController: UIViewController {
    var flagName: String?
    var countryDescription: String?
    var countryURL: String?

    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        flagImageView.image = UIImage(named: flagName ?? "")
        descriptionLabel.text = countryDescription
    }
    
    @IBAction func buttontapped(_ sender: UIButton) {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWebView",
           let webViewController = segue.destination as? WebViewController {
            webViewController.urlString = countryURL
        }
    }
}
