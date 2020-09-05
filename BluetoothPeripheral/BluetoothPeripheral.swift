//
//  BluetoothPeripheral.swift
//  BluetoothPeripheral
//
//  Created by Yuki Tachi on 2020/05/18.
//  Copyright © 2020 Yuki Tachi. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothPeripheral: NSObject {
    private var peripheralManager: CBPeripheralManager!
    private var service: CBMutableService!
    private var characteristic: CBMutableCharacteristic!
    public static let instance: BluetoothPeripheral = BluetoothPeripheral()

    private func prepare() {
        print("ペリフェラルマネージャを起動しました")
        // サービスを作成
        service = CBMutableService(type: Setting.Bluetooth.Service.UUID, primary: true) // primary -> 主となるサービスとするかどうか
        // キャラクタリスティックを作成
        characteristic = CBMutableCharacteristic(
            type: Setting.Bluetooth.Charcteristic.UUID,
            properties: [.read, .write],
            value: nil,
            permissions: [.readable, .writeable])
        // サービスにキャラクタリスティックを設定
        service.characteristics = [characteristic]
        // サービスをペリフェラルマネージャに追加
        peripheralManager.add(service)
        // アドバタイズ開始
        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "Display",
            CBAdvertisementDataServiceUUIDsKey: [Setting.Bluetooth.Service.UUID]
        ])
    }
    
    override init() {
        peripheralManager = CBPeripheralManager()
    }
    
    public func startAdvertise() {
        // ペリフェラルマネージャを起動
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    public func stopAdvertise() {
        print("アドバタイズを停止しました")
        peripheralManager.stopAdvertising()
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothPeripheral : CBPeripheralManagerDelegate{
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // 起動直後にアドバタイズを開始すると失敗する
        switch peripheral.state {
        case .poweredOn:
            print("アドバタイズを開始します...")
            prepare()
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
        default:
            break
        }
    }
    
    // 書き込みリクエストに応答して、値を書き込む
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("didReceiveWrite")
        for request in requests {
            if request.characteristic.uuid.isEqual(characteristic.uuid) {
                // リクエストの値を書き込む
                characteristic.value = request.value
                // let value: String? = String(data: request.value!, encoding: .utf8)
                print("書き込みました")
            }
        }
        // リクエストに応答
        // peripheralManager.respond(to: requests[0], withResult: .success)
    }

    private func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            print("サービスの追加に失敗しました: \(error.debugDescription)")
        }
    }
    
    private func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("アドバタイズに失敗しました: \(error.debugDescription)")
        }
    }
}
