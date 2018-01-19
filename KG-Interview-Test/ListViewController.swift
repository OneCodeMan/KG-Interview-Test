//
//  ListViewController.swift
//  KG-Interview-Test
//
//  Created by Dave Gumba on 2018-01-19.
//  Copyright © 2018 Dave's Organization. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var gamesTableView: UITableView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var dayParam = ""
    var monthParam = ""
    var yearParam = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: sender.date)
        
        if let day = components.day, let month = components.month, let year = components.year {
            dayParam = String(day).count == 1 ? "0\(day)" : "\(day)"
            monthParam = String(month).count == 1 ? "0\(month)" : "\(month)"
            yearParam = "\(year)"
            
            // get data, update table view
        }
    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gamesTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        
        cell.homeTeamName?.text = "Yankees"
        cell.homeTeamScore?.text = "0"
        cell.awayTeamName?.text = "Blue Jays"
        cell.awayTeamScore?.text = "4"
    
        cell.status?.text = "Final"
    
        return cell
        
    }

}
