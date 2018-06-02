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
    var development = false
    
    var userName = "" { didSet { WelcomeMessageLabel.text = "Hello \(userName), how are you?" } }
    var todaysDiaryEntered = false { didSet {
        if todaysDiaryEntered && !development{
            print("Entry button was changed")
            AddEntryButton.isEnabled = false
            AddEntryButton.isHidden = true
            ComeBackTomorrowLabel.isHidden = false
        }
    }}
    let defaults = UserDefaults.standard
    let formatter = DateFormatter()
    
    
    
    // MARK: - METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeView()
        self.askForRecordingPermissions()
    }
    
    func initializeView() {
//        userName = userConfiguration.userName
//        if let userNameFromUserDefaults = defaults.string(forKey: "userName") {
//            userName = userNameFromUserDefaults
//        }
        print("DashboardController, initializeView() started")
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
    
    func askForRecordingPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("AVCaptureDevice permissions granted")
            break
            
        case .notDetermined:
            print("AVCaptureDevice Permissions not yet given")
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.showPermissionsMissingAlert()
                }
                AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
                    if !granted {
                        self.showPermissionsMissingAlert()
                    }
                })
            })
            
        default:
            print("AVCaptureDevice permissions missing")
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
}
