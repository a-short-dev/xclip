//
//  AppSettings.swift
//  xclip
//
//  Created by Your Name on 31/03/2025.
//

import SwiftUI
import Combine

class AppSettings: ObservableObject {
    // Singleton instance
    static let shared = AppSettings()
    
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // General Settings
    @Published var launchAtLogin: Bool {
        didSet { save(key: "launchAtLogin", value: launchAtLogin) }
    }
    
    @Published var maxHistoryItems: Int {
        didSet { save(key: "maxHistoryItems", value: maxHistoryItems) }
    }
    
    @Published var ignoreWhitespace: Bool {
        didSet { save(key: "ignoreWhitespace", value: ignoreWhitespace) }
    }
    
    @Published var playSound: Bool {
        didSet { save(key: "playSound", value: playSound) }
    }
    
    // Appearance Settings
    @Published var theme: Theme {
        didSet { save(key: "theme", value: theme.rawValue) }
    }
    
    @Published var fontSize: Int {
        didSet { save(key: "fontSize", value: fontSize) }
    }
    
    @Published var accentColor: Color {
        didSet {
            if let colorData = try? NSKeyedArchiver.archivedData(
                withRootObject: NSColor(accentColor),
                requiringSecureCoding: false
            ) {
                defaults.set(colorData, forKey: "accentColor")
            }
        }
    }
    
    // Shortcuts
    @Published var showShortcut: String {
        didSet { save(key: "showShortcut", value: showShortcut) }
    }
    
    @Published var copyShortcut: String {
        didSet { save(key: "copyShortcut", value: copyShortcut) }
    }
    
    @Published var clearShortcut: String {
        didSet { save(key: "clearShortcut", value: clearShortcut) }
    }
    
    // Theme enum
    enum Theme: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
    }
    
    init() {
        // Register default values
        defaults.register(defaults: [
            "launchAtLogin": false,
            "maxHistoryItems": 100,
            "ignoreWhitespace": true,
            "playSound": true,
            "theme": Theme.system.rawValue,
            "fontSize": 14,
            "showShortcut": "⌘⇧V",
            "copyShortcut": "⌘⇧C",
            "clearShortcut": "⌘⇧X"
        ])
        
        // Load saved values
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        maxHistoryItems = defaults.integer(forKey: "maxHistoryItems")
        ignoreWhitespace = defaults.bool(forKey: "ignoreWhitespace")
        playSound = defaults.bool(forKey: "playSound")
        
        theme = Theme(rawValue: defaults.string(forKey: "theme") ?? Theme.system.rawValue) ?? .system
        fontSize = defaults.integer(forKey: "fontSize")
        
        showShortcut = defaults.string(forKey: "showShortcut") ?? "⌘⇧V"
        copyShortcut = defaults.string(forKey: "copyShortcut") ?? "⌘⇧C"
        clearShortcut = defaults.string(forKey: "clearShortcut") ?? "⌘⇧X"
        
        // Load accent color
        if let colorData = defaults.data(forKey: "accentColor"),
           let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: colorData) {
            accentColor = Color(nsColor)
        } else {
            accentColor = .blue
        }
        
        // Auto-save on changes
        setupAutoSave()
    }
    
    private func setupAutoSave() {
        // Automatically save when any property changes
        objectWillChange
            .debounce(for: 1.0, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveAll()
            }
            .store(in: &cancellables)
    }
    
    private func saveAll() {
        // Save all properties (useful for first run or reset)
        save(key: "launchAtLogin", value: launchAtLogin)
        save(key: "maxHistoryItems", value: maxHistoryItems)
        save(key: "ignoreWhitespace", value: ignoreWhitespace)
        save(key: "playSound", value: playSound)
        save(key: "theme", value: theme.rawValue)
        save(key: "fontSize", value: fontSize)
        save(key: "showShortcut", value: showShortcut)
        save(key: "copyShortcut", value: copyShortcut)
        save(key: "clearShortcut", value: clearShortcut)
        
        if let colorData = try? NSKeyedArchiver.archivedData(
            withRootObject: NSColor(accentColor),
            requiringSecureCoding: false
        ) {
            defaults.set(colorData, forKey: "accentColor")
        }
    }
    
    private func save(key: String, value: Any) {
        defaults.set(value, forKey: key)
    }
}
