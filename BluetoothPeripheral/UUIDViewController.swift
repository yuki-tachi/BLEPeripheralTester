//
//  UUIDViewController.swift
//  BluetoothPeripheral
//
//  Created by Yuki Tachi on 2020/09/01.
//  Copyright © 2020 Yuki Tachi. All rights reserved.
//

import UIKit

class UUIDViewController: UIViewController, UITextFieldDelegate {
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true, completion:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setServiceUUID() {
        let serviveId = "xxxx";
        UserDefaults.standard.set(serviveId, forKey: "ServiceUuid")
    }
    
    private func setCharcteristicUUID() {
        let charcteristicId = "xxxx";
        UserDefaults.standard.set(charcteristicId, forKey: "CharcteristicUuid")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
