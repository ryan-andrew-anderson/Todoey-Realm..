//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: UITableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        searchBar.delegate = self
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = todoItems?[indexPath.row]
        
        if #available(iOS 14.0, *) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            content.text = item?.title
            cell.backgroundColor = UIColor.randomFlat()
            
            cell.accessoryType = item?.done == true ? .checkmark : .none
            
            cell.contentConfiguration = content
            
            return cell
        } else {
            // Fallback on earlier versions
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! ItemTableViewCell
            
            cell.accessoryType = item?.done == true ? .checkmark : .none
            cell.itemLabel.text = item?.title
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write({
                    item.done.toggle()
                })
            } catch {
                print("Error saving done status", error)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error saving deleting item", error)
            }
            
            tableView.reloadData()
        }
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todey Item", message: "" , preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            guard let title = textField.text else { return }
            self.save(title: title)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: .none)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    
    func save(title: String) {
        
        do{
            try realm.write({
                let newItem = Item()
                newItem.title = title
                newItem.dateCreated = Date()
                realm.add(newItem)
                selectedCategory?.items.append(newItem)
            })
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true) //"dateCreated"
        tableView.reloadData()
    }
    
}

//MARK: - SearchBar Methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

