//
//  ClipboardWindoController.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import Cocoa


class ClipboardWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    static let shared = ClipboardWindowController()

    private var tableView: NSTableView!
    private var clipboardHistory: [(String, Date)] = []

    init() {
        let window = NSWindow(contentRect: NSMakeRect(0, 0, 400, 300),
                              styleMask: [.titled, .closable, .resizable],
                              backing: .buffered, defer: false)
        super.init(window: window)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let scrollView = NSScrollView(frame: window!.contentView!.bounds)
        scrollView.hasVerticalScroller = true

        tableView = NSTableView(frame: scrollView.bounds)
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("TextColumn"))
        column.title = "Copied Text"
        column.width = 380
        tableView.addTableColumn(column)

        tableView.dataSource = self
        tableView.delegate = self

        scrollView.documentView = tableView
        window?.contentView?.addSubview(scrollView)
    }

    func updateHistory(_ history: [(String, Date)]) {
        clipboardHistory = history
        tableView.reloadData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return clipboardHistory.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier("TextCell")
        let text = clipboardHistory[row].0

        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTextField {
            cell.stringValue = text
            return cell
        } else {
            let textField = NSTextField(labelWithString: text)
            textField.identifier = cellIdentifier
            return textField
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            let copiedText = clipboardHistory[selectedRow].0
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(copiedText, forType: .string)
        }
    }
}

