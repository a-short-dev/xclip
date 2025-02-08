//
//  xclipApp.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import SwiftUI

@main
struct xclipApp: App {
    @StateObject private var clipboardMonitor = ClipboardMonitor() // ✅ Create a shared instance

//    init() {
//        clipboardMonitor.startMonitoring() // ✅ Start monitoring immediately
//    }

    var body: some Scene {
        WindowGroup {
            ContentView(clipboardMonitor: clipboardMonitor) 
        }
    }
}
