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
    var quantityOfItems: Int?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()

        if let category = selectedCategory {
            title = category.name
        }
    }

    // MARK: - TableView dataSource

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
        if let item = itemArray {
            item[indexPath.row].status = !item[indexPath.row].status
            saveItems()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    //MARK: - SWIPE влево (редактирование и удаление)

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, handler) in
            self.context.delete(self.itemArray![indexPath.row])
            self.itemArray?.remove(at: indexPath.row)
            self.selectedCategory?.quantity -= 1
            self.saveItems()

        }
        deleteAction.image = UIImage(systemName: "trash")

        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { (action, view, handler) in
            var textField = UITextField()
            let alert = UIAlertController(title: "Change", message: "", preferredStyle: .alert)

            let alertAction = UIAlertAction(title: "Save", style: .default) { [self] (action) in
                itemArray?[indexPath.row].setValue(textField.text!, forKey: "title")
                self.saveItems()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alert.addTextField { (alertText) in
                if let text = self.itemArray?[indexPath.row].title{
                    alertText.text = "\(text)"
                }
                textField = alertText
                print(alertText)
            }

            alert.addAction(cancel)
            alert.addAction(alertAction)

            self.present(alert, animated: true)

            self.saveItems()
        }

        editAction.image = UIImage(systemName: "square.and.pencil")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    //MARK: - SWIPE вправо (поделиться)

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let shareAction = UIContextualAction(style: .normal, title: "Поделиться") { (action, view, handler) in
            let textToShare: [Any] = [self.itemArray![indexPath.row].title!]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true)

        }
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        let configuration = UISwipeActionsConfiguration(actions: [shareAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    //MARK: - CRUD
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving items \(error)")
        }
        tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest()) {

        let categoryPredicate = NSPredicate(format: "category MATCHES %@", selectedCategory!.name!)
        request.predicate = categoryPredicate

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

