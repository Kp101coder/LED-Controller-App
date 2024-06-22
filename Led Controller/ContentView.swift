//
//  ContentView.swift
//  Led Controller
//
//  Created by Krish Prabhu on 6/15/24.
//

import SwiftUI
//Standard Roundness of shapes
private let R:CGFloat = 15
//Standard Opacity of background shapes
private let O:CGFloat = 0.5
//Variables for recording screen bounds for some placement calculations. Not to be relied on.
let screenRect = UIScreen.main.bounds
let screenWidth = screenRect.size.width
let screenHeight = screenRect.size.height

struct ContentView: View
{
    //Animation variables
    @State private var animateHeading = false
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: R)
                Rectangle()
                    .fill(Color.white)
                    .opacity(0.25)
                VStack
                {
                    Spacer().frame(height: 80)
                    MainUI()
                    Spacer()
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .principal)
                {
                    LinearGradient(
                        colors: [.blue, .green, .brown, .pink],
                        startPoint: .leading,
                        endPoint: .trailing)
                        .offset(x:animateHeading ? screenWidth : 0)
                        .animation(.linear(duration: 5.0).repeatForever(autoreverses: true), value: animateHeading)
                        .mask(Text("LED Controller")
                            .font(.largeTitle)
                            .accessibilityAddTraits(.isHeader))
                        .onAppear(perform:
                        {
                            animateHeading.toggle()
                        }
                    )
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
            Text("Connection Status: " + status)
                .foregroundColor(Color.black)
                .padding()
                .background(RoundedRectangle(cornerRadius: R)
                    .fill(Color.gray)
                    .opacity(O))
        }
    }
}

#Preview {
    ContentView()
}
