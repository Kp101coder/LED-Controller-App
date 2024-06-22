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
private let O:CGFloat = 0.6
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
                    .opacity(0.15)
                VStack
                {
                    Spacer().frame(height: 20)
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
                        colors: [.blue, .green, .brown, .pink, .blue, .green, .brown, .pink, .blue, .green, .brown, .pink],
                        startPoint: .leading,
                        endPoint: .trailing)
                        .frame(width: screenWidth*3)
                        .offset(x:animateHeading ? 0 : -screenWidth)
                        .mask(
                            Text("LED Controller")
                            .font(.largeTitle)
                            .accessibilityAddTraits(.isHeader))
                        .animation(.linear(duration: 5.0).repeatForever(autoreverses: false), value: animateHeading)
                    .onAppear(perform:
                    {
                        animateHeading.toggle()
                    })
                }
            }
        }
    }
}

struct MainUI: View
{
    var body: some View 
    {
        Text("Connection Status: " + status)
            .foregroundColor(Color.black)
            .padding()
            .background(RoundedRectangle(cornerRadius: R)
                .fill(Color.gray)
                .opacity(O))
    }
}

#Preview {
    ContentView()
}
