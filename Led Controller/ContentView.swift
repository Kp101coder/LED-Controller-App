//
//  ContentView.swift
//  Led Controller
//
//  Created by Krish Prabhu on 6/15/24.
//

import SwiftUI
let R:CGFloat = 30
let screenRect = UIScreen.main.bounds
let screenWidth = screenRect.size.width
let screenHeight = screenRect.size.height
struct ContentView: View
{
    var body: some View 
    {
        NavigationStack
        {
            ZStack
            {
                Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                VStack
                {
                    
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .principal) 
                {
                    Text("LED Controller")
                        .font(.largeTitle)
                        .accessibilityAddTraits(.isHeader)
                }
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Image("highlight").resizable().frame(width:50,height:50,alignment:.center)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
