//
//  RecordViewController.swift
//  Audio Diary
//
//  Created by Romeno Wenogk Fernando on 27/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import Speech

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    enum recordingStates {
        case notRecording
        case recording
        case paused
    }
    
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var timerLabel: UILabel!
    
    //Recording related instance variables
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: AVAudioPlayer?
    var recordingState: recordingStates = .notRecording;
    var audioFilename: URL!
    
    //Timer instance variables
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var previousTime:Double?
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    var audioItems:[AudioItem]?;
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        fetchAudios()
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
    
    
    // MARK: - SFSpeechRecognizer stuff
    
    func audioUrlToTextAndSave(url:URL) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        request.shouldReportPartialResults = false
        if (recognizer?.isAvailable)! {
            
            recognizer?.recognitionTask(with: request) { result, error in
                guard error == nil else { print("Error: \(error!)"); return }
                guard let result = result else { print("No result!"); return }
                
                // get the best transcribed version of the audio file as a string
                let transcribedText = result.bestTranscription.formattedString
                
                //Classify transcribed text using sentiment analysis Core ML model
                let sentimentAnalysisClassificationDictionary = SentimentClassificationService.instance.prediction(from: transcribedText)
                
                //call the function that updates the model with the new transcribed text and classification values
                self.updateTranscribedAndClassification(filepath: url, transcribed: transcribedText, classificationDictionary: sentimentAnalysisClassificationDictionary)
            }
        } else {
            print("Device doesn't support speech recognition")
        }
    }
    // MARK: - Core Data Functions
    
    func fetchAudios() {
        do {
            self.audioItems = try context.fetch(AudioItem.fetchRequest())
        } catch {
            
        }
    }
    
    func createNewAudioItem(filepath:URL, dateTime date:Date, transcribed: String) {
        
        let newAudioItem = AudioItem(context: self.context)
        
        newAudioItem.audioFilePath = filepath;
        newAudioItem.dateTime = date;
        newAudioItem.transcribed = transcribed;
        
        do {
            try self.context.save()
        } catch {
            print("error saving data")
        }
        
    }
    
    func updateTranscribedAndClassification(filepath:URL, transcribed: String, classificationDictionary: [String:Double]?) {
        
        guard audioItems != nil else { return; }
        var audioItem:AudioItem?
        for item in audioItems! {
            if item.audioFilePath! == filepath {
                audioItem = item;
            }
        }
        
        if audioItem != nil {
            audioItem?.transcribed = transcribed;
        
            
            do {
                try self.context.save()
            } catch {
                print("error updating transcribed")
            }
        }
        
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
        
        let audiosCount = audioItems?.count ?? 0;
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        audioFilename = getDocumentsDirectory().appendingPathComponent("\(Constants.AUDIO_FILE_NAME_PREFIX)_\(timestamp)_\(audiosCount+1).m4a")
        
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
            recordingState = .notRecording
            stopTimer()
            let dateTime = Date();
            createNewAudioItem(filepath: audioFilename, dateTime: dateTime, transcribed: "sample")
            fetchAudios()
            audioUrlToTextAndSave(url: audioFilename)
            
            
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
    
    // MARK: - Timer functions
    
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
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
