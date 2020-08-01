//
//  StatsViewController.swift
//  Audio Diary
//
//  Created by Romeno Wenogk Fernando on 27/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//

import UIKit
import Charts
import CoreData
import AVFoundation

class StatsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
   
    @IBOutlet var stackView: UIStackView!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    var positivityLineChart = LineChartView();
    var negativityLineChart = LineChartView();
    var pieChart = PieChartView();
    
    var audioItems:[AudioItem]?
    
    var totalAudioSeconds:Double = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Statistics"
        
        positivityLineChart.delegate = self;
        negativityLineChart.delegate = self;
        pieChart.delegate = self;
        
        //negativityLineChart.widthAnchor.constraint(equalToConstant: 400).isActive = true
       // negativityLineChart.heightAnchor.constraint(equalToConstant: 300).isActive = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        //scrollView.contentSize.height = 2000
        
        
        // Do any additional setup after loading the view.
        //positivityLineChart.backgroundColor = UIColor(red: 104/255, green: 241/255, blue: 175/255, alpha: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchAudioItems()
    }
    
    func fetchAudioItems() {
        
        do {
            let request = AudioItem.fetchRequest() as NSFetchRequest<AudioItem>
            
            let sort = NSSortDescriptor(key: "dateTime", ascending: true)
            
            request.sortDescriptors = [sort]
            
            self.audioItems = try context.fetch(request)
            
            DispatchQueue.main.async {
                //self.tableView.reloadData();
                self.processAllAudioItemData();
                self.positivityLineChart.notifyDataSetChanged(); // let the chart know it's data changed
                self.negativityLineChart.notifyDataSetChanged();
                self.pieChart.notifyDataSetChanged()
                let contentRect: CGRect = self.stackView.subviews.reduce(into: .zero) { rect, view in
                    rect = rect.union(view.frame)
                }
                self.scrollView.contentSize = contentRect.size
               // self.barChart.invalidate(); // refresh
            }
            
        } catch {
            
        }
        
        
    }
    
    func generateStyledDataSetForLineChart(entries: [ChartDataEntry], label: String, fillColor: UIColor) -> LineChartDataSet {
        let set = LineChartDataSet(entries: entries, label: label);
        set.mode = .cubicBezier
        set.drawCirclesEnabled = false
        set.lineWidth = 1.8
        set.circleRadius = 4
        set.setCircleColor(.white)
        set.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set.fillColor = fillColor
        set.fillAlpha = 1
        set.drawFilledEnabled = true;
        
        return set;
    }
    
    func processAllAudioItemData() {
        
        guard self.audioItems != nil else { return; }
        
        var positiveLineChartEntries = [ChartDataEntry]()
        var negativeLineChartEntries = [ChartDataEntry]()
        var pieChartEntries = [ChartDataEntry]()
        
        var positiveCount = 0;
        var negativeCount = 0;
        
        for x in 1...self.audioItems!.count {
            
            totalAudioSeconds += audioDuration(for: self.audioItems![x-1].audioFileName!)
            
            positiveLineChartEntries.append(ChartDataEntry(x: Double(x), y: self.audioItems![x-1].positiveProbability));
            negativeLineChartEntries.append(ChartDataEntry(x: Double(x), y: self.audioItems![x-1].negativeProbability));
            
            if(self.audioItems![x-1].positiveProbability > self.audioItems![x-1].negativeProbability) {
                positiveCount += 1;
            } else {
                negativeCount += 1;
            }
            
        }
        
        let positiveLineChartSet = generateStyledDataSetForLineChart(entries: positiveLineChartEntries, label: "positive",fillColor: UIColor(red: 0, green: 1, blue: 0, alpha: 0.5))
         let negativeLineChartSet = generateStyledDataSetForLineChart(entries: negativeLineChartEntries, label: "negative",fillColor: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5))
        // set.drawHorizontalHighlightIndicatorEnabled = false
         let positiveLineChartData = LineChartData(dataSet: positiveLineChartSet)
        let negativeLineChartData = LineChartData(dataSet: negativeLineChartSet)
         positivityLineChart.data = positiveLineChartData;
        negativityLineChart.data = negativeLineChartData;
        
        pieChartEntries.append(PieChartDataEntry(value: 1, label: "Positive", data:  Double(positiveCount) as AnyObject))
        pieChartEntries.append(PieChartDataEntry(value: 2, label: "Negative", data:  Double(negativeCount) as AnyObject))
           
        let pieChartSet = PieChartDataSet(entries: pieChartEntries)
        pieChartSet.colors = ChartColorTemplates.vordiplom()
        + ChartColorTemplates.joyful()
        + ChartColorTemplates.colorful()
        + ChartColorTemplates.liberty()
        + ChartColorTemplates.pastel()
        + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
           
          // set.drawHorizontalHighlightIndicatorEnabled = false
           let pieChartData = PieChartData(dataSet: pieChartSet)
           pieChart.data = pieChartData;
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();

        positivityLineChart.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: self.view.frame.width)
        
        negativityLineChart.frame = CGRect(x: 0, y: self.view.frame.width + 50, width: self.view.frame.width, height: self.view.frame.width)
        
        pieChart.frame = CGRect(x: 0, y: self.view.frame.width * 2 + 50, width: self.view.frame.width, height: self.view.frame.width)
        
        
        stackView.addSubview(positivityLineChart)
        stackView.addSubview(negativityLineChart)
        stackView.addSubview(pieChart)
        
        
    }
    //function for getting the duration of audio duration from filePath
    func audioDuration(for resource: String) -> Double {
        let audioFilePath = getDocumentsDirectory().appendingPathComponent(resource)
        let asset = AVURLAsset(url: audioFilePath)
        return Double(CMTimeGetSeconds(asset.duration))
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
