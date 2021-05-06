//
//  StoryListenerApp.swift
//  StoryListener
//
//  Created by Mohammad Yasir on 07/05/21.
//

import SwiftUI

@main
struct StoryListenerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
