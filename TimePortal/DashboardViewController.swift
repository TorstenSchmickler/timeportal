//
//  ViewController.swift
//  TimePortal
//
//  Created by Torsten Schmickler on 15/04/2018.
//  Copyright © 2018 Torsten Schmickler. All rights reserved.
//

import UIKit
import AVFoundation

class DashboardViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var AddEntryButton: UIButton!
    @IBOutlet weak var WelcomeMessageLabel: UILabel!
    @IBOutlet weak var ComeBackTomorrowLabel: UILabel!
    
    // MARK: - VARIABLES
    var userName = "" { didSet { WelcomeMessageLabel.text = "Hello \(userName), how are you?" } }
    var userNameNotSet = false
    var popUpClear = false { didSet { self.askForPermissionsInSequence() }}
    var todaysDiaryEntered = false { didSet {
        if todaysDiaryEntered {
            print("Entry button was changed")
            AddEntryButton.isEnabled = false
            AddEntryButton.isHidden = true
            ComeBackTomorrowLabel.isHidden = false
        }
    }}
    let defaults = UserDefaults.standard
    let userDefaultService = UserDefaultsService.init()
    let formatter = DateFormatter()
    var permissionsGranted = true {
        didSet {
            print("penis was called")
            DispatchQueue.main.async {
                self.AddEntryButton.isHidden = true
                self.ComeBackTomorrowLabel.text = "Permissions missing"
                self.ComeBackTomorrowLabel.isHidden = false
            }
        }
    }
    lazy var initCommands = [{ self.initializeUserName() }, { self.askForVideoPermissions() }, { UserNotificationService.init().requestAuthorization() }]
        
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
        askForPermissionsInSequence()
    }
    
    func askForPermissionsInSequence() {
        DispatchQueue.main.async {
            self.initCommands.remove(at: 0)()
        }
    }
    
    func initializeView() {
        print("DashboardController, initializeView() started")
        if let storedUsername = defaults.string(forKey: "userName") {
            userName = storedUsername
        } else {
            userNameNotSet = true
        }
        if let lastEntry = defaults.string(forKey: "lastEntry") {
            let today = Date()
            formatter.dateFormat = "dd.MM.yyyy"
            let todayAsString  = formatter.string(from: today)
            if lastEntry == todayAsString {
                todaysDiaryEntered = true
            }
        }
        // Add days until portal will open
    }
    
    func askForVideoPermissions() {
        print("askForVideoPermissions")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("AVCaptureDevice Video permissions granted")
            popUpClear = true
            break
            
        case .notDetermined:
            print("AVCaptureDevice Video Permissions not yet given")
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                self.popUpClear = true
                if !granted {
                    self.permissionsGranted = false
                    self.showPermissionsMissingAlert()
                }
            })
            
        default:
            self.permissionsGranted = false
            popUpClear = true
            print("AVCaptureDevice Video permissions missing")
            showPermissionsMissingAlert()
        }
    }
    
    func showPermissionsMissingAlert() {
        DispatchQueue.main.async {
            let changePrivacySetting = "Timeportal doesn't have permission to use the camera, please change privacy settings"
            let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
            let alertController = UIAlertController(title: "Timeportal", message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                    style: .cancel,
                                                    handler: nil))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                    style: .`default`,
                                                    handler: { _ in
                                                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func initializeUserName() {
        if (userNameNotSet) {
            showInputDialog()
        } else {
            popUpClear = true
        }
    }
    
    func showInputDialog() {
        print("inputdialog called")
        let alertController = UIAlertController(title: "Your Profile", message: "Enter your name", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            self.userName = (alertController.textFields?[0].text)!.capitalizingFirstLetter()
            self.defaults.set(self.userName, forKey: "userName")
            self.popUpClear = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in self.popUpClear = true }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

