//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ryan Anderson on 1/31/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    /// Add New Catrgories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category Name", style: .default) { action in
            
            guard let name = textField.text else { return }
            
            let newCategory = Category(context: self.context)
            newCategory.name = name
            self.categoryArray.append(newCategory)
            self.saveCategories()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: .none)
        
        alert.addTextField { alerttextField in
            alerttextField.placeholder = "Create new Category"
            textField = alerttextField
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - TableView DataSource Methods
    //  Displaying all the Categoryies in the presistance Container
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categoryArray[indexPath.row]
        
        
//        if #available(iOS 14.0, *) {
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
//            var content = cell.defaultContentConfiguration()
//
//            content.text = category.name
//            print(category.name)
//
//            return cell
//        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
            
            cell.categoryLabel.text = category.name
            
            return cell
//        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.description == "goToItems" {
            self.performSegue(withIdentifier: "goToItems", sender: self)
        }
    }
    
    //MARK: - TableView Delegate Methods
    // leave blank for now
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            saveCategories()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //MARK: - Data Manipulation Methods
    //    Save data and load data
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoryArray = try context.fetch(request)
            
            print(categoryArray)
        } catch {
            print("Error fetching data from context \(error)")
        }
        self.tableView.reloadData()
        
    }
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error fetching data from context \(error)")
        }
        self.tableView.reloadData()
        
    }
}
