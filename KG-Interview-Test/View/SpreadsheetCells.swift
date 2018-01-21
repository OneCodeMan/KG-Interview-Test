//
//  SpreadsheetCells.swift
//  KG-Interview-Test
//
//  Created by Dave Gumba on 2018-01-20.
//  Copyright © 2018 Dave's Organization. All rights reserved.
//

import UIKit
import SpreadsheetView

class TitleCell: Cell {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.frame = bounds
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ScoreCell: Cell {
    let scoreLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scoreLabel.frame = bounds
        scoreLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scoreLabel.font = UIFont.systemFont(ofSize: 12)
        scoreLabel.textAlignment = .center
        
        contentView.addSubview(scoreLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


