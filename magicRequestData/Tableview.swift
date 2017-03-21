//
//  Tableview.swift
//  magicRequestData
//
//  Created by bruno raupp kieling on 18/03/17.
//  Copyright © 2017 brunokieling. All rights reserved.
//

import UIKit

class Tableview : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var historico = [String : Double]()
    var vetName : [String?] = []
    var vetPreco : [Double?] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vetName.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Customcell
        cell.labelText.text = vetName[indexPath.count]! + String(describing: vetPreco[indexPath.count]!)
        
        print (cell.labelText.text)
        return cell
        
    }
}
