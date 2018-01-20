//
//  ListViewController.swift
//  KG-Interview-Test
//
//  Created by Dave Gumba on 2018-01-19.
//  Copyright © 2018 Dave's Organization. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ListViewController: UIViewController {

    @IBOutlet weak var gamesTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var finalURL = ""
    var gamesList = [Game]()
    
    var dayParam = ""
    var monthParam = ""
    var yearParam = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
    }
    
    // MARK: Date picker changed
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        
        gamesList = [] // restart gamesList whenever new date is selected
        gamesTableView.reloadData()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: sender.date)
        
        if let day = components.day, let month = components.month, let year = components.year {
            
            dayParam = String(day).count == 1 ? "0\(day)" : "\(day)"
            monthParam = String(month).count == 1 ? "0\(month)" : "\(month)"
            yearParam = "\(year)"
            
            finalURL = "http://gd2.mlb.com/components/game/mlb/year_\(yearParam)/month_\(monthParam)/day_\(dayParam)/master_scoreboard.json"
            print(finalURL)
            
            getMLBGameData(url: finalURL)
        }
    }
    
    // MARK: Networking
    func getMLBGameData(url: String) {
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    let resultValue = response.result.value ?? ""
                    let resultJSON = JSON(resultValue)
                    let gamesJSON = resultJSON["data"]["games"]["game"]
                    
                    if gamesJSON != nil {
                        self.updateGameData(gamesJSON: gamesJSON)
                    } else {
                        print("No games")
                        // display no games on this date
                    }
                    
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")

                }
            }
    }
    
    // MARK: JSON Parsing
    func updateGameData(gamesJSON: JSON) {
        
        let onlyOneGame = gamesJSON["home_team_name"] != nil
        
        if !onlyOneGame {
            
            for (_, gameJSON) in gamesJSON {
                let homeTeamName = "\(gameJSON["home_team_name"])"
                let awayTeamName = "\(gameJSON["away_team_name"])"
                let status = "\(gameJSON["status"]["status"])"
                
                let game = Game(homeTeam: homeTeamName, homeTeamScore: "0", awayTeam: awayTeamName, awayTeamScore: "0", status: status)
                gamesList.append(game)
            }
            
        } else {
            
            let homeTeamName = "\(gamesJSON["home_team_name"])"
            let awayTeamName = "\(gamesJSON["away_team_name"])"
            let status = "\(gamesJSON["status"]["status"])"
            
            let game = Game(homeTeam: homeTeamName, homeTeamScore: "0", awayTeam: awayTeamName, awayTeamScore: "0", status: status)
            gamesList.append(game)
            
        }
            
        //print(gamesList)
        gamesTableView.reloadData()
    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gamesTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        let game = gamesList[indexPath.row]
        
        cell.homeTeamName?.text = game.homeTeam
        cell.homeTeamScore?.text = game.homeTeamScore
        cell.awayTeamName?.text = game.awayTeam
        cell.awayTeamScore?.text = game.awayTeamScore
    
        cell.status?.text = game.status
    
        return cell
        
    }

}
