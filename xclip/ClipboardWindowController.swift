//
//  ClipboardWindowController.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import Cocoa

class ClipboardWindowController: NSWindowController {
    static let shared = ClipboardWindowController()
    
    private var tableView: NSTableView!
    private var scrollView: NSScrollView!
    private var searchField: NSSearchField!
    private var clipboardHistory: [(String, Date)] = [] {
        didSet {
            filteredHistory = clipboardHistory
        }
    }
    private var filteredHistory: [(String, Date)] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Clipboard History"
        window.center()
        super.init(window: window)
        
        setupUI()
        setupToolbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Create container view
        let containerView = NSView(frame: window!.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        
        // Setup search field
        searchField = NSSearchField(frame: NSRect(x: 10, y: containerView.bounds.height - 40, width: containerView.bounds.width - 20, height: 30))
        searchField.placeholderString = "Search clipboard history..."
        searchField.autoresizingMask = [.width, .minYMargin]
        searchField.action = #selector(searchFieldChanged(_:))
        searchField.target = self
        containerView.addSubview(searchField)
        
        // Setup scroll view and table view
        scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height - 50))
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        
        tableView = NSTableView(frame: scrollView.bounds)
        tableView.autoresizingMask = [.width, .height]
        
        // Text column
        let textColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("TextColumn"))
        textColumn.title = "Text"
        textColumn.width = 300
        tableView.addTableColumn(textColumn)
        
        // Date column
        let dateColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("DateColumn"))
        dateColumn.title = "Copied At"
        dateColumn.width = 150
        tableView.addTableColumn(dateColumn)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        tableView.target = self
        
        scrollView.documentView = tableView
        containerView.addSubview(scrollView)
        window?.contentView = containerView
    }
    
    private func setupToolbar() {
        let toolbar = NSToolbar(identifier: "ClipboardToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        window?.toolbar = toolbar
    }
    
    func updateHistory(_ history: [(String, Date)]) {
        clipboardHistory = history.sorted { $0.1 > $1.1 } // Sort by most recent first
    }
    
    @objc private func searchFieldChanged(_ sender: NSSearchField) {
        let searchText = sender.stringValue.lowercased()
        if searchText.isEmpty {
            filteredHistory = clipboardHistory
        } else {
            filteredHistory = clipboardHistory.filter { $0.0.lowercased().contains(searchText) }
        }
    }
    
    @objc private func tableViewDoubleClick(_ sender: Any) {
        copySelectedItem()
    }
    
    @objc private func copySelectedItem() {
        guard tableView.selectedRow >= 0 else { return }
        let selectedItem = filteredHistory[tableView.selectedRow]
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(selectedItem.0, forType: .string)
    }
    
    @objc private func clearHistory() {
        clipboardHistory = []
    }
}

extension ClipboardWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredHistory.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = filteredHistory[row]
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier("TextColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier("TextCell")
            if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTextField {
                cell.stringValue = item.0
                return cell
            } else {
                let textField = NSTextField(labelWithString: item.0)
                textField.identifier = cellIdentifier
                textField.lineBreakMode = .byTruncatingTail
                return textField
            }
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier("DateColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier("DateCell")
            if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTextField {
                cell.stringValue = dateFormatter.string(from: item.1)
                return cell
            } else {
                let textField = NSTextField(labelWithString: dateFormatter.string(from: item.1))
                textField.identifier = cellIdentifier
                return textField
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20.0
    }
}

extension ClipboardWindowController: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.copy, .flexibleSpace, .clear]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.copy, .clear, .flexibleSpace]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        switch itemIdentifier {
        case .copy:
            toolbarItem.label = "Copy"
            toolbarItem.paletteLabel = "Copy Selected"
            toolbarItem.toolTip = "Copy selected item to clipboard"
            toolbarItem.image = NSImage(named: NSImage.Name("NSMultipleDocuments")) ?? NSImage(named: NSImage.Name("NSActionTemplate"))
            toolbarItem.action = #selector(copySelectedItem)
        case .clear:
            toolbarItem.label = "Clear"
            toolbarItem.paletteLabel = "Clear History"
            toolbarItem.toolTip = "Clear all clipboard history"
            toolbarItem.image = NSImage(named: NSImage.Name("NSTrash")) ?? NSImage(named: NSImage.Name("NSStopProgressTemplate"))
            toolbarItem.action = #selector(clearHistory)
        default:
            return nil
        }
        
        toolbarItem.target = self
        return toolbarItem
    }
}

extension NSToolbarItem.Identifier {
    static let copy = NSToolbarItem.Identifier("CopyItem")
    static let clear = NSToolbarItem.Identifier("ClearItem")
}
