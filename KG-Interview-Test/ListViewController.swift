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
    @IBOutlet weak var emptyTableView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func prevButtonClicked(_ sender: Any) {
        datePicker.date = datePicker.date.previousDay
        self.dateChanged(datePicker)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        datePicker.date = datePicker.date.nextDay
        self.dateChanged(datePicker)
    }
    
    let baseURL = "http://gd2.mlb.com"
    var finalGameURL = ""
    var gamesList = [Game]()
    var favoriteTeam = "Blue Jays"
    
    var currentDatePickerValue = Date()
    
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
            
            finalGameURL = "\(baseURL)/components/game/mlb/year_\(yearParam)/month_\(monthParam)/day_\(dayParam)/master_scoreboard.json"
            
            getMLBGameData(url: finalGameURL)
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
                    
                    if gamesJSON != JSON.null {
                        self.updateGameData(gamesJSON: gamesJSON)
                        self.emptyTableView.isHidden = true
                    } else {
                        self.emptyTableView.isHidden = false
                    }
                    
                } else {
                    self.emptyTableView.isHidden = false

                }
            }
    }
    
    // MARK: JSON Parsing
    
    func updateGameData(gamesJSON: JSON) {
        
        let onlyOneGame = gamesJSON["home_team_name"] != JSON.null
        
        if !onlyOneGame {
            // "favorite team being the first row" logic is only needed to be implemented when there's more than one game, only needs to be in this if block
            
            for (_, gameJSON) in gamesJSON {
                let homeTeamName = "\(gameJSON["home_team_name"])"
                let homeTeamScore = Int("\(gameJSON["linescore"]["r"]["home"])") ?? 0
                let awayTeamName = "\(gameJSON["away_team_name"])"
                let awayTeamScore = Int("\(gameJSON["linescore"]["r"]["away"])") ?? 0
                let status = "\(gameJSON["status"]["status"])"
                
                let dataDirectoryExists = gameJSON["game_data_directory"] != JSON.null
                let dataDirectory = dataDirectoryExists ? "\(gameJSON["game_data_directory"])" : ""
                
                let game = Game(homeTeam: homeTeamName, homeTeamScore: homeTeamScore, awayTeam: awayTeamName, awayTeamScore: awayTeamScore, status: status, dataDirectory: dataDirectory)
                
                // if favorite team appears, insert it at the beginning of gamesList
                if game.homeTeam == favoriteTeam || game.awayTeam == favoriteTeam {
                    gamesList.insert(game, at: 0)
                } else {
                    gamesList.append(game)
                }
            }
            
        } else {
            
            let homeTeamName = "\(gamesJSON["home_team_name"])"
            let homeTeamScore = Int("\(gamesJSON["linescore"]["r"]["home"])") ?? 0
            let awayTeamName = "\(gamesJSON["away_team_name"])"
            let awayTeamScore = Int("\(gamesJSON["linescore"]["r"]["away"])") ?? 0
            let status = "\(gamesJSON["status"]["status"])"
            
            let dataDirectoryExists = gamesJSON["game_data_directory"] != JSON.null
            let dataDirectory = dataDirectoryExists ? "\(gamesJSON["game_data_directory"])" : ""
            
            let game = Game(homeTeam: homeTeamName, homeTeamScore: homeTeamScore, awayTeam: awayTeamName, awayTeamScore: awayTeamScore, status: status,
                            dataDirectory: dataDirectory)
            gamesList.append(game)
        }
        
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
        cell.homeTeamName?.font = UIFont.systemFont(ofSize: 15)
        cell.homeTeamScore?.text = "\(game.homeTeamScore)"
        
        cell.awayTeamName?.text = game.awayTeam
        cell.awayTeamName?.font = UIFont.systemFont(ofSize: 15)
        cell.awayTeamScore?.text = "\(game.awayTeamScore)"
    
        cell.status?.text = game.status
        
        // bold the winning team for current game row
        if game.homeTeamScore > game.awayTeamScore {
            cell.homeTeamName?.font = UIFont.boldSystemFont(ofSize: 15)
        } else if game.awayTeamScore > game.homeTeamScore {
            cell.awayTeamName?.font = UIFont.boldSystemFont(ofSize: 15)
        }
    
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedGame = gamesList[indexPath.row]
        
        if !selectedGame.dataDirectory.isEmpty {
        
            if let vc = storyboard?.instantiateViewController(withIdentifier: "GameDetail") as? GameDetailViewController {
                vc.gameDataDirectoryURL = gamesList[indexPath.row].dataDirectory
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}
