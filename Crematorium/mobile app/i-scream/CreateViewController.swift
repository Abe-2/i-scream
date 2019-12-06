//
//  CreateViewController.swift
//  i-scream
//
//  Created by Abdalwahab on 12/6/19.
//  Copyright © 2019 team. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class CreateViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    let ref = Database.database().reference()
    
    let choices : [String:[String]] = [
        "Base":["Vanilla", "Strawberry", "Chocolate", "Lemon", "Coffee", "Mango"],
        "Nuts":["choice1","choice2","choice3"],
        "Sauces":["choice4","choice5","choice6"],
        "Fruits":["choice7", "choice8", "choice9"],
        "Baked Yuminess":["choice10", "choice11"]
    ]
    let categories = ["Base", "Nuts", "Sauces", "Fruits", "Baked Yuminess"]
    
    var selection : [String:[String]] = [
        "Base":[],
        "Nuts":[],
        "Sauces":[],
        "Fruits":[],
        "Baked Yuminess":[]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func done(_ sender: Any) {
        
        var selectedBase = false;
        
//        table.indexPathsForSelectedRows
        
        guard let selectedRows = table.indexPathsForSelectedRows, !selectedRows.isEmpty else {
            showAlert(title: "Order something!", message: "You must at least pick one ingredient from base")
            return
        }
        
        for row in selectedRows {
            if row.section == 0 {
                selectedBase = true
            }
            
            let sectionName = categories[row.section]
            let choiceName = choices[sectionName]![row.row]
            
            selection[sectionName]?.append(choiceName)
        }
        
        if selectedBase {
            addOrder()
        }else{
            showAlert(title: "Pick a base", message: "You must pick an ingredint from base category")
        }
    }
    
    func addOrder() {
        var order = ""
        
        for category in categories {
            if !selection[category]!.isEmpty {
                order += category + ": "
                for pick in selection[category]! {
                    order += pick + ", "
                }
            }
        }
        
        let id = ViewController.lastID
        
        ref.child("Orders").child("order\(id)").child("id").setValue(String(id))
        ref.child("Orders").child("order\(id)").child("status").setValue("pending")
        ref.child("Orders").child("order\(id)").child("order").setValue(order)
        
        ViewController.lastID += 1
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Close") {
            self.navigationController?.popViewController(animated: true)
        }
        alertView.showSuccess("Done!", subTitle: "Thank you for ordering.\nYour order number: \(id)")
        
//        let alert = UIAlertController(title: "Done!", message: "Thank you for ordering.\nYour order number: \(id)", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
//            self.navigationController?.popViewController(animated: true)
//        })
//        alert.addAction(cancelAction)
//        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension CreateViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices[categories[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell") as! ChoiceCell
        
         let cellBGView = UIView()
         cellBGView.backgroundColor = #colorLiteral(red: 1, green: 0.4140008092, blue: 0.694357872, alpha: 0.3985712757)
         cell.selectedBackgroundView = cellBGView
        
        cell.lblTitle.text = choices[categories[indexPath.section]]![indexPath.row]
        
        return cell
    }
    
    
}

class ChoiceCell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    
//    var choosen = false
    
}
