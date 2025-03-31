//
//  GeneralSettings.swift
//  xclip
//

import SwiftUI

struct GeneralSettings: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        Form {
            Section(header: Text("Behavior")) {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Toggle("Ignore whitespace items", isOn: $settings.ignoreWhitespace)
                Toggle("Play copy sound", isOn: $settings.playSound)
            }
            
            Section(header: Text("History")) {
                Stepper("Max items: \(settings.maxHistoryItems)",
                       value: $settings.maxHistoryItems, in: 10...500, step: 10)
            }
            
            Section {
                Button("Reset All Settings") {
                    resetSettings()
                }
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    private func resetSettings() {
        let defaults = UserDefaults.standard
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        
        // Refresh settings
        let newSettings = AppSettings()
        settings.launchAtLogin = newSettings.launchAtLogin
        settings.maxHistoryItems = newSettings.maxHistoryItems
        // Copy all other properties similarly...
    }
}

struct GeneralSettings_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettings()
            .environmentObject(AppSettings.shared)
    }
}
