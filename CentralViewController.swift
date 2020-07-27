//
//  CentralViewController.swift
//  BluetoothPeripheral
//
//  Created by Yuki Tachi on 2020/05/19.
//  Copyright © 2020 Yuki Tachi. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralViewController: UIViewController {
    @IBOutlet weak var discript: UILabel!
    @IBOutlet weak var setPerripheral: UILabel!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func connect(_ sender: UIButton) {
        // セントラルマネージャを起動
        debugLog("セントラルマネージャを起動")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        debugLog("接続解除")
        centralManager = nil
    }
    
    @IBAction func writeValue(_ sender: UIButton) {
        writeValue("write")
    }
    
    @IBAction func readValueAction(_ sender: Any) {
        readValue()
    }
    
    private var isConnected: Bool = false
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic!
    /// 接続先の機器
    private var connectPeripheral: CBPeripheral? = nil
    /// 対象のキャラクタリスティック
    private var writeCharacteristic: CBCharacteristic? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    private func debugLog(_ msg: String) {
        //表示可能最大行数を指定
        discript.numberOfLines = 0
        //contentsのサイズに合わせてobujectのサイズを変える
        discript.sizeToFit()
        dump(msg)
        discript.text = msg;
    }
}

// MARK: - CBCentralManagerDelegate
extension CentralViewController : CBCentralManagerDelegate, CBPeripheralDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
       
        // 起動直後にスキャンを開始するとスキャンに失敗する
        switch central.state {
            case CBManagerState.poweredOn:
                debugLog("ペリフェラルのスキャンを開始します...")
                // このサービスUUIDを持つペリフェラルをスキャンする
                centralManager.scanForPeripherals(withServices: [Setting.Bluetooth.Service.UUID], options: nil)
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
                break
            default:
                break
        }
    }
    
    // ペリフェラルを検知した場合　centralManager.scanForPeripherals
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        debugLog("検知したペリフェラル: \(peripheral)")
        self.peripheral = peripheral
        // ペリフェラルに接続
        centralManager.connect(self.peripheral, options: nil)
    }
    
    // ペリフェラルへの接続が成功した場合
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan() // ストップしないと接続後もスキャンし続ける
        
        // サービスを検出する
        self.peripheral.delegate = self
        self.peripheral.discoverServices([Setting.Bluetooth.Service.UUID])
        
//        self.setPerripheral.sizeToFit()
        self.setPerripheral.text = "\(String(describing: peripheral.name))";
        debugLog("接続: \(String(describing: peripheral.name))")
        // debugLog("\(peripheral) に接続成功しました")
    }
    
    // ペリフェラルへの接続に失敗した場合
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        debugLog("\(peripheral) に接続失敗しました: \(error.debugDescription)")
    }
    
    // サービスを見つけた場合
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            debugLog("サービスの検出でエラーが発生しました: \(error.debugDescription)")
            return
        }
        // キャラクタリスティックを検出する
        debugLog("サービスを検出しました")
        // 今回の仕様では、相手がひとつしかサービスを持たないため「.first」としている
        // self.peripheral.discoverCharacteristics([Setting.Bluetooth.Charcteristic.UUID], for: (peripheral.services?.first)!)
        for service in peripheral.services! {
            print("Characteristicsのuuid: \(service.uuid)")
            self.peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // キャラクタリスティックを見つけた場合
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            debugLog("キャラクタリスティックの検出でエラーが発生しました: \(error.debugDescription)")
            return
        }
        debugLog("キャラクタリスティックを検出しました \(String(describing: service.characteristics?.first))")
        // 今回の仕様では、相手がひとつしかキャラクタリスティックを持たないため「.first」としている
        characteristic = service.characteristics?.first
        // 通知
        // peripheral.setNotifyValue(true, for: characteristic!)

        isConnected = true; // キャラクタリスティックを見つけられればデータの送受信ができる
    }

    func peripheral(
         _ peripheral: CBPeripheral,
         didUpdateValueFor characteristic: CBCharacteristic,
         error: Error?
     ) {
        debugLog("didUpdateValueFor peri")
     }
    /// データ更新時に呼ばれる
//    func peripheral(
//        _ peripheral: CBPeripheral,
//        didUpdateValueFor characteristic: CBCharacteristic,
//        error: Error?
//    ) {
//
//        if error != nil {
//            debugLog("error.debugDescription")
//            debugLog(error.debugDescription)
//            return
//        }
//
//        debugLog("\(String(describing: characteristic.value))")
//    }
    
    // 値を読み込む(通知)
//    private func peripheral(
//        peripheral: CBPeripheral!,
//        didUpdateValueFor characteristic: CBCharacteristic!,
//        error: Error!
//    ) {
//        if error != nil {
//            debugLog("読み込みに失敗しました=\(error.debugDescription)")
//            return
//        }
//
//        debugLog("valueを読み込みました")
//        let data = characteristic.value;
//        debugLog("value=\(data!)")
//    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let value: String? = String(data: request.value!, encoding: .utf8)
        debugLog("「\(value!)」を書き込みました")
    }

    // 値を書き込む
    func writeValue(_ value: String) {
        if !isConnected {
            debugLog("isnotconnected")
            return
        }

        let data: Data = value.data(using: .utf8)!
        self.peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        debugLog("「\(value)」を書き込みました")
    }
    
    private func peripheral(peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: Error?)
    {
        if let error = error {
            debugLog("Failed... error: \(error)")
            return
        }

        debugLog("Succeeded! value: \(String(describing: characteristic.value))")
    }
    
    // 値を読み込む
    func readValue() {
        debugLog("readを開始する")
        self.peripheral.readValue(for: characteristic)
    }
}
