//
//  CoreLocation_ReduxApp.swift
//  Shared
//
//  Created by Nicolas Philippe on 9/14/20.
//

import SwiftUI
import SwiftRex
import CombineRex
import CombineRextensions

@main
struct CoreLocation_ReduxApp: App {
    
    @StateObject var store = World
        .origin
        .store()
        .asObservableViewModel(initialState: .empty)
    
    var body: some Scene {
        WindowGroup {
            ViewProducer.content(store: store).view()
        }
    }
}
