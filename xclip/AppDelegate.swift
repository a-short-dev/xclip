//
//  AppDelegate.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import Cocoa
import SwiftUI
import KeyboardShortcuts
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var clipboardMonitor: ClipboardMonitor!
    var popover: NSPopover!
    
    private var shortcuts: [KeyboardShortcuts.Name: () -> Void] = [:]

    func applicationDidFinishLaunching(_ notification: Notification) {
        clipboardMonitor = ClipboardMonitor()
        setupMenuBar()
        clipboardMonitor.startMonitoring()
        setupKeyboardShortcuts()
        setupNotifications()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor.stopMonitoring()
        statusItem = nil
        popover = nil
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "📋"
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView(clipboardMonitor: clipboardMonitor)
        )
    }
    
    private func setupKeyboardShortcuts() {
        shortcuts = [
            .toggleClipboard: { [weak self] in
                self?.togglePopover(nil)
            },
            .copyLastItem: { [weak self] in
                self?.copyLastItem()
            },
            .clearHistory: { [weak self] in
                self?.clearClipboardHistory()
            }
        ]
        
        for (name, action) in shortcuts {
            KeyboardShortcuts.onKeyDown(for: name, action: action)
        }
    }
    
    private func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    private func copyLastItem() {
        guard let lastItem = clipboardMonitor.clipboardHistory.first else { return }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(lastItem, forType: .string)
        
        showModernNotification(title: "Copied", body: lastItem.truncated(to: 30))
    }
    
    private func clearClipboardHistory() {
        clipboardMonitor.clearHistory()
        showModernNotification(title: "Cleared", body: "Clipboard history cleared")
    }
    
    private func showModernNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Handle notifications while app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is active
        completionHandler([.banner, .sound])
    }

    @objc func togglePopover(_ sender: Any?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}

extension String {
    func truncated(to length: Int) -> String {
        return count <= length ? self : String(prefix(length)) + "..."
    }
}
