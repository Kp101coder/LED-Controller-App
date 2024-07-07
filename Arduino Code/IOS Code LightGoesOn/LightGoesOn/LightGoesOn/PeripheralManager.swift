//
//  PeripheralManager.swift
//  LightGoesOn
//
//  Created by Beau Nouvelle on 10/2/2024.
//

import Foundation
import os
import CoreBluetooth
import SwiftUI

@Observable
class PeripheralManager: NSObject, CBPeripheralDelegate {

    static let shared = PeripheralManager()
    private override init() { super.init() }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            BluetoothService.shared.ledCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            os_log("error writing to peripheral")
        } else {
            os_log("LED Toggled!")
        }
    }

}

enum PeripheralState {
    case scanning, disconnected, connected, error, connecting

    var color: Color {
        switch self {
        case .scanning:
                .blue
        case .disconnected:
                .gray
        case .connected:
                .green
        case .error:
                .red
        case .connecting:
                .yellow
        }
    }
}

