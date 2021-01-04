//
//  CategoryViewController.swift
//  FilmBookSerial
//
//  Created by Екатерина Григорьева on 29.12.2020.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = ["Films","Books","Serials","Games"]
    var itemArray = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
    
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)
        
        var action = [UIAlertAction]()
        for i in 0...categories.count-1{
            action.append(UIAlertAction(title: categories[i], style: .default){[self] (action) in
                let newItem = Items(context: self.context)
                newItem.title = textField.text!
                newItem.category = categories[i]
                newItem.status = false
                self.itemArray.append(newItem)
                self.saveItems()
            })
            alert.addAction(action[i])
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (alertText) in
            alertText.placeholder = "Create New Item"
            textField = alertText
            print(alertText)
        }
        
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toItems", sender: self)
        print("\(categories[indexPath.row]) njbbjbmj" )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            print(categories[indexPath.row])
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error saving context \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest()) {
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching request \(error)")
        }
        tableView.reloadData()
    }
    
    func deleteAllData(entity: String)
    {
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do { try context.execute(DelAllReqVar) }
        catch { print(error) }
    }
}
