//
//  CategoryViewController.swift
//  Todoey
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
   private var categories = [Category]()
    //private var categories = ["1313", "qfqwf"]
    
    private let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer
        .viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    //MARK:- TableView Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let category = categories[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCell, for: indexPath)
        cell.textLabel?.text = category.name
        //cell.textLabel?.text = category
        
        return cell
    }
    
    //MARK:- TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: K.goToItems, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
        
    }
    
    //MARK:- Data Manipulation Methods
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
       
        var result = UITextField()
        
        let aler = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let safeName = result.text {
                
                let category = Category(context: self.context)
                category.name = safeName
                
                self.categories.append(category)
                
                self.saveData()
                
                self.tableView.reloadData()
            }
        }
        
        aler.addTextField { (alerTextField) in
            alerTextField.placeholder = "Category name"
            result = alerTextField
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
    
    private func loadData(_ request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
           categories = try context.fetch(request)
        } catch {
            print("Error while featching data: \(error)")
        }
        
        tableView.reloadData()
        
    }
}
