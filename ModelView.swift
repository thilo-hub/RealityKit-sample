//
//  ModelView.swift
//  RealityConverter
//
//  Created by Thilo Jeremias on 30.01.23.
//

import SwiftUI


struct ModelView: View {
    @EnvironmentObject var robj: rObject
    
    var body: some View {
        VStack{
            HStack {
                Button("Hide Model"){ robj.model = nil}
                    .disabled(robj.model == nil)
                if let url = robj.model {
                    SaveModelView(fromURL: url)
                }
                Spacer()

            }
            ZStack {
                if let md = robj.model  {
                    ConverterModelView(bbox: $robj.boundingBox,modelurl: md)
                }
                HStack{
                    Spacer()
                    VStack{
                        Spacer()
                        Text(robj.messages)
                    }
                    .frame(width: 300)
                }
            }
    }
    }
}

//struct ModelView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModelView()
//    }
//}
