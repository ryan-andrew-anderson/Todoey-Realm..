//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ryan Anderson on 1/31/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let realm = try! Realm()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        loadCategories()
        
    }
    
    /// Add New Catrgories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category Name", style: .default) { action in
            
            guard let name = textField.text else { return }
            
            let newCategory = Category()
            newCategory.name = name
            self.save(category: newCategory)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let category = categoryArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        cell.categoryLabel.text = category.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray.count
    }
    
    //MARK: - TableView Delegate Methods
    // leave blank for now
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //            context.delete(categoryArray[indexPath.row])
            //            do{
            //                try! realm.write({
            //                    realm.delete()
            //                })
            //            }
            //            categoryArray.remove(at: indexPath.row)
            //            save()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            vc.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    //    Save data and load data
    
    //    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
    //
    //        do {
    //            categoryArray = try context.fetch(request)
    //
    //            print(categoryArray)
    //        } catch {
    //            print("Error fetching data from context \(error)")
    //        }
    //        self.tableView.reloadData()
    //
    //    }
    
    func save(category: Category) {
        
        do {
            
            try realm.write({
                realm.add(category)
                categoryArray.append(category)
            })
        } catch {
            
            print("Error saving data from context \(error)")
        }
        
        self.tableView.reloadData()
    }
}
