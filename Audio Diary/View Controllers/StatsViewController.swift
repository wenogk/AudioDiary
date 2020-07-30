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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    var lineChart = LineChartView();
    
    var audioItems:[AudioItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart.delegate = self;
        // Do any additional setup after loading the view.
        
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
                self.loadBarChartData()
                self.lineChart.notifyDataSetChanged(); // let the chart know it's data changed
               // self.barChart.invalidate(); // refresh
            }
            
        } catch {
            
        }
        
        
    }
    
    func loadBarChartData() {
        var entries = [ChartDataEntry]()
        
        guard self.audioItems != nil else { return; }
        
        for x in 1...self.audioItems!.count {
            entries.append(ChartDataEntry(x: Double(x), y: self.audioItems![x-1].positiveProbability))
        }
        
        let set = LineChartDataSet(entries: entries);
        let data = LineChartData(dataSet: set)
        lineChart.data = data;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
        
        lineChart.center = view.center
        
        view.addSubview(lineChart)
        
        
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
