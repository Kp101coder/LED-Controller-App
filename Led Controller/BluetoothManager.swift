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
        print("Central Manager initialized")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on. Starting scan...")
            startScan()
        } else {
            print("Bluetooth is not available.")
        }
    }

    func startScan() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Scanning for peripherals...")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral.name ?? "Unknown") with UUID: \(peripheral.identifier)")
        
        // Check if the discovered peripheral is the Raspberry Pi by its UUID
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
            let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as! [CBUUID]
            if serviceUUIDs.contains(CBUUID(string: "7a6307c9-5be7-4747-a8b6-51a6cb9b285c")) {
                centralManager.stopScan()
                connectedPeripheral = peripheral
                connectedPeripheral?.delegate = self
                centralManager.connect(peripheral, options: nil)
                print("Connecting to \(peripheral.identifier)...")
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.identifier)")
        isConnected = true
        peripheral.discoverServices([CBUUID(string: "7a6307c9-5be7-4747-a8b6-51a6cb9b285c")])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.identifier)")
        isConnected = false
        startScan()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("Discovered service: \(service.uuid)")
                peripheral.discoverCharacteristics([CBUUID(string: "ddbf3449-9275-42e5-9f4f-6058fabca551")], for: service)
            }
        } else if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Discovered characteristic: \(characteristic.uuid)")
                if characteristic.properties.contains(.write) {
                    dataCharacteristic = characteristic
                    print("Characteristic is writable")
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Characteristic notifications enabled")
                }
            }
        } else if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            receivedData = String(data: data, encoding: .utf8) ?? "Unknown data"
            print("Received data: \(receivedData)")
        } else if let error = error {
            print("Error updating value for characteristic: \(error.localizedDescription)")
        }
    }

    func sendData(_ data: Data) {
        if let characteristic = dataCharacteristic, let peripheral = connectedPeripheral {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
            print("Sent data: \(String(data: data, encoding: .utf8) ?? "Unknown data")")
        } else {
            print("Failed to send data: No connected peripheral or characteristic")
        }
    }
}
