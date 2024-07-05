//Made by Krish Prabhu and ChatGPT
//7/4/2024

import CoreBluetooth
import Combine
import UIKit

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var dataCharacteristic: CBCharacteristic?
    
    @Published var isConnected = false
    @Published var receivedData: String = ""

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name == "LEDController" {
            centralManager.stopScan()
            connectedPeripheral = peripheral
            connectedPeripheral?.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.properties.contains(.write) {
                    dataCharacteristic = characteristic
                    // Send iPhone's name when characteristic is discovered
                    let iphoneName = UIDevice.current.name
                    sendData(iphoneName.data(using: .utf8)!)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            receivedData = String(data: data, encoding: .utf8) ?? "Unknown data"
            print("Received data: \(receivedData)")
        }
    }

    func sendData(_ data: Data) {
        if let characteristic = dataCharacteristic, let peripheral = connectedPeripheral {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}
