//
//  CategoryViewController.swift
//  Todoey
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    private let realm = try! Realm()
    
    private var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navBar = navigationController?.navigationBar {
            navBar.backgroundColor = .white
        }
    }
    
    //MARK:- TableView Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let category = categories?[indexPath.row]
        
        cell.backgroundColor = UIColor(hexString: (category?.backgroundColor) ?? K.whiteHex)
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: false)
        
        cell.textLabel?.text = category?.name
        
        return cell
    }
    
    //MARK:- TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: K.goToItems, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
    }
    
    //MARK:- Data Manipulation Methods
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var result = UITextField()
        
        let aler = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let safeName = result.text {
                
                let category = Category()
                category.name = safeName
                category.backgroundColor = UIColor.randomFlat().hexValue()
                
                self.save(category)
                
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
    
    private func save(_ category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error while saving data \(error)")
        }
    }
    
    private func loadData() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error while update: \(error)")
            }
        }
    }
}
