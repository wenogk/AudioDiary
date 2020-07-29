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
    
    @IBOutlet var mainCellHolder: UIView!
    
    var audioItem:AudioItem?;
    
    func setupCell(audioItem: AudioItem) {
        
        mainCellHolder.layer.cornerRadius = 8  
        
        self.audioItem = audioItem;
        
        guard audioItem != nil else { return; }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dateString = formatter.string(from: audioItem.dateTime!)
        dateLabel.text = dateString

        excerptLabel.text = audioItem.transcribed!
        
        //set background color of table cell subview based on model classification
            var color:UIColor!
            // change color to green or red based on whether it is a more positive or negative text
            if(audioItem.negativeProbability > audioItem.positiveProbability) {
                color = UIColor(red: 1, green: 0, blue: 0, alpha: CGFloat(audioItem.negativeProbability))
            } else {
                color = UIColor(red: 0, green: 1, blue: 0, alpha: CGFloat(audioItem.positiveProbability))
            }
            
            mainCellHolder.backgroundColor = color;
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
