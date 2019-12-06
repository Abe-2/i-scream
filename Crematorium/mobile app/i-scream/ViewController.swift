//
//  ViewController.swift
//  i-scream
//
//  Created by Abdalwahab on 12/6/19.
//  Copyright © 2019 team. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    var pending = [Order]()
    var ready = [Order]()
    
    static var lastID = 1
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
//        let query = ref.queryOrdered(byChild: "Orders")
//        query.observeSingleEvent(of: .value, with: { (fireSnapshot) in
//
//            for child in fireSnapshot.children.allObjects as! [DataSnapshot] {
//                for object in child.children.allObjects as! [DataSnapshot] {
//                    //                    print("start-object")
//                    //                    print(object)
//                    //                    print("end-object")
//
//                    let id = object.childSnapshot(forPath: "id").value as! String
//                    let status = object.childSnapshot(forPath: "status").value as! String
//
//                    let order = Order(id: id, status: status)
//
//                    if status == "pending" || status == "preparing" {
//                        self.pending.append(order)
//                    }else{
//                        self.ready.append(order)
//                    }
//                }
//            }
//
//            self.table.reloadData()
//        })
        
        ref.child("Orders").observe(.childAdded, with: { (fireSnapshot) in
            let id = fireSnapshot.childSnapshot(forPath: "id").value as! String
            let status = fireSnapshot.childSnapshot(forPath: "status").value as? String ?? "pending"

            ViewController.lastID = max(Int(id)! + 1, ViewController.lastID)
            
            let order = Order(id: id, status: status)

            // status == "pending" ||
            if status == "preparing" {
                self.pending.append(order)
            }else if status == "done" {
                self.ready.append(order)
            }

            self.table.reloadData()
        })
        
        ref.child("Orders").observe(.childChanged, with: { (fireSnapshot) in
            let id = fireSnapshot.childSnapshot(forPath: "id").value as! String
            let status = fireSnapshot.childSnapshot(forPath: "status").value as! String
            
            self.pending.removeAll { order in
                return order.id == id
            }
            
            let order = Order(id: id, status: status)
            
            if status == "pending" || status == "preparing" {
                self.pending.append(order)
            }else{
                self.ready.append(order)
            }
            
            self.table.reloadData()
        })
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "being prepared"
        }else{
            return "ready to pickup"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pending.count
        }else{
            return ready.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell") as! OrderCell
        
        if indexPath.section == 0 {
            cell.imgIcon.image = #imageLiteral(resourceName: "icecream")
            cell.lblID.text = "order #\(pending[indexPath.row].id!)"
        }else{
            cell.imgIcon.image = #imageLiteral(resourceName: "icecream-filled")
            cell.lblID.text = "order #\(ready[indexPath.row].id!)"
        }
        
        return cell
    }
    
}

class OrderCell: UITableViewCell {
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var lblID: UILabel!
}

