//
//  Game.swift
//  KG-Interview-Test
//
//  Created by Dave Gumba on 2018-01-19.
//  Copyright © 2018 Dave's Organization. All rights reserved.
//

import Foundation

struct Game {
    let homeTeam: String
    let homeTeamScore: Int
    let awayTeam: String
    let awayTeamScore: Int
    let status: String
    
    init(homeTeam: String, homeTeamScore: Int, awayTeam: String, awayTeamScore: Int, status: String) {
        self.homeTeam = homeTeam
        self.homeTeamScore = homeTeamScore
        self.awayTeam = awayTeam
        self.awayTeamScore = awayTeamScore
        self.status = status
    }
    
}
