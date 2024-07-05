//Made by Krish Prabhu
import CoreBluetooth
import Combine
import UIKit

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var dataCharacteristic: CBCharacteristic?
    
    @Published var isConnected = false
    @Published var receivedData: String = ""
    
    // Define UUIDs
    let serviceUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0")
    let characteristicUUID = CBUUID(string: "87654321-1234-5678-1234-56789abcdef0")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralManager.stopScan()
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                dataCharacteristic = characteristic
                if characteristic.properties.contains(.write) {
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
        if let characteristic = dataCharacteristic, let peripheral = connectedPeruthiral {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}
