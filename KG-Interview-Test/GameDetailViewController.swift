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
    var inningInfoHeaders = [String]()
    var homeTeamCode = ""
    var homeTeamInnings = [Int]()
    var awayTeamCode = ""
    var awayTeamInnings = [Int]()
    
    var gameDataDirectoryURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inningSpreadsheetView.delegate = self
        inningSpreadsheetView.dataSource = self
        
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
                    
                    // inning by inning data extraction
                    self.homeTeamCode = "\(gameDetailJSON["home_team_code"])".uppercased()
                    self.awayTeamCode = "\(gameDetailJSON["away_team_code"])".uppercased()
                    
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
                        
                        self.inningInfoHeaders.append(inningNumber)
                        self.homeTeamInnings.append(homeInning)
                        self.awayTeamInnings.append(awayInning)
                        
                    }
                    
                    self.inningInfoHeaders += ["R", "H", "E"]
                    self.homeTeamInnings += [homeTeamRuns, homeTeamHits, homeTeamErrors]
                    self.awayTeamInnings += [awayTeamRuns, awayTeamHits, awayTeamErrors]
                    
                    
                    // batting data extraction
                    
                    let battingJSON = gameDetailJSON["batting"]
                    //print(battingJSON)
                    
                    
                    
                } else {

                    
                }
            }
    }

}

extension GameDetailViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 40
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 80
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 14
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 5
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    
}
