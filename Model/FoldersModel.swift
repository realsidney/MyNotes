//
//  FoldersModel.swift
//  MyNotes
//
//  Created by sidney on 5/7/20.
//  Copyright © 2020 sidney. All rights reserved.
//

import UIKit
import RealmSwift

class FoldersModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = ""
    @objc dynamic var fullDate: Date?
    var notes = List<NotesModel>()
}
