//
//  ContentView.swift
//  LightGoesOn
//
//  Created by Beau Nouvelle on 9/2/2024.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {

    @State var bleService = BluetoothService.shared

    var body: some View {
        VStack {
            Circle()
                .fill(bleService.peripheralState.color)
                .frame(maxHeight: 100)

            Button {
                toggleLED()
            } label: {
                VStack {
                    Image(systemName: "sun.max")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                        .padding()
                    Text("Toggle LED")
                }
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }

    func toggleLED() {
        guard BluetoothService.shared.peripheralState == .connected else {
            print("Peripheral not connected, scanning again.")
            BluetoothService.shared.scanForPeripherals()
            return
        }

        let data = "toggle".data(using: .utf8)!
        guard let char = BluetoothService.shared.ledCharacteristic else {
            print("Could not find LED characteristic")
            return
        }
        BluetoothService.shared.ledPeripheral?.writeValue(data, for: char, type: .withResponse)
    }
}

#Preview {
    ContentView()
}
