//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ryan Anderson on 1/31/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
    var categoryArray: Results<Category>?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navBar = navigationController?.navigationBar {
            tableView.backgroundColor = UIColor.link
            navBar.backgroundColor = UIColor.link
            navBar.tintColor = ContrastColorOf(navBar.backgroundColor ?? .black , returnFlat: true)
        }
    }
    
    /// Add New Catrgories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category Name", style: .default) { action in
            
            guard let name = textField.text else { return }
            
            let newCategory = Category()
            newCategory.name = name
            newCategory.color = UIColor.randomFlat().hexValue()
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
        
        guard
            let category = categoryArray?[indexPath.row]
                , let categoryColor = UIColor(hexString: category.color)
        else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        cell.categoryLabel.text = category.name
        cell.categoryLabel.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        cell.backgroundColor = categoryColor
        cell.selectionStyle = .none
        
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete, let category = categoryArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            }catch {
                print("Trouble Deleting Category", error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow,
           let categories = categoryArray?[indexPath.row] {
            
            vc.selectedCategory = categories
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        self.tableView.reloadData()
    }
    
    func save(category: Category) {
        
        do {
            
            try realm.write({
                realm.add(category)
            })
        } catch {
            
            print("Error saving data from context \(error)")
        }
        
        self.tableView.reloadData()
    }
}
