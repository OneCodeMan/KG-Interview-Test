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

class GameDetailViewController: UIViewController {
    
    var gameDataDirectoryURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let gameDataDirectoryURL = gameDataDirectoryURL {
            getMLBGameDetailData(url: gameDataDirectoryURL)
        }
    }
    
    func getMLBGameDetailData(url: String) {
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    let resultValue = response.result.value ?? ""
                    let resultJSON = JSON(resultValue)
                    let gameDetailJSON = resultJSON["data"]["boxscore"]
                    
                    // linescore
                    let linescoreJSON = gameDetailJSON["linescore"]
                    print(linescoreJSON)
                    
                    // batting
                    let battingJSON = gameDetailJSON["batting"]
                    //print(battingJSON)
                    
                    let homeTeamCode = "\(gameDetailJSON["home_team_code"])".uppercased()
                    print(homeTeamCode)
                    let awayTeamCode = "\(gameDetailJSON["away_team_code"])".uppercased()
                    print(awayTeamCode)
                    
                    
                } else {

                    
                }
        }
    }

}
