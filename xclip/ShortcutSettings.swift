//
//  ShortcutSettings.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 31/03/2025.
//



import SwiftUI
import KeyboardShortcuts

struct ShortcutsSettings: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        Form {
            Section(header: Text("Application Shortcuts")) {
                HStack {
                    Text("Show Clipboard:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleClipboard)
                }
                
                HStack {
                    Text("Copy Last Item:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .copyLastItem)
                }
                
                HStack {
                    Text("Clear History:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .clearHistory)
                }
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            // Setup default shortcuts if not already set
            if KeyboardShortcuts.getShortcut(for: .toggleClipboard) == nil {
                KeyboardShortcuts.setShortcut(.init(.v, modifiers: [.command, .shift]), for: .toggleClipboard)
            }
        }
    }
}

extension KeyboardShortcuts.Name {
    static let toggleClipboard = Self("toggleClipboard")
    static let copyLastItem = Self("copyLastItem")
    static let clearHistory = Self("clearHistory")
}

struct ShortcutsSettings_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutsSettings()
            .environmentObject(AppSettings.shared)
    }
}
