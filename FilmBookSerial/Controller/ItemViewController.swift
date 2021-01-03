//
//  ItemViewController.swift
//  FilmBookSerial
//
//  Created by Екатерина Григорьева on 29.12.2020.
//

import UIKit
import CoreData

class ItemViewController: UITableViewController {
    
    var itemArray: [Items]?
    
    var selectedCategory: String?
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
        title = selectedCategory
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = itemArray?[indexPath.row]
        cell.textLabel?.text = item!.title
        cell.accessoryType = item!.status ? .checkmark : .none //для постановки галочки или снятия (при повторном нажатии)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = itemArray{
            item[indexPath.row].status = !item[indexPath.row].status
            saveItems()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, handler) in
            self.context.delete(self.itemArray![indexPath.row])
            self.itemArray?.remove(at: indexPath.row)
            self.saveItems()
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { (action, view, handler) in
            var textField = UITextField()
            let alert = UIAlertController(title: "Change", message: "", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Save", style: .default){[self] (action) in
                itemArray?[indexPath.row].setValue(textField.text!, forKey: "title")
                self.saveItems()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addTextField { (alertText) in
                alertText.placeholder = "Change Item"
                textField = alertText
                print(alertText)
            }
            
            alert.addAction(cancel)
            alert.addAction(alertAction)
            
            self.present(alert, animated: true)
            
            self.saveItems()
        }
        
        editAction.image = UIImage(systemName: "square.and.pencil")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error saving items \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest(), predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "category MATCHES %@", selectedCategory!)
        request.predicate = categoryPredicate
        
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

