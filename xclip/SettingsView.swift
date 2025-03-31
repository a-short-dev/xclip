//
//  SettingsView.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 31/03/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var selectedTab: SettingsTab = .general
    
    enum SettingsTab: Hashable {
        case general
        case appearance
        case shortcuts
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTab.general)
            
            AppearanceSettings()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
                .tag(SettingsTab.appearance)
            
            ShortcutsSettings()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
                .tag(SettingsTab.shortcuts)
        }
        .frame(width: 450, height: 300)
        .padding(20)
        .onAppear {
            // Restore last selected tab if needed
            if let savedTab = UserDefaults.standard.string(forKey: "selectedSettingsTab"),
               let tab = SettingsTab(rawValue: savedTab) {
                selectedTab = tab
            }
        }
        .onChange(of: selectedTab) {
            // Save selected tab
            UserDefaults.standard.set(selectedTab.rawValue, forKey: "selectedSettingsTab")
        }
    }
}

// Extend SettingsTab for raw value representation
extension SettingsView.SettingsTab: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "general": self = .general
        case "appearance": self = .appearance
        case "shortcuts": self = .shortcuts
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .general: return "general"
        case .appearance: return "appearance"
        case .shortcuts: return "shortcuts"
        }
    }
}

// Preview
#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
