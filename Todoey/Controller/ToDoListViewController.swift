//
//  ViewController.swift
//  Todoey
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    private let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
    
    var items: Results<Item>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let colorBack = UIColor(hexString: selectedCategory?.backgroundColor ?? K.whiteHex),
           let navBar = navigationController?.navigationBar {
            
                navBar.backgroundColor = colorBack
                navBar.tintColor = ContrastColorOf(UIColor(hexString: colorBack.hexValue())!, returnFlat: false)
                searchBar.barTintColor = colorBack
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(colorBack, returnFlat: false)]
            
            // To change status bar color 
//            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
//                    statusBar.backgroundColor = UIColor.black
//            statusBar.tintColor = ContrastColorOf(UIColor.black, returnFlat: false)
//                    UIApplication.shared.keyWindow?.addSubview(statusBar)
        }
        
        navigationItem.title = selectedCategory?.name
    }
    
    //MARK:- TableView DataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row] {
            
            if let color = UIColor(hexString: selectedCategory?.backgroundColor ?? K.whiteHex)?.darken(byPercentage: CGFloat(Double(indexPath.row) / Double(items!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: false)
            }
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none
        }
        return cell
    }
    
    //MARK:- TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    
                    item.isDone = !item.isDone
                    self.tableView.reloadData()
                }
            } catch {
                print("Error while update: \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK:- Data Manipulation Methods
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var resultItem = UITextField()
        
        let aler = UIAlertController(title: "Add ToDo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let safeTitle = resultItem.text, let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let item = Item()
                        item.title = safeTitle
                        item.created = Date()
                        currentCategory.items.append(item)
                    }
                } catch {
                    print("Error while saving data \(error)")
                }
                
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
    
    private func loadData() {
        
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.items?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error while update: \(error)")
            }
        }
    }
    
    
    
}

//MARK:- SearchView Delegate

extension ToDoListViewController: UISearchBarDelegate  {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "created", ascending: true)
        
        tableView.reloadData()
        
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
