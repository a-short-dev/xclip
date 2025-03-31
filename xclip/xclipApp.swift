//
//  xclipApp.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import SwiftUI

@main
struct xclipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var clipboardMonitor = ClipboardMonitor()
    @StateObject private var settings = AppSettings.shared
    
    init() {
        // Configure NSWindow behavior
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    var body: some Scene {
        Settings {
                   SettingsView()
                       .environmentObject(settings)
               }
        
        // Main window (hidden by default)
        Window("Clipboard History", id: "main") {
            ContentView(clipboardMonitor: clipboardMonitor)
                .frame(minWidth: 300, idealWidth: 350, maxWidth: 500,
                       minHeight: 400, idealHeight: 500, maxHeight: 800)
                .onAppear {
                    // Start monitoring when the window appears
                    clipboardMonitor.startMonitoring()
                }
                .onDisappear {
                    // Optional: Stop monitoring when window closes
                    clipboardMonitor.stopMonitoring()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {} // Remove "New Window" option
            CommandGroup(after: .windowArrangement) {
                Button("Show Clipboard History") {
                    NSApp.windows.first?.makeKeyAndOrderFront(nil)
                }
                .keyboardShortcut("v", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .help) {
                Button("xclip Help") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/yourusername/xclip")!)
                }
            }
        }
    }
}
