//
//  NotesModel.swift
//  MyNotes
//
//  Created by sidney on 5/7/20.
//  Copyright © 2020 sidney. All rights reserved.
//

import UIKit
import RealmSwift

class NotesModel: Object {
    @objc dynamic var contents = ""
    @objc dynamic var date = ""
    @objc dynamic var editDate = ""
    @objc dynamic var fullDate: Date?
    @objc dynamic var fullEditDate: Date?
}
