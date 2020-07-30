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
    
    @IBOutlet var positiveLabel: UILabel!
    
    @IBOutlet var negativeLabel: UILabel!
    
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
        positiveLabel.text = "Positive: \(audioItem!.positiveProbability)"
        negativeLabel.text = "Negative: \(audioItem!.negativeProbability)"
        
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
        //Prevent further execution if audioItem is empty
        guard audioItem != nil else {
            return;
        }
        
        //call playAudio function to play the current audio
        playAudio(fileName: audioItem!.audioFileName!);  
    }
    
    func playAudio(fileName: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            print(" playing \(url) ")
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            // couldn't load file :(
            print("couldn't play audio :( \(error)")
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
