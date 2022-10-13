//
//  MigrationViewController.swift
//  FireBaseExample
//
//  Created by sae hun chung on 2022/10/13.
//

import UIKit
import RealmSwift

final class MigrationViewController: UIViewController {
    
    let localRealm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. fileURL
        print("Realm FileURL: \(localRealm.configuration.fileURL!)")
        
        // 2. SchemaVersion 구조를 확인하는 코드 (버전별)
        do {
            let version = try schemaVersionAtURL(localRealm.configuration.fileURL!)
            print("Schema Version: \(version)")
        } catch {
            print(error)
        }
        
        // 3. Test
        for i in 1...100 {
            let task = Todo(title: "산책가자 할일: \(i)", importance: Int.random(in: 1...5))

            try! localRealm.write({
                localRealm.add(task)
            })
        }
        
    }
    
}
