//
//  GameDetailViewController.swift
//  KG-Interview-Test
//
//  Created by Dave Gumba on 2018-01-19.
//  Copyright © 2018 Dave's Organization. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SpreadsheetView

class GameDetailViewController: UIViewController {
    
    @IBOutlet weak var networkCallFailView: UIView!
    
    // MARK: - Inning by inning variables
    @IBOutlet weak var inningSpreadsheetView: SpreadsheetView!
    var inningInfoHeaders = [""]
    var homeTeamName = ""
    var homeTeamInnings = [Int]()
    var awayTeamName = ""
    var awayTeamInnings = [Int]()
    
    // MARK: - Batting variables
    @IBOutlet weak var battingTeamPicker: UIPickerView!
    @IBOutlet weak var battingSpreadsheetView: SpreadsheetView!
    var battingTeamPickerData = [String]()
    var battingTeamPickerIndex = 0
    var battingInfoHeaders = ["Name", "AB", "R", "H", "RBI", "BB", "SO", "AVG"]
    var teamNames = [String]()
    var homeTeamBatters = [[String]]()
    var awayTeamBatters = [[String]]()
    var batters = [[[String]]]()
    
    var gameDataDirectoryURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkCallFailView.isHidden = true
        
        // inning spreadsheetview logic
        inningSpreadsheetView.delegate = self
        inningSpreadsheetView.dataSource = self
        inningSpreadsheetView.showsHorizontalScrollIndicator = true
        inningSpreadsheetView.register(TitleCell.self, forCellWithReuseIdentifier: "TitleCell")
        inningSpreadsheetView.register(ScoreCell.self, forCellWithReuseIdentifier: "ScoreCell")
        
        // batting picker logic
        battingTeamPicker.delegate = self
        battingTeamPicker.dataSource = self
        
        // batting spreadsheetview logic
        battingSpreadsheetView.delegate = self
        battingSpreadsheetView.dataSource = self
        battingSpreadsheetView.register(TitleCell.self, forCellWithReuseIdentifier: "TitleCell")
        battingSpreadsheetView.register(ScoreCell.self, forCellWithReuseIdentifier: "ScoreCell")
        
        if let gameDataDirectoryURL = gameDataDirectoryURL {
            getMLBGameDetailData(url: gameDataDirectoryURL)
        }
    }
    
    // MARK: - API call
    func getMLBGameDetailData(url: String) {
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    self.networkCallFailView.isHidden = true
                    
                    let resultValue = response.result.value ?? ""
                    let resultJSON = JSON(resultValue)
                    let gameDetailJSON = resultJSON["data"]["boxscore"]
                    
                    self.updateInningData(gameDetailJSON: gameDetailJSON)
                    
                    // batting logic
                    let battingJSON = gameDetailJSON["batting"]
                    let homeTeamName = gameDetailJSON["home_fname"].stringValue
                    let awayTeamName = gameDetailJSON["away_fname"].stringValue
                    self.teamNames = [homeTeamName, awayTeamName]
                    
                    self.updateBattingData(battingJSON: battingJSON, teamNames: self.teamNames)
                    
                } else {
                    self.networkCallFailView.isHidden = false
                }
            }
    }
    
    // MARK: - Innings JSON logic
    func updateInningData(gameDetailJSON: JSON) {
        
        // inning by inning data extraction
        let homeTeamCode = gameDetailJSON["home_team_code"].stringValue,
            awayTeamCode = gameDetailJSON["away_team_code"].stringValue
        
        homeTeamName = homeTeamCode.uppercased()
        awayTeamName = awayTeamCode.uppercased()
        
        let linescoreJSON = gameDetailJSON["linescore"]
        
        let homeTeamRuns = linescoreJSON["home_team_runs"].intValue,
            homeTeamHits = linescoreJSON["home_team_hits"].intValue,
            homeTeamErrors = linescoreJSON["home_team_errors"].intValue
        
        let awayTeamRuns = linescoreJSON["away_team_runs"].intValue,
            awayTeamHits = linescoreJSON["away_team_hits"].intValue,
            awayTeamErrors = linescoreJSON["away_team_errors"].intValue
        
        let inningsJSON = linescoreJSON["inning_line_score"]
        
        for (_, inning) in inningsJSON {
            
            let inningNumber = inning["inning"].stringValue
            let homeInning = inning["home"].intValue
            let awayInning = inning["away"].intValue
            
            inningInfoHeaders.append(inningNumber)
            homeTeamInnings.append(homeInning)
            awayTeamInnings.append(awayInning)
            
        }
        
        inningInfoHeaders += ["R", "H", "E"]
        homeTeamInnings += [homeTeamRuns, homeTeamHits, homeTeamErrors]
        awayTeamInnings += [awayTeamRuns, awayTeamHits, awayTeamErrors]
        
        inningSpreadsheetView.reloadData()
        
    }
    
    // MARK: - Batting JSON logic
    func updateBattingData(battingJSON: JSON, teamNames: [String]) {
        
        battingTeamPickerData = teamNames
        battingTeamPicker.reloadAllComponents()
        
        if let batterListJSON = battingJSON.array {
            
            let homeTeamBattersJSON = batterListJSON[0]["batter"].array ?? []
            let awayTeamBattersJSON = batterListJSON[1]["batter"].array ?? []
            
            for homeTeamBatter in homeTeamBattersJSON {
                
                let batterName = homeTeamBatter["name"].stringValue,
                    batterAB = homeTeamBatter["ab"].stringValue,
                    batterR = homeTeamBatter["r"].stringValue,
                    batterH = homeTeamBatter["h"].stringValue,
                    batterRBI = homeTeamBatter["rbi"].stringValue,
                    batterBB = homeTeamBatter["bb"].stringValue,
                    batterSO = homeTeamBatter["so"].stringValue,
                    batterAVG = homeTeamBatter["avg"].stringValue
                
                let homeTeamBatterInstance = [batterName, batterAB, batterR, batterH, batterRBI, batterBB, batterSO, batterAVG]
                homeTeamBatters.append(homeTeamBatterInstance)
                
            }
            
            for awayTeamBatter in awayTeamBattersJSON {
                
                let batterName = awayTeamBatter["name"].stringValue,
                    batterAB = awayTeamBatter["ab"].stringValue,
                    batterR = awayTeamBatter["r"].stringValue,
                    batterH = awayTeamBatter["h"].stringValue,
                    batterRBI = awayTeamBatter["rbi"].stringValue,
                    batterBB = awayTeamBatter["bb"].stringValue,
                    batterSO = awayTeamBatter["so"].stringValue,
                    batterAVG = awayTeamBatter["avg"].stringValue
                
                let awayTeamBatterInstance = [batterName, batterAB, batterR, batterH, batterRBI, batterBB, batterSO, batterAVG]
                awayTeamBatters.append(awayTeamBatterInstance)
                
            }
            
            batters = [homeTeamBatters, awayTeamBatters]
            battingSpreadsheetView.reloadData()
            
        }
        
    }

}

