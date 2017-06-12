//
//  ViewController.swift
//  LightsOn
//
//  Created by Ameya Vichare on 03/06/17.
//  Copyright © 2017 vit. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager : CBCentralManager?
    var discoveredPeripheral : CBPeripheral?
    var targetService: CBService?
    var writableCharacteristic: CBCharacteristic?
    
    var SERVICE_UUID = "FFF0"
    var CHARACTERISTIC_UUID = "FFF3"
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func onButton(_ sender: UIButton) {
        
        self.writeValue(value: 1)
    }
    
    @IBAction func offButton(_ sender: UIButton) {
        
        self.writeValue(value: 0)
    }
    
    func writeValue(value: Int8) {
        
        let data = Data.dataWithValue(value: value)
        discoveredPeripheral?.writeValue(data, for: writableCharacteristic!, type: .withResponse)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //3
        
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //2
        
        discoveredPeripheral = peripheral
        discoveredPeripheral?.delegate = self
        centralManager?.connect(discoveredPeripheral!, options: nil)
        centralManager?.stopScan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        //1
        
        if central.state == .poweredOn {
            
            centralManager?.scanForPeripherals(withServices: [CBUUID(string: SERVICE_UUID)], options: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        //4
        
        targetService = peripheral.services?.first
        peripheral.discoverCharacteristics(nil, for: targetService!)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //5

        for characteristic in service.characteristics! {
            
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                
                writableCharacteristic = characteristic
                
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //6
        
        if (characteristic.value?.int8Value())! > 0 {
            
            view.backgroundColor = UIColor.yellow
        }
        else {
            
            view.backgroundColor = UIColor.black
        }
        
    }
}


extension Data {
    static func dataWithValue(value: Int8) -> Data {
        var variableValue = value
        return Data(buffer: UnsafeBufferPointer(start: &variableValue, count: 1))
    }
    
    func int8Value() -> Int8 {
        return Int8(bitPattern: self[0])
    }
}
