//
//  DetailedRecordingViewController.swift
//  Audio Diary
//
//  Created by Romeno Wenogk Fernando on 27/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//

import UIKit
import AVFoundation

class DetailedRecordingViewController: UIViewController {
    
    var audioItem:AudioItem?;
    
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet var titleLabel: UILabel!
    
    
    
    @IBOutlet var transcribedText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prevent further execution if audioItem is empty
        guard audioItem != nil else {
            return;
        }
        
        //Set title label and transcribed text view to audio item info
        titleLabel.text = "\(audioItem!.dateTime!)"
        transcribedText.text = String(audioItem!.transcribed!)
        
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
        //Prevent further execution if audioItem is empty
        guard audioItem != nil else {
            return;
        }
        
        //call playAudio function to play the current audio
        playAudio(url: audioItem!.audioFilePath!);
    }
    
    func playAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            // couldn't load file :(
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
