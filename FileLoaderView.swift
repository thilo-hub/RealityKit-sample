//
//  FileLoaderView.swift
//  RealityConverter
//
//  Created by Thilo Jeremias on 29.01.23.
//

import SwiftUI

struct FileLoaderView: View {
    let loaded: (URL) -> Void
    @EnvironmentObject var robj: rObject
    
    fileprivate func loadFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            if let url = panel.url {
                loaded(url)
            }
        }
    }
    var body: some View {
        VStack {
            HStack {
                Button(action:{
                    loadFile()
                },
                       label: {
                    Image(systemName:"tray.and.arrow.down.fill")
                    Text("Load File")
                })
                Spacer()
            }
            Spacer()
        }
    }
}

//struct FileLoaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        FileLoaderView(loaded: { url in  print(url) })
//    }
//}
//
