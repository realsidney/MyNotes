//
//  NotesViewController.swift
//  MyNotes
//
//  Created by sidney on 5/7/20.
//  Copyright © 2020 sidney. All rights reserved.
//

import UIKit
import RealmSwift

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var folder: FoldersModel!
    var notes: List<NotesModel>?
    //MARK: Initialize
    
    func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
    }
    
    //MARK: Ults
    //MARK: HandleAction
    
    @objc func addNotes() {
        print("add notes.....")
        
        let writeNotesVC = WriteNoteViewController()
        writeNotesVC.folder = folder
        navigationController?.pushViewController(writeNotesVC, animated: true)
        
    }
    
    //MARK: LifeCircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = folder.name
         
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addNotes))

        configTableView()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationItem.largeTitleDisplayMode = .never
        notes = folder.notes
        tableView.reloadData()
     }
    
    //MARK: Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell");
        
        if cell == nil{
           cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell");
        }
        cell?.accessoryType = .disclosureIndicator
        let note = notes![indexPath.row]
        cell?.textLabel?.text = note.contents
        cell?.detailTextLabel?.text = "\(note.date)"
        if note.editDate != "" {
            cell?.detailTextLabel?.text = "\(note.date)" + "  edited:\(note.editDate)"
        }
        cell?.imageView?.image = UIImage(systemName: "doc.plaintext")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let writeNotesVC = WriteNoteViewController()
        writeNotesVC.folder = folder
        writeNotesVC.note = notes![indexPath.row]
        navigationController?.pushViewController(writeNotesVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
     
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            let realm = try! Realm()
            try! realm.write {
                self.notes?.remove(at: indexPath.row)
            }
            
            tableView.reloadData()
            
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
