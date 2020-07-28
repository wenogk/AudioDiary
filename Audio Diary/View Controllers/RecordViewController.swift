//
//  RecordViewController.swift
//  Audio Diary
//
//  Created by Romeno Wenogk Fernando on 27/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    
    enum recordingStates {
        case notRecording
        case recording
        case paused
    }
    
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var timerLabel: UILabel!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: AVAudioPlayer?
    var recordingState: recordingStates = .notRecording;
    
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var previousTime:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
       setupAudioRecording()
    }
    
    @IBAction func stopRecordingTap(_ sender: Any) {
        
        if(recordingState == .recording || recordingState == .paused) {
            finishRecording(success: true)
        }
        print(recordingState)
    }
    
    @IBAction func onRecordButtonTap(_ sender: Any) {
        // Run record and stop recording logic here
       
        if recordingState == .notRecording{
            startRecording()
        } else if recordingState == .paused {
            resumeRecording()
        } else if recordingState == .recording {
            pauseRecording()
        }
        print(recordingState)
    }
    // MARK: - Timer function
    func startTimer(_ startTimeVal:Double) {
        startTime = startTimeVal;
        timer = Timer.scheduledTimer(timeInterval: 0.05,
                                     target: self,
                                     selector: #selector(advanceTimer(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func pauseTimer() {
        previousTime = startTime;
        timer?.invalidate()
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    @objc func advanceTimer(timer: Timer) {

      //Total time since timer started, in seconds
      time = Date().timeIntervalSinceReferenceDate - startTime

      //The rest of your code goes here
        
      //Convert the time to a string with 2 decimal places
        
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        let timeString =  String(format:"%02i:%02i", minutes, seconds)
      //let timeString = String(format: "%.2f", time)

      //Display the time string to a label in our view controller
      timerLabel.text = timeString
    }
    
    
    // MARK: - Audio Recording Functions
    
    func setupAudioRecording() {
        
        // Check if recording permission is given and then allow for visible record button
        
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func pauseRecording() {
        
        if recordingState == .recording {
            pauseTimer()
            audioRecorder?.pause()
            recordingState = .paused
        }
        
    }
    
    func resumeRecording() {
        
        if recordingState == .paused {
            startTimer(previousTime!);
            audioRecorder?.record()
            recordingState = .recording
        }
        
    }
    
    func startRecording() {
        
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            recordingState = .recording;
            startTimer(Date().timeIntervalSinceReferenceDate)
            //recordButton.setImage(UIImage(contentsOfFile: ""), for: .selected)
            print("started recording")
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            let url = getDocumentsDirectory().appendingPathComponent("recording.m4a")
                       do {
                          recordedAudio = try AVAudioPlayer(contentsOf: url)
                           recordedAudio?.play()
                       } catch {
                           // couldn't load file :(
                       }
            recordingState = .notRecording
            print("finished recording")
            stopTimer()
            //recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            //recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
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
