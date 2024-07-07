//
//  BluetoothService.swift
//  LightGoesOn
//
//  Created by Beau Nouvelle on 10/2/2024.
//

import Foundation
import os
import CoreBluetooth

@Observable
class BluetoothService: NSObject {
    static let shared = BluetoothService()
    private var centralManager: CBCentralManager!

    var peripheralState: PeripheralState = .disconnected

    var ledPeripheral: CBPeripheral?
    var ledCharacteristic: CBCharacteristic?

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        os_log("CBManager initialized")
    }

}

extension BluetoothService: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            os_log("CBManager is powered on")
            scanForPeripherals()
        } else {
            os_log("CBManager is powered OFF")
        }
    }

    func scanForPeripherals() {
        os_log("scanning for peripherals")
        peripheralState = .scanning
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "d804b643-6ce7-4e81-9f8a-ce0f699085eb")])
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        os_log("Discovered %s at %d", String(describing: peripheral.name), RSSI.intValue)

        if ledPeripheral == nil {
            ledPeripheral = peripheral
            peripheralState = .connecting
            central.connect(peripheral)
            central.stopScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralState = .connected
        peripheral.delegate = PeripheralManager.shared
        peripheral.discoverServices([CBUUID(string: "d804b643-6ce7-4e81-9f8a-ce0f699085eb")])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error {
            print(error)
        }
        peripheralState = .error
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected peripheral")
        peripheralState = .disconnected
    }

}
