//
//  RecordedItemTableViewCell.swift
//  AudioDiary
//
//  Created by Romeno Wenogk Fernando on 29/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//

import UIKit

class RecordedItemTableViewCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var excerptLabel: UILabel!
    
    var audioItem:AudioItem?;
    
    func setupCell(audioItem: AudioItem) {
        
        self.audioItem = audioItem;
        
        guard audioItem != nil else { return; }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dateString = formatter.string(from: audioItem.dateTime!)
        dateLabel.text = dateString
        
        excerptLabel.text = audioItem.transcribed!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
