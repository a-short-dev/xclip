//
//  ClipboarMonitor.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import Cocoa
import SwiftUI

class ClipboardMonitor: NSObject, ObservableObject {
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int

    @Published var clipboardHistory: [String] = []
    override init() {
        self.lastChangeCount = pasteboard.changeCount
        super.init()
    }

    func startMonitoring() {
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
    }

    @objc private func checkClipboard() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            if let copiedString = pasteboard.string(forType: .string) {
                DispatchQueue.main.async {
                    if !self.clipboardHistory.contains(copiedString) {
                        self.clipboardHistory.insert(copiedString, at: 0) // Add newest at top
                    }
                }
                //print("Copied: \(copiedString)")
            }
        }
    }
}
