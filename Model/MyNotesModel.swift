//
//  MyNotesModel.swift
//  MyNotes
//
//  Created by sidney on 5/7/20.
//  Copyright © 2020 sidney. All rights reserved.
//

import UIKit
import RealmSwift

class MyNotesModel: Object {
    
    var folders = List<FoldersModel>()
}
