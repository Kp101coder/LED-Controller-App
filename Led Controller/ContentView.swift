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
//Standard Padding of objects within the switch editing containers
private let P:CGFloat = 30
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
    //button states
    @State var button1On = false
    @State var button2On = false
    @State var button3On = false
    var body: some View
    {
        Text("Connection Status: " + status)
            .foregroundColor(Color.black)
            .padding()
            .background(RoundedRectangle(cornerRadius: R)
                .fill(Color.gray)
                .opacity(O))
        HStack
        {
            RoundedRectangle(cornerRadius: R)
                    .fill(Color.gray)
                    .opacity(O)
                    .padding()
                    .overlay(VStack{
                        Label(
                            title: { Text("Switch 1") },
                            icon: { Image(systemName: "switch.2") }
                        ).padding(P)
                        
                        Toggle(
                                "Use Image",
                                systemImage: "photo",
                                isOn: $button1On
                        ).padding(P)
                    })
            ZStack {
                HStack {
                    Text(text)
                        .font(.system(size: 22).bold())
                        .foregroundStyle(LinearGradient(
                            colors: [.blue, .green, .brown, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .padding(.leading, 10)
                    Spacer()
                }
                
                TextField("Add your text here...", text: $text)
                    .font(.system(size: 22).bold())
                    .foregroundColor(.clear)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1.3)
                    )
            }
        }
    }
}

#Preview {
    ContentView()
}
