//
//  RecordingsViewController.swift
//  Audio Diary
//
//  Created by Romeno Wenogk Fernando on 27/07/2020.
//  Copyright © 2020 Romeno Wenogk Fernando. All rights reserved.
//

import UIKit
import CoreData

class RecordingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    var audioItems:[AudioItem]?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Your entries"
        tableView.delegate = self;
        tableView.dataSource = self;
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Get audio items from Core Data
        fetchAudioItems();
    }
    // MARK: - Core Data Fetch Methods
    
    func fetchAudioItems() {
        
        do {
            let request = AudioItem.fetchRequest() as NSFetchRequest<AudioItem>
            
            let sort = NSSortDescriptor(key: "dateTime", ascending: false)
            
            request.sortDescriptors = [sort]
            
            self.audioItems = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData();
            }
            
        } catch {
            
        }
        
        
    }
    // MARK: - Table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioItems?.count ?? 0;
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordedItem", for: indexPath)
        
        let audioItem = self.audioItems![indexPath.row]
        
        cell.textLabel?.text = "\(audioItem.dateTime!)";
        return cell;
        
     }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //which audio item to remove
            let audioItemToRemove = self.audioItems![indexPath.row];
            
            //delete it from the context
            self.context.delete(audioItemToRemove)
            
            do {
                //save the context
                try self.context.save()
            } catch {
                
            }
            
            self.fetchAudioItems()
            
        }
        
        return UISwipeActionsConfiguration(actions: [action])
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
