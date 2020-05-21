//
//  BluetoothCentral.swift
//  BluetoothPeripheral
//
//  Created by Yuki Tachi on 2020/05/19.
//  Copyright © 2020 Yuki Tachi. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothCentral: NSObject {
    // シングルトンにしないと「[CoreBluetooth] XPC connection invalid」エラーが出る
    static var instance: BluetoothCentral = BluetoothCentral()
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic!
    private var charcteristicUUID = Setting.Bluetooth.Charcteristic.UUID;
    
    // 接続開始
    public func connect() {
        // セントラルマネージャを起動
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // 接続解除
    public func disconnect() {
        BluetoothCentral.instance = BluetoothCentral()
        print("接続を解除しました")
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothCentral : CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 起動直後にスキャンを開始するとスキャンに失敗する
        switch central.state {
            case CBManagerState.poweredOn:
                print("ペリフェラルのスキャンを開始します...")
                // このサービスUUIDを持つペリフェラルをスキャンする
                centralManager.scanForPeripherals(withServices: [Setting.Bluetooth.Service.UUID], options: nil)
            case .unknown:
                print("unknown")
            case .resetting:
                print("resetting")
            case .unsupported:
                print("unsupported")
            case .unauthorized:
                print("unauthorized")
            case .poweredOff:
                print("powered off")
                break
            default:
                break
        }
    }
    
    // ペリフェラルを検知した場合
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("検知したペリフェラル: \(peripheral)")
        
        self.peripheral = peripheral
        // ペリフェラルに接続
        centralManager.connect(peripheral, options: nil)
    }
    
    // ペリフェラルへの接続が成功した場合
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\(peripheral) に接続成功しました")
        centralManager.stopScan() // ストップしないと接続後もスキャンし続ける
        
        // サービスを検出する
        self.peripheral.delegate = self as? CBPeripheralDelegate
        self.peripheral.discoverServices([Setting.Bluetooth.Service.UUID])
    }
    
    // 値を書き込む
    func writeValue(_ value: String) {
//        if !isConnected { return }
        let data: Data = value.data(using: .utf8)!
        peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        print("「\(value)」を書き込みました")
    }
}
