//
//  DetailPlaceholder.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/10/20.
//

import SwiftUI

struct DetailPlaceholder: View {
    var body: some View {
        Image(systemName: "flag.circle")
            .font(.system(size: 80))
            .imageScale(.large)
            .navigationTitle("Select a Hashflag")
            .font(.headline)
            .foregroundColor(.secondary)
    }
}
