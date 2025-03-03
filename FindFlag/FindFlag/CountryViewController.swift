//
//  ViewController.swift
//  HW8
//
//  Created by Swaroop Mula on 3/4/24.
//

import UIKit

class CountryViewController: UITableViewController {
    
    let countries = countriesData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Countries"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let countries = countries[indexPath.row]
        let message = "Click on the country to view flag details"
        let actionSheetController = UIAlertController(title: countries.name, message: message, preferredStyle: .actionSheet)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        actionSheetController.addAction(okayAction)
        present(actionSheetController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFlagDetail",
           let destinationVC = segue.destination as? FlagViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            let country = countries[indexPath.row]
            destinationVC.flagName = country.flag
            destinationVC.countryDescription = country.description
            destinationVC.countryURL = country.URL
        }
    }
}
