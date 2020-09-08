//
//  HashflagApp.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/8/20.
//

import SwiftUI

@main
struct HashflagApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
