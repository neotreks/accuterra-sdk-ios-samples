//
//  DisplayItem.swift
//  AccuterraSampleApp
//
//  Created by Brian Elliott on 4/17/20.
//  Copyright © 2020 NeoTreks, Inc. All rights reserved.
//

import SwiftUI

struct DisplayItem: View {
    
    var item: String

    var body: some View {
        if item == "Creating a Map" {
            return AnyView(CreateMap())
        } else {
            return AnyView(Text("View not found"))
        }
    }
}

struct DisplayItem_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
