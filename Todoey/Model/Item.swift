//
//  Item.swift
//  Todoey
//
//  Created by mac on 22.01.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var created: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
