//
//  ViewController.swift
//  BluetoothPeripheral
//
//  Created by Yuki Tachi on 2020/05/18.
//  Copyright © 2020 Yuki Tachi. All rights reserved.
//
import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate {
    private var count: Int = 0
    private var peripheralManager: CBPeripheralManager!
    private var connectPeripheral: CBPeripheral!
    private var service: CBMutableService!
    private var characteristic: CBMutableCharacteristic!
    private var isConnecting: Bool = false
    
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func start(_ sender: UIButton) {
        debugLog("start")
         self.startAdvertise()
    }
    
    @IBAction func stop(_ sender: UIButton) {
        debugLog("stop")
        self.stopAdvertise()
    }
    
    @IBAction func push(_ sender: UIButton) {
        if (!self.isConnecting) {
            debugLog("アドバタイズ開始していません")
            return
        }
        
        count += 1
        let str = String(count)
        let updateValue = str.data(using: String.Encoding.utf8)
        debugLog("push: \(count)")
        characteristic.value = updateValue;
        peripheralManager.updateValue(updateValue!, for: characteristic, onSubscribedCentrals: nil)
    }

    @IBOutlet weak var serviceUUID: UILabel!
    @IBAction func SetDefaultServiceUuid(_ sender: Any) {
        // uuidを戻す
        serviceUUIDField.text = Setting.Bluetooth.Service.RawUuid
        serviceUUID.text = Setting.Bluetooth.Service.RawUuid
    }
    
    @IBOutlet weak var serviceUUIDField: UITextField!
    
    @IBOutlet weak var charcteristicUUID: UILabel!

    @IBAction func SetDefaultCharcteristicUuid(_ sender: Any) {
        charcteristicUUIDField.text = Setting.Bluetooth.Charcteristic.RawUuid
        charcteristicUUID.text = Setting.Bluetooth.Charcteristic.RawUuid
    }

    @IBOutlet weak var charcteristicUUIDField: UITextField!
    
    private func prepare() {
        let serviceUuid = self.getServiceUUID()
        debugLog("serviceUuid: \(serviceUuid)")
        // サービスを作成
        service = CBMutableService(type: CBUUID(string: serviceUuid), primary: true) // primary -> 主となるサービスとするかどうか
        // キャラクタリスティックを作成
        characteristic = CBMutableCharacteristic(
            type: CBUUID(string: self.getCharcteristicUUID()),
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
            CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: serviceUuid)]
        ])
    }

    private func getServiceUUID() -> String {
        if UserDefaults.standard.string(forKey: "ServiceUuid") == nil {
            UserDefaults.standard.set(Setting.Bluetooth.Service.RawUuid, forKey: "ServiceUuid")
        }
        return UserDefaults.standard.string(forKey: "ServiceUuid")!
    }
    
    private func setServiceUUID() {
        UserDefaults.standard.set(serviceUUID.text, forKey: "ServiceUuid")
    }
    
    
    private func getCharcteristicUUID() -> String {
        if UserDefaults.standard.string(forKey: "CharcteristicUuid") == nil {
            UserDefaults.standard.set(Setting.Bluetooth.Charcteristic.RawUuid, forKey: "CharcteristicUuid")
        }
        return UserDefaults.standard.string(forKey: "CharcteristicUuid")!
    }
    
    private func setCharcteristicUUID() {
        UserDefaults.standard.set(charcteristicUUID.text, forKey: "CharcteristicUuid")
    }

    private func startAdvertise() {
        debugLog("アドバタイズ開始")
        self.setServiceUUID()
        self.setCharcteristicUUID()
        // ペリフェラルマネージャを起動
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    private func stopAdvertise() {
        debugLog("アドバタイズを停止しました")
        peripheralManager.stopAdvertising()
        self.isConnecting = false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let serviceUuid = self.getServiceUUID()
        serviceUUID.text = serviceUuid
        serviceUUIDField.text = serviceUuid
        
        let charcteristicUuid = self.getCharcteristicUUID()
        charcteristicUUID.text = charcteristicUuid
        charcteristicUUIDField.text = charcteristicUuid
        
        serviceUUIDField.delegate = self
        charcteristicUUIDField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        serviceUUID.text = serviceUUIDField.text
        charcteristicUUID.text = charcteristicUUIDField.text

        return true
    }
    
    private func debugLog(_ msg: String) {
        dump(msg)

        if peripheralManager != nil {
            print("isAdvertising: \(peripheralManager.isAdvertising)")
        }
        //contentsのサイズに合わせてobujectのサイズを変える
        textView.text += msg + "\n";
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
        self.isConnecting = true;
    }

    // writeリクエストに応答
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if request.characteristic.uuid.isEqual(characteristic.uuid) {
                // リクエストの値を書き込む
                characteristic.value = request.value
                let value: String? = String(data: request.value!, encoding: .utf8)
                debugLog("write: \(value!)")
                peripheralManager.respond(to: request, withResult: .success)
            }
        }
    }

    // readリクエストに応答
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid.isEqual(characteristic.uuid) {
            let value: String? = String(data: characteristic.value!, encoding: .utf8)
            debugLog("read: \(value!)")
            peripheralManager.respond(to: request, withResult: .success)
        }
    }
}
