//
//  AppearanceSettings.swift
//  xclip
//

import SwiftUI

struct AppearanceSettings: View {
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                Picker("Appearance", selection: $settings.theme) {
                    ForEach(AppSettings.Theme.allCases, id: \.self) { theme in
                        Text(theme.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Customization")) {
                ColorPicker("Accent Color", selection: $settings.accentColor)
                
                Picker("Font Size", selection: $settings.fontSize) {
                    Text("Small").tag(12)
                    Text("Medium").tag(14)
                    Text("Large").tag(16)
                }
            }
            
            Section {
                Button("Reset Appearance") {
                    withAnimation {
                        settings.theme = .system
                        settings.accentColor = .blue
                        settings.fontSize = 14
                    }
                }
            }
        }
        .padding()
        .frame(width: 400)
    }
}

struct AppearanceSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettings()
            .environmentObject(AppSettings.shared)
    }
}
