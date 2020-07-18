//
//  WriteNoteViewController.swift
//  MyNotes
//
//  Created by sidney on 5/7/20.
//  Copyright © 2020 sidney. All rights reserved.
//

import UIKit
import RealmSwift
import AppCenterAnalytics

class WriteNoteViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    var note: NotesModel?
    var folder: FoldersModel!
    
    //MARK: Initialize
    //MARK: Ults
    //MARK: HandleAction
    
    @objc func share() {
        
        let activityVC = UIActivityViewController(activityItems: [textView.text as Any], applicationActivities: nil)
        // 顯示出我們的 activityVC。
        self.present(activityVC, animated: true, completion: nil)
        
        MSAnalytics.trackEvent("share", withProperties: ["note": textView.text])
    }
    
    @objc func done() {
        
        if textView.text == "" ||
            textView.text == nil {
            return
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dateStr = formatter.string(from: date)
        
        let realm = try! Realm()
        
        if note == nil {
            let note = NotesModel()
            note.contents = textView.text
            note.date = dateStr
            note.fullDate = date
            try! realm.write {
                folder.notes.append(note)
            }
        } else {
            
            try! realm.write {
                note?.contents = textView.text
                note?.editDate = dateStr
                note?.fullEditDate = date
            }
        }
        
//        navigationController?.popViewController(animated: true)
        
        let shareBarBtnItem = UIBarButtonItem(image: UIImage(systemName:  "square.and.arrow.up"), style: .plain, target: self, action: #selector(share))
//              let doneBarBtnItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
              
        navigationItem.rightBarButtonItems = [shareBarBtnItem]
        
        if (note?.contents) != nil {
            MSAnalytics.trackEvent("Edit Note", withProperties: ["folder": folder.name, "note": textView.text])
        } else {
            MSAnalytics.trackEvent("Add Note", withProperties: ["folder": folder.name, "note": textView.text])
        }
        
    }
    
    //MARK: LifeCircle
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareBarBtnItem = UIBarButtonItem(image: UIImage(systemName:  "square.and.arrow.up"), style: .plain, target: self, action: #selector(share))
        navigationItem.rightBarButtonItems = [shareBarBtnItem]
        textView.text = note?.contents
        textView.delegate = self
 
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
//        navigationController?.navigationItem.largeTitleDisplayMode = .never
        textView.becomeFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let shareBarBtnItem = UIBarButtonItem(image: UIImage(systemName:  "square.and.arrow.up"), style: .plain, target: self, action: #selector(share))
        let doneBarBtnItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        
        navigationItem.rightBarButtonItems = [doneBarBtnItem, shareBarBtnItem]
    }
   //MARK: Delegate
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
