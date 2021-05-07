//
//  Persistence.swift
//  StoryListener
//
//  Created by Mohammad Yasir on 07/05/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container : NSPersistentContainer
    
    init(){
        container = NSPersistentContainer(name: "StoryListener")
        container.loadPersistentStores { (_ , error) in
            if let error = error as NSError? {
                fatalError("Error \(error.userInfo)")
            }
        }
    }
}
