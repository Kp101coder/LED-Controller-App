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
                    .ignoresSafeArea(.all)
                Rectangle()
                    .fill(Color.white)
                    .opacity(0.15)
                    .ignoresSafeArea(.all)
                VStack
                {
                    Spacer().frame(height: 20)
                    Text("Connection Status: " + status)
                        .foregroundColor(Color.black)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: R)
                            .fill(Color.gray)
                            .opacity(O))
                    MainUI()
                    Button("Transmit")
                    {
                        //Transmit
                    }
                    .padding()
                    .foregroundColor(Color.blue)
                    .background(RoundedRectangle(cornerRadius: R)
                        .fill(Color.black)
                        .opacity(O)
                        .frame(width: 100))
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
                        .offset(x:animateHeading ? -screenWidth : screenWidth)
                        .mask(
                            Text("LED Controller")
                            .font(.largeTitle)
                            .accessibilityAddTraits(.isHeader))
                        .animation(.linear(duration: 5.0).repeatForever(autoreverses: true), value: animateHeading)
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
    //Image toggle button states
    @State var imageButton1:Bool = false
    @State var imageButton2:Bool = false
    @State var imageButton3:Bool = false
    //Text input states
    @State var button1Text:String = ""
    @State var button2Text:String = ""
    @State var button3Text:String = ""
    //Focused State for hiding edit text
    @FocusState var inFocus: Int?
    //RGB value array states
    @State var switch1Colors:[Int?] = [nil, nil, nil]
    @State var switch2Colors:[Int?] = [nil, nil, nil]
    @State var switch3Colors:[Int?] = [nil, nil, nil]
    //Rainbow States
    @State var rainbowButton1:Bool = false
    @State var rainbowButton2:Bool = false
    @State var rainbowButton3:Bool = false
    var body: some View
    {
        ScrollView
        {
            //First switch change options
            addSwitch(switchNumber: 1, buttonText: $button1Text, imageButton: $imageButton1, rainbowButton: $rainbowButton1, rgb: $switch1Colors).frame(minHeight: 500)
            //Second switch change options
            addSwitch(switchNumber: 2, buttonText: $button2Text, imageButton: $imageButton2, rainbowButton: $rainbowButton2, rgb: $switch2Colors).frame(minHeight: 500)
            //Third switch change options
            addSwitch(switchNumber: 3, buttonText: $button3Text, imageButton: $imageButton3, rainbowButton: $rainbowButton3, rgb: $switch3Colors).frame(minHeight: 500)
        }
    }
}

struct addSwitch: View
{
    var switchNumber: Int
    @Binding var buttonText: String
    @Binding var imageButton: Bool
    @Binding var rainbowButton: Bool
    @FocusState var inFocus: Int?
    @Binding var rgb: [Int?]
    var body: some View
    {
        VStack
        {
            RoundedRectangle(cornerRadius: R)
                .fill(Color.gray)
                .opacity(O)
                .padding([.top, .leading, .trailing], 20)
                .frame(height: 200)
                .overlay(
                    VStack
                    {
                        Label(
                            title: { Text("Switch " + String(switchNumber)) },
                            icon: { Image(systemName: "switch.2") }
                        ).padding(.top, 30)
                        HStack
                        {
                            if(!imageButton)
                            {
                                Toggle(isOn: $rainbowButton)
                                {
                                    Text("Rainbow Font")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                            Toggle(isOn: $imageButton)
                            {
                                Text("Use Image")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }.padding([.trailing], imageButton ? 130 : 50)
                        }
                        HStack
                        {
                            VStack
                            {
                                if (!rainbowButton && !imageButton)
                                {
                                    Label(
                                        title: { Text("RGB Values (0-255)") },
                                        icon: { Image(systemName: "paintpalette") }
                                    )
                                    HStack 
                                    {
                                        RoundedRectangle(cornerRadius: R)
                                            .stroke(Color.gray, lineWidth: 1.3)
                                            .fill(Color.black)
                                            .opacity(O)
                                            .overlay(
                                                TextField(
                                                    "Red Value",
                                                    value: $rgb[0],
                                                    format: .number
                                                )
                                                .foregroundColor(.red)
                                                .onChange(of: rgb[0] ?? 0)
                                                { oldValue, newValue in
                                                    if(newValue > 255 || newValue < 0)
                                                    {
                                                        rgb[0] = oldValue
                                                    }
                                                }
                                                .padding()
                                            )
                                        RoundedRectangle(cornerRadius: R)
                                            .stroke(Color.gray, lineWidth: 1.3)
                                            .fill(Color.black)
                                            .opacity(O)
                                            .overlay(
                                                TextField(
                                                    "Green Value",
                                                    value: $rgb[1],
                                                    format: .number
                                                )
                                                .foregroundColor(.green)
                                                .onChange(of: rgb[1] ?? 0)
                                                { oldValue, newValue in
                                                    if(newValue > 255 || newValue < 0)
                                                    {
                                                        rgb[1] = oldValue
                                                    }
                                                }
                                                    .padding(.leading, 10)
                                            )
                                        RoundedRectangle(cornerRadius: R)
                                            .stroke(Color.gray, lineWidth: 1.3)
                                            .fill(Color.black)
                                            .opacity(O)
                                            .overlay(
                                                TextField(
                                                    "Blue Value",
                                                    value: $rgb[2],
                                                    format: .number
                                                )
                                                .foregroundColor(.blue)
                                                .onChange(of: rgb[2] ?? 0)
                                                { oldValue, newValue in
                                                    if(newValue > 255 || newValue < 0)
                                                    {
                                                        rgb[2] = oldValue
                                                    }
                                                }
                                                .padding(.leading, 15)
                                            )
                                    }.padding([.leading, .trailing], 30).padding(.bottom, 15)
                                }
                            }
                        }
                    }
                )
                //Text input for the screen
                RoundedRectangle(cornerRadius: R)
                    .fill(Color.gray)
                    .opacity(O)
                    .overlay(
                        ZStack(alignment: .topLeading) 
                        {
                            TextEditor(text: $buttonText).id(1)
                                .focused($inFocus, equals: 1)
                                .font(.system(size: 22).bold())
                                .foregroundColor(rainbowButton ? (inFocus == 1 ? .white : .clear) : Color(red: rgb[0] == nil ? 255.0 : (Double(rgb[0]!)/255.0), green: rgb[1] == nil ? 255.0 : (Double(rgb[1]!)/255.0), blue: rgb[2] == nil ? 255.0 : (Double(rgb[2]!)/255.0)))
                                .scrollContentBackground(.hidden)
                                .background(RoundedRectangle(cornerRadius: R)
                                    .fill(Color.black))
                                .padding(15)
                                .onTapGesture
                                {
                                    dismissKeyboard()
                                }
                            if(rainbowButton)
                            {
                                Text(buttonText)
                                    .font(.system(size: 22).bold())
                                    .foregroundStyle(LinearGradient(
                                        colors: [.blue, .green, .brown, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing))
                                    .padding(20)
                                    .opacity(inFocus != 1 ? 1 : 0)
                            }
                        }
                    )
                    .padding([.leading, .trailing], 19)
                    .onTapGesture
                    {
                        dismissKeyboard()
                    }
        }
    }
    
    private func dismissKeyboard() 
    {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
