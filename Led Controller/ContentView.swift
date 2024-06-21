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
                
                MainUI()
                
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
                        .foregroundStyle(LinearGradient(
                                colors: [.blue, .green, .brown, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                        ))
                }
            }
        }
    }
}

struct MainUI: View
{
    var body: some View 
    {
        VStack(alignment: .leading)
        {
            Text("Placeholder")
                .background(RoundedRectangle(cornerRadius: R)
                    .fill(Color.black)
                    .frame(width: screenWidth/2, height: 40))
        }
    }
}

#Preview {
    ContentView()
}
