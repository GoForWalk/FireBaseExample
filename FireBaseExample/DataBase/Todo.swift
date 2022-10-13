//
//  Todo.swift
//  FireBaseExample
//
//  Created by sae hun chung on 2022/10/13.
//

import Foundation
import RealmSwift

class Todo: Object {
    
    @Persisted var title: String
    @Persisted var favorite: Double
    @Persisted var userDescription: String
    @Persisted var count: Int
    
    @Persisted(primaryKey: true) var objectID: ObjectId

    convenience init(title: String, importance: Int) {
        self.init()
        self.title = title
        self.favorite = Double(importance)
    }
    
}
