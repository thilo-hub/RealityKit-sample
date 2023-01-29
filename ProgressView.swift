//
//  ProgressView.swift
//  RealityConverter
//
//  Created by Thilo Jeremias on 30.01.23.
//

import SwiftUI

struct ConverterProgressView: View {
    @ObservedObject var converter: Converter

        var body: some View {
            if let f = converter.progressValue {
                    ProgressView(value: f)
            }
          
    }
}

