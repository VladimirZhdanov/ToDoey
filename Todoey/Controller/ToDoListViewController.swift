//
//  ViewController.swift
//  Todoey
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
     }
    
    var items = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer
        .viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //TableView DataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.toDoItemCell, for: indexPath)
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.isDone ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        items[indexPath.row].isDone = !items[indexPath.row].isDone
        
        
        //        context.delete(items[indexPath.row])
        //        items.remove(at: indexPath.row)
        
        saveData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Add new item
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var resultItem = UITextField()
        
        let aler = UIAlertController(title: "Add ToDo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let safeTitle = resultItem.text {
                
                let item = Item(context: self.context)
                item.title = safeTitle
                //item.isDone = false
                item.parentCategory = self.selectedCategory
                
                self.items.append(item)
                
                self.saveData()
                
                self.tableView.reloadData()
            }
        }
        
        aler.addTextField { (alerTextField) in
            alerTextField.placeholder = "Item name"
            resultItem = alerTextField
        }
        
        aler.addAction(action)
        
        present(aler, animated: true, completion: nil)
    }
    
    private func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error while saving data \(error)")
        }
    }
    
    private func loadData(_ request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
       // let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error while featching data: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    
    
}

//MARK:- SearchView Delegate

extension ToDoListViewController: UISearchBarDelegate  {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
        
        let sortDescriptr = NSSortDescriptor(key: "title", ascending: true)
        
        request.sortDescriptors = [sortDescriptr]
        
        loadData(request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadData()
            
            DispatchQueue.main.async {
                
                searchBar.resignFirstResponder()
            }
        }
    }
}

