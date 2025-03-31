//
//  ContentView.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var clipboardMonitor: ClipboardMonitor
    @State private var searchText = ""
    
    private var filteredItems: [String] {
        if searchText.isEmpty {
            return clipboardMonitor.clipboardHistory
        } else {
            return clipboardMonitor.clipboardHistory.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Clipboard History")
                    .font(.headline)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: {
                    clipboardMonitor.clearHistory()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing)
                .help("Clear all history")
            }
            .padding(.vertical, 8)
            .background(Color(.windowBackgroundColor))
            
            // Search bar
            SearchBar(text: $searchText)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            
            // Content
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                List(filteredItems, id: \.self) { item in
                    ClipboardItemRow(text: item)
                        .onTapGesture {
                            clipboardMonitor.copyToClipboard(item)
                            NSApp.hide(nil) // Hide the app after selection
                        }
                        .contextMenu {
                            Button("Copy") {
                                clipboardMonitor.copyToClipboard(item)
                            }
                            Button("Delete") {
                                if let index = clipboardMonitor.clipboardHistory.firstIndex(of: item) {
                                    clipboardMonitor.clipboardHistory.remove(at: index)
                                }
                            }
                        }
                }
                .listStyle(PlainListStyle())
            }
            
            // Footer
            HStack {
                Text("\(filteredItems.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    NSApp.hide(nil)
                }) {
                    Text("Close")
                }
            }
            .padding(8)
        }
        .frame(width: 300, height: 400)
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .padding()
            
            Text(searchText.isEmpty ?
                 "Your clipboard history is empty" :
                 "No items matching \"\(searchText)\"")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Subviews

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(6)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ClipboardItemRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .lineLimit(2)
                .font(.system(size: 12))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "doc.on.doc")
                .foregroundColor(.blue)
                .opacity(0.7)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .contentShape(Rectangle()) // Makes entire row tappable
    }
}

// MARK: - Preview

#Preview {
    let monitor = ClipboardMonitor()
    monitor.clipboardHistory = [
        "First copied item",
        "Second copied item with longer text that might wrap to multiple lines",
        "Third item",
        "Fourth item",
        "Fifth item"
    ]
    return ContentView(clipboardMonitor: monitor)
}
