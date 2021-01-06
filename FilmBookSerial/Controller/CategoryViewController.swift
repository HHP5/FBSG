//
//  CategoryViewController.swift
//  FilmBookSerial
//
//  Created by Екатерина Григорьева on 29.12.2020.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    var itemArray = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadCategories()
        
        // первоначальное создание фиксированный категорий
        if categories.count == 0 {
            createCategories()
        }

    }

    // для обновления числа кол-ва заметок в категории при возврате на главный экран (если заметка удалена)
    override func viewDidAppear(_ animated: Bool) {
        loadCategories()
    }


    // MARK: - TableView dataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name              
        cell.detailTextLabel?.text = "\(category.quantity)" //кол-во заметок в категории
        return cell
    }

    //MARK: - Добавление новых элементов

    @IBAction func addItemButton(_ sender: UIBarButtonItem) {

        var textField = UITextField()

        let alert = UIAlertController(title: "Add new Item", message: "", preferredStyle: .alert)

        var action = [UIAlertAction]()
        for i in 0...categories.count - 1 {
            action.append(UIAlertAction(title: categories[i].name, style: .default) { [self] (action) in
                let newItem = Items(context: self.context)
                newItem.title = textField.text!
                newItem.category = categories[i].name
                newItem.status = false
                self.itemArray.append(newItem)
                categories[i].quantity += 1
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

    //MARK: - Table View Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }

    //MARK: - Методы CoreData

    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching request \(error)")
        }
        tableView.reloadData()
    }

    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {

        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }

    func createCategories() {
        
        createCategory(name: "Films")
        createCategory(name: "Books")
        createCategory(name: "Serials")
        createCategory(name: "Games")
        saveItems()
    }

    func createCategory(name: String) {
        
        let newCategory = Category(context: self.context)
        newCategory.name = name
        newCategory.quantity = 0
        categories.append(newCategory)
    }


    func deleteAllData(entity: String){
        
        let ReqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: ReqVar)
        do {
            try context.execute(DelAllReqVar)
        } catch {
            print(error)
        }
    }

}
