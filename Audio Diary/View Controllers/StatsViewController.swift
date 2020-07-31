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

class StatsViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet var stackView: UIStackView!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    var positivityLineChart = LineChartView();
    var negativityLineChart = LineChartView();
    
    var audioItems:[AudioItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        positivityLineChart.delegate = self;
        negativityLineChart.delegate = self;
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
                self.loadPositiveBarChartData()
                self.loadNegativeBarChartData()
                self.positivityLineChart.notifyDataSetChanged(); // let the chart know it's data changed
                self.negativityLineChart.notifyDataSetChanged();
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
    
    func loadPositiveBarChartData() {
        
        //transform data from audioItem array and create datapoints for positive bar chart
        
        var entries = [ChartDataEntry]()
        
        guard self.audioItems != nil else { return; }
        
        for x in 1...self.audioItems!.count {
            entries.append(ChartDataEntry(x: Double(x), y: self.audioItems![x-1].positiveProbability))
        }
        
        let set = generateStyledDataSetForLineChart(entries: entries, label: "positive",fillColor: UIColor(red: 0, green: 1, blue: 0, alpha: 0.5))
        
       // set.drawHorizontalHighlightIndicatorEnabled = false
        let data = LineChartData(dataSet: set)
        positivityLineChart.data = data;
    }
    
    func loadNegativeBarChartData() {
        
        //transform data from audioItem array and create datapoints for positive bar chart
        
        var entries = [ChartDataEntry]()
        
        guard self.audioItems != nil else { return; }
        
        for x in 1...self.audioItems!.count {
            entries.append(ChartDataEntry(x: Double(x), y: self.audioItems![x-1].negativeProbability))
        }
        
        let set = generateStyledDataSetForLineChart(entries: entries, label: "negative", fillColor: UIColor(red: 1, green: 0, blue: 0, alpha: 0.5))
        
       // set.drawHorizontalHighlightIndicatorEnabled = false
        let data = LineChartData(dataSet: set)
        negativityLineChart.data = data;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        positivityLineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
        
        negativityLineChart.frame = CGRect(x: 0, y: self.view.frame.width, width: self.view.frame.width, height: self.view.frame.width)
        
        
        stackView.addSubview(positivityLineChart)
        stackView.addSubview(negativityLineChart)
        
        
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
