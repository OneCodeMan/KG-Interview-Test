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
    
    // MARK: Inning by inning variables
    @IBOutlet weak var inningSpreadsheetView: SpreadsheetView!
    var inningInfoHeaders = [""]
    var homeTeamName = ""
    var homeTeamInnings = [Int]()
    var awayTeamName = ""
    var awayTeamInnings = [Int]()
    
    // MARK: Batting variables
    @IBOutlet weak var battingTeamPicker: UIPickerView!
    var battingTeamPickerData = [String]()
    
    var gameDataDirectoryURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if let gameDataDirectoryURL = gameDataDirectoryURL {
            getMLBGameDetailData(url: gameDataDirectoryURL)
        }
    }
    
    // MARK: API call
    
    func getMLBGameDetailData(url: String) {
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    let resultValue = response.result.value ?? ""
                    let resultJSON = JSON(resultValue)
                    let gameDetailJSON = resultJSON["data"]["boxscore"]
                    
                    self.updateInningData(gameDetailJSON: gameDetailJSON)
                    
                    // batting logic
                    let battingJSON = gameDetailJSON["batting"]
                    let homeTeamName = gameDetailJSON["home_fname"]
                    let awayTeamName = gameDetailJSON["away_fname"]
                    let teamNames = ["\(homeTeamName)", "\(awayTeamName)"]
                    
                    self.updateBattingData(battingJSON: battingJSON, teamNames: teamNames)
                    
                } else {
                    print("Network call failed")
                }
            }
    }
    
    // MARK: Innings JSON logic
    
    func updateInningData(gameDetailJSON: JSON) {
        
        // inning by inning data extraction
        let homeTeamCode = "\(gameDetailJSON["home_team_code"])",
            awayTeamCode = "\(gameDetailJSON["away_team_code"])"
        
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
            
            let inningNumber = "\(inning["inning"])"
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
    
    // MARK: Batting JSON logic
    
    func updateBattingData(battingJSON: JSON, teamNames: [String]) {
        battingTeamPickerData = teamNames
        battingTeamPicker.reloadAllComponents()
    }

}

extension GameDetailViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 40
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 50
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return inningInfoHeaders.count
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 3
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        
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
        return nil
    }
    
}

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
    
}
