//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    //    tapping into userDefaults using constant "defaults"
    //    let defaults = UserDefaults.standard
    
    //    This is for Saving Data using Filemanager onto a Plist
    //    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.Plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
        searchBar.delegate = self
        
        //        loadItems()
        //        let newItem = Item()
        //        newItem.title = "Find Mike"
        //        itemArray.append(newItem)
        //
        //        let newItem2 = Item()
        //        newItem2.title = "Buy Eggos"
        //        itemArray.append(newItem2)
        //
        //        let newItem3 = Item()
        //        newItem3.title = "Destory Demogorgon"
        //        itemArray.append(newItem3)
        
        //                    loading data using uderDefaults
        //        if let items = defaults.array(forKey: "TodolistArray") as? [Item] {
        //            itemArray = items
        //          }
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemArray[indexPath.row]
        
        if #available(iOS 14.0, *) {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            content.text = item.title
            
            cell.accessoryType = item.done == true ? .checkmark : .none
            
            cell.contentConfiguration = content
            
            return cell
        } else {
            // Fallback on earlier versions
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! ItemTableViewCell
            
            cell.accessoryType = item.done == true ? .checkmark : .none
            cell.itemLabel.text = item.title
            
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done.toggle()
        //        itemArray.remove(at: indexPath.row)
        //        context.delete(itemArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        saveItems()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textfield = UITextField()
        
        let alert = UIAlertController(title: "Add New Todey Item", message: "" , preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //            what will once the user clicks the Add item button on our alert
            
            let newItem = Item(context: self.context)
            newItem.title = textfield.text!
            newItem.done = false
            self.itemArray.append(newItem)
            self.saveItems()
            
            //            saving using uderDefaults
            //            self.defaults.set(self.itemArray, forKey: "TodolistArray")
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textfield = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    
    func saveItems() {
        //        init() Encoder for saving with userDefaults
        //        let encoder =  PropertyListEncoder()
        
        do{
            try context.save()
            //            Saving encoding data to be saved into Plist
            //            let data = try encoder.encode(itemArray)
            //            try data.write(to: dataFilePath!)
        } catch {
            print("Error saving context \(error)")
            //            print("Error encoding item array, \(error.localizedDescription)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        do {
            itemArray = try context.fetch(request)
            print(itemArray)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    //    func loadItems() {
    //        if let data = try? Data(contentsOf: dataFilePath!) {
    //            let decoder = PropertyListDecoder()
    //            do {
    //            itemArray = try decoder.decode([Item].self, from: data)
    //            } catch {
    //                print("Error decoding from Plist\(error.localizedDescription)")
    //            }
    //        }
    //    }
}
//MARK: - SearchBar Methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
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

