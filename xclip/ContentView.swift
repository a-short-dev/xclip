//
//  ContentView.swift
//  xclip
//
//  Created by Akinrinsola Abiodun on 08/02/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var clipboardMonitor: ClipboardMonitor// ✅ Observes changes

    var body: some View {
        VStack {
            Text("Clipboard History")
                .font(.headline)
                .padding()

            List(clipboardMonitor.clipboardHistory, id: \.self) { item in
                Text(item)
                    .padding()
                    .foregroundStyle(.red)
                
            }

            Button("Clear History") {
                clipboardMonitor.clipboardHistory.removeAll() // ✅ Clears history
            }
            .padding()
        }
        .frame(width: 200,height: 200)
        .padding()
       
    }
}


#Preview {
    ContentView(clipboardMonitor: ClipboardMonitor())
}
