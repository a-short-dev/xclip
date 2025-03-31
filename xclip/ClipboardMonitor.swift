//
//  ClipboardMonitor.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import Cocoa
import Combine

class ClipboardMonitor: NSObject, ObservableObject {
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var clipboardHistory: [String] = [] {
        didSet {
            // Limit history size to prevent memory issues
            if clipboardHistory.count > 100 {
                clipboardHistory = Array(clipboardHistory.prefix(100))
            }
        }
    }
    
    override init() {
        self.lastChangeCount = pasteboard.changeCount
        super.init()
        
        // Load any saved history
        loadHistory()
        
        // Save history when changes occur
        $clipboardHistory
            .dropFirst() // Skip initial empty array
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveHistory()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        guard timer == nil else { return }
        
        // Initial check
        checkClipboard()
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.5, // More responsive interval
            target: self,
            selector: #selector(checkClipboard),
            userInfo: nil,
            repeats: true
        )
        timer?.tolerance = 0.1 // Improve energy efficiency
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        
        lastChangeCount = pasteboard.changeCount
        
        // Check for multiple types of content
        if let copiedString = pasteboard.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            guard !copiedString.isEmpty else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Avoid duplicates and maintain order
                self.clipboardHistory.removeAll { $0 == copiedString }
                self.clipboardHistory.insert(copiedString, at: 0)
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        UserDefaults.standard.set(clipboardHistory, forKey: "clipboardHistory")
    }
    
    private func loadHistory() {
        if let history = UserDefaults.standard.stringArray(forKey: "clipboardHistory") {
            clipboardHistory = history
        }
    }
    
    // MARK: - Public Methods
    
    func clearHistory() {
        clipboardHistory = []
    }
    
    func copyToClipboard(_ string: String) {
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }
}
