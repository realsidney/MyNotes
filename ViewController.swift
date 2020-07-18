//
//  ViewController.swift
//  MyNotes
//
//  Created by sidney on 5/7/20.
//  Copyright © 2020 sidney. All rights reserved.
//

import UIKit
import RealmSwift
import AppCenterAnalytics

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var folders: List<FoldersModel>?
    
    //MARK: Initialize
    
    func configTableView() {
        tableView.dataSource = self;
        tableView.delegate = self;
        
        tableView.tableFooterView = UIView()
        
        let realm = try! Realm()
        var myNotes = realm.objects(MyNotesModel.self).first
        
        if myNotes == nil {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let dateStr = formatter.string(from: date)
            
            myNotes = MyNotesModel()
            try! realm.write {
                realm.add(myNotes!)
                folders = myNotes?.folders
                let folder = FoldersModel()
                folder.name = "碎片"
                folder.date = dateStr
                folder.fullDate = date
                myNotes?.folders.append(folder)
            }
        } else {
             folders = myNotes?.folders
        }
   
        tableView.reloadData()
    }
    
    //MARK: Ults
    
    func renameFolderWithIndex(index: Int) {
        
        let realm = try! Realm()
        let folder = self.folders![index]
        
        let alertController = UIAlertController(title: "Rename", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = folder.name
        }
        let saveAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if (firstTextField.text?.lengthOfBytes(using: .utf8))! > 0 {
                try! realm.write {
                    folder.name = firstTextField.text!
                }
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: HandleAction
    
    @IBAction func addFolders(_ sender: Any) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dateStr = formatter.string(from: date)
        
        let ac = UIAlertController(title: "Folder Name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Done", style: .default) { [unowned ac] _ in
            let folderNameTextField = ac.textFields![0]
            
            if folderNameTextField.text == "" || folderNameTextField.text == nil {
                return
            }
            
            let folder = FoldersModel()
            folder.name = folderNameTextField.text!;
            folder.date = dateStr
            
            let realm = try! Realm()
            try! realm.write {
                self.folders?.append(folder)
            }
            self.tableView.reloadData()
            
            MSAnalytics.trackEvent("Add Folder", withProperties: ["folder" : folderNameTextField.text!])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action : UIAlertAction!) -> Void in })
        ac.addAction(cancelAction)
        ac.addAction(submitAction)
        present(ac, animated: true)
        
    }
    
    //MARK: LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationItem.largeTitleDisplayMode = .always

    }
    
    //MARK: Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders?.count ?? 0;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell");
        
        if cell == nil{
           cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell");
        }
        cell?.accessoryType = .disclosureIndicator
        let folder = folders![indexPath.row]
        
        cell?.textLabel?.text = folder.name
        cell?.detailTextLabel?.text = folder.date
        cell?.detailTextLabel?.textColor = .systemGray
        cell?.imageView?.image = UIImage(systemName: "folder")
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
     
        let notesVC = NotesViewController()
        notesVC.folder = folders![indexPath.row]
        navigationController?.pushViewController(notesVC, animated: true)
    }
    
   
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.row == 0 {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            let realm = try! Realm()
            try! realm.write {
                self.folders?.remove(at: indexPath.row)
            }
            
            tableView.reloadData()
            
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: "\(indexPath.row)" as NSCopying, previewProvider: nil) { suggestedActions in

            let newNote = UIAction(title: "New Note", image: UIImage(systemName: "square.and.pencil")) { action in
               
               let writeNoteVC = WriteNoteViewController()
                writeNoteVC.folder = self.folders![indexPath.row]
                self.navigationController?.pushViewController(writeNoteVC, animated: true)
            }
            
            let rename = UIAction(title: "Rename", image: UIImage(systemName: "pencil.and.outline")) { action in
                self.renameFolderWithIndex(index: indexPath.row)
            }
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                            let realm = try! Realm()
                try! realm.write {
                    self.folders?.remove(at: indexPath.row)
                }
                
                tableView.reloadData()
            }

            // Create a UIMenu with all the actions as children
            return UIMenu(title: "", children: [newNote, rename, delete])
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
       
        guard let indexStr = configuration.identifier as? String else { return }
        let index = Int(indexStr)
        
        animator.addCompletion {
            let noteVC = NotesViewController()
            noteVC.folder = self.folders![index!]
            self.show(noteVC, sender: self)
        }
    }
}

