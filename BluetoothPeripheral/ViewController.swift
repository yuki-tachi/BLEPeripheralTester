//
//  ViewController.swift
//  BluetoothPeripheral
//
//  Created by Yuki Tachi on 2020/05/18.
//  Copyright © 2020 Yuki Tachi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    private var count: Int = 0
    private var peripheralManager: CBPeripheralManager!
    private var service: CBMutableService!
    private var characteristic: CBMutableCharacteristic!

    @IBOutlet weak var discript: UILabel!
    
    @IBAction func start(_ sender: UIButton) {
        debugLog("start")
         self.startAdvertise()
    }
    
    @IBAction func stop(_ sender: UIButton) {
        debugLog("stop")
        self.stopAdvertise()
    }
    
    private func prepare() {
        // サービスを作成
        service = CBMutableService(type: Setting.Bluetooth.Service.UUID, primary: true) // primary -> 主となるサービスとするかどうか
        // キャラクタリスティックを作成
        characteristic = CBMutableCharacteristic(
            type: Setting.Bluetooth.Charcteristic.UUID,
            properties: [.notify, .read, .write],
            value: nil,
            permissions: [.readable, .writeable])
        // サービスにキャラクタリスティックを設定
        service.characteristics = [characteristic]
        // サービスをペリフェラルマネージャに追加
        peripheralManager.add(service)
        // アドバタイズ開始
        peripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "Display-peripheral",
            CBAdvertisementDataServiceUUIDsKey: [Setting.Bluetooth.Service.UUID]
        ])
    }
    
    private func writeTSValue() {
        debugLog("timestapmを書き込みました")
        // peripheralManager.updateValue(123, forCharacteristic: characteristic, onSubscribedCentrals: nil)
    }
    
    private func startAdvertise() {
        // ペリフェラルマネージャを起動
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    private func stopAdvertise() {
        debugLog("アドバタイズを停止しました")
        peripheralManager.stopAdvertising()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func debugLog(_ msg: String) {
        dump(msg)
        //if peripheralManager != nil {
        //    print("isAdvertising: \(peripheralManager.isAdvertising)")
        //}
        //表示可能最大行数を指定
        discript.numberOfLines = 0
        //contentsのサイズに合わせてobujectのサイズを変える
        discript.sizeToFit()
        discript.text = msg;
    }
}


// MARK: - CBPeripheralManagerDelegate
extension ViewController : CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
        // 起動直後にアドバタイズを開始すると失敗する
        switch peripheral.state {
        case .poweredOn:
            self.prepare()
        case .unknown:
            debugLog("unknown")
        case .resetting:
            debugLog("resetting")
        case .unsupported:
            debugLog("unsupported")
        case .unauthorized:
            debugLog("unauthorized")
        case .poweredOff:
            debugLog("powered off")
        default:
            break
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            debugLog("サービスの追加に失敗しました: \(error.debugDescription)")
            return
        }
        debugLog("サービスの追加に成功しました: \(service)")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            debugLog("アドバタイズに失敗しました: \(error.debugDescription)")
            return
        }
        debugLog("アドバタイズ開始: \(peripheral)")
    }

    // writeリクエストに応答
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        debugLog("writeリクエストに応答")
        for request in requests {
            if request.characteristic.uuid.isEqual(characteristic.uuid) {
                // リクエストの値を書き込む
                characteristic.value = request.value
                let value: String? = String(data: request.value!, encoding: .utf8)
                count += 1
                debugLog("「\(value!)」を書き込みました \(count)")
                peripheralManager.respond(to: request, withResult: .success)
            }
        }
    }
    
    // readリクエストに応答
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        debugLog("readRequestが来た")
        if request.characteristic.uuid.isEqual(characteristic.uuid) {
            let value: String? = String(data: characteristic.value!, encoding: .utf8)
            debugLog("read: \(value!)")
            peripheralManager.respond(to: request, withResult: .success)
        }
    }
}