// MARK: - SpreadsheetViewDataSource, SpreadsheetViewDelegate
extension GameDetailViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if spreadsheetView == inningSpreadsheetView {
            return 40
        } else {
            return 110
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 50
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == inningSpreadsheetView {
            return inningInfoHeaders.count
        } else {
            return battingInfoHeaders.count
        }
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == inningSpreadsheetView {
            return 1
        }
        
        return 0
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == inningSpreadsheetView {
            return 3
        } else {
            
            if !homeTeamBatters.isEmpty && !awayTeamBatters.isEmpty {
                return batters[battingTeamPickerIndex].count + 1
            }
        }
        return 1
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        if spreadsheetView == battingSpreadsheetView {
            return 1
        }
        
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        
        // inning-by-inning spreadsheet
        if spreadsheetView == inningSpreadsheetView {
            if !awayTeamInnings.isEmpty && !homeTeamInnings.isEmpty {
                
                switch (indexPath.column, indexPath.row) {
                case (1...inningInfoHeaders.count, 0):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "TitleCell", for: indexPath) as! TitleCell
                    cell.titleLabel.text = inningInfoHeaders[indexPath.column]
                    return cell
                    
                case (0, 1):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "TitleCell", for: indexPath) as! TitleCell
                    cell.titleLabel.text = homeTeamName
                    return cell
                    
                case (0, 2):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "TitleCell", for: indexPath) as! TitleCell
                    cell.titleLabel.text = awayTeamName
                    return cell
                    
                case (1...homeTeamInnings.count, 1):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = "\(homeTeamInnings[indexPath.column - 1])"
                    return cell
                    
                case (1...awayTeamInnings.count, 2):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = "\(awayTeamInnings[indexPath.column - 1])"
                    return cell
                    
                default:
                    return nil
                }
            }
        } else {
            // batting spreadsheet
            if !homeTeamBatters.isEmpty && !awayTeamBatters.isEmpty {
                
                let currentTeam = batters[battingTeamPickerIndex]
                let currentRange = currentTeam.count
                
                switch (indexPath.column, indexPath.row) {
                case (0...battingInfoHeaders.count, 0):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "TitleCell", for: indexPath) as! TitleCell
                    cell.titleLabel.text = battingInfoHeaders[indexPath.column]
                    return cell
                    
                case (0, 1...currentRange):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = currentTeam[indexPath.row - 1][0]
                    return cell
                    
                case (1, 1...currentRange):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = currentTeam[indexPath.row - 1][1]
                    return cell
                    
                case (2, 1...currentRange):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = currentTeam[indexPath.row - 1][2]
                    return cell
                    
                case (3, 1...currentRange):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = currentTeam[indexPath.row - 1][3]
                    return cell
                    
                case (4, 1...currentRange):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = currentTeam[indexPath.row - 1][4]
                    return cell
                    
                case (5, 1...currentRange):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = currentTeam[indexPath.row - 1][5]
                    return cell
                    
                case (6, 1...currentRange):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = currentTeam[indexPath.row - 1][6]
                    return cell
                    
                case (7, 1...currentRange):
                    let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as! ScoreCell
                    cell.scoreLabel.text = currentTeam[indexPath.row - 1][7]
                    return cell
                    
                default:
                    return nil
                }
            }
        }
    
        return nil
    }
    
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension GameDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if !battingTeamPickerData.isEmpty {
            return battingTeamPickerData[row]
        }
        
        return "Loading data..."
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        battingTeamPickerIndex = row
        battingSpreadsheetView.reloadData()
    }
    
}
