//
//  ViewController.swift
//  BeaconPop
//
//  Created by Abdul Qadar on 10/3/15.
//  Copyright (c) 2015 Argonteq. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import CoreBluetooth


class ViewController: UIViewController , CBPeripheralManagerDelegate{

    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var lblBTStatus: UILabel!
    
    @IBOutlet weak var txtMajor: UITextField!
    
    @IBOutlet weak var txtMinor: UITextField!
    
    
    let uuid = UUID(uuidString: "388A0B9C-600F-41D7-ACF1-5CA80A2B82FA")
    
    var beaconRegion: CLBeaconRegion!
    
    var bluetoothPeripheralManager: CBPeripheralManager!
    
    var isBroadcasting = false
    
    var dataDictionary = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnAction.layer.cornerRadius = btnAction.frame.size.width / 2
    
        
        self.hideKeyboardWhenTappedAround()

        
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchBroadcastingState(sender: AnyObject) {
        
        if txtMajor.text == "" || txtMinor.text == "" {
            return
        }

        if !isBroadcasting {
            if bluetoothPeripheralManager.state == .poweredOn {
                let major: CLBeaconMajorValue = UInt16(txtMajor.text!)!
                let minor: CLBeaconMinorValue = UInt16(txtMinor.text!)!
                beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "argonteq.BeaconPop")
                dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
                bluetoothPeripheralManager.startAdvertising(dataDictionary as! [String : Any])
                btnAction.setTitle("Stop", for: .normal)
                lblStatus.text = "Broadcasting..."
                
                txtMajor.isEnabled = false
                txtMinor.isEnabled = false
                
                isBroadcasting = true
            }
        }else {
            
            bluetoothPeripheralManager.stopAdvertising()
            
            btnAction.setTitle("Start", for: .normal)
            lblStatus.text = "Broadcast Stopped"
            
            txtMajor.isEnabled = true
            txtMinor.isEnabled = true
            
            isBroadcasting = false
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        var statusMessage = ""
        
        switch peripheral.state {
        case .poweredOn:
            statusMessage = "Bluetooth Status: Turned On"
        case .unknown:
            statusMessage = "Bluetooth Status: Unknow"
        case .resetting:
            statusMessage = "Bluetooth Status: Resetting"
        case .unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
        case .unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
        case .poweredOff:
            if isBroadcasting {
                switchBroadcastingState(sender: self)
            }
            statusMessage = "Bluetooth Status: Turned Off"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
        
        lblBTStatus.text = statusMessage
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

