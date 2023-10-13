//
//  SchnapsenApp.swift
//  Schnapsen
//
//  Created by David Laczkovits on 10.10.23.
//

import SwiftUI

@main
struct SchnapsenApp: App {
    var body: some Scene {
        WindowGroup {
           MainView(viewController: Controller())
        }
    }
}
