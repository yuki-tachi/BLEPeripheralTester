//
//  BluetoothSetting.swift
//  BluetoothPeripheral
//
//  Created by Yuki Tachi on 2020/05/18.
//  Copyright © 2020 Yuki Tachi. All rights reserved.
//
import CoreBluetooth

struct Setting {
    struct Bluetooth {
        struct Service {
            static var UUID: CBUUID = CBUUID(string: "8FECA99F-C116-45AB-A453-0A6B5A8EA12E")
        }
        
        struct Charcteristic {
            static var UUID: CBUUID = CBUUID(string: "97C36F66-9DDD-4D85-AF67-BBD21E7C5271")
        }
    }
}
