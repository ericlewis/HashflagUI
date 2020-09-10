//
//  HashflagApp.swift
//  Hashflag Watch Extension
//
//  Created by Eric Lewis on 9/9/20.
//

import SwiftUI

@main
struct HashflagApp: App {
    private let api = API()
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
