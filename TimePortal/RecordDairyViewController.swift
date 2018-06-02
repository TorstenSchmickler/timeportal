//
//  RecordDairyViewController.swift
//  TimePortal
//
//  Created by Torsten Schmickler on 15/05/2018.
//  Copyright © 2018 Torsten Schmickler. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class RecordDairyViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - OUTLETS
    @IBOutlet weak var countDownLabel: UILabel! 

    // MARK: - VARIABLE DECLARATIONS
    
    private var diaryEntryRecordingSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var recordingSessionObserver: NSObjectProtocol?
    private var movieFileOutput: AVCaptureMovieFileOutput?
    var countDown = 60 { didSet { countDownLabel.text = "\(countDown)" } }
    var countdownTimer: Timer!
    let defaults = UserDefaults.standard
    let formatter = DateFormatter()
    var fileName: String { get {
        let today = Date()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: today)
        }}

    
    // MARK: - METHODS
    
    override func viewWillDisappear(_ animated: Bool) {
        print("record view controller will disappear")
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        addObservers()
        
        initializeDiaryRecording()
        
        initializePreviewLayer()
        
        diaryEntryRecordingSession.startRunning()
    }
    
    func stopSessionRecording() {
        self.diaryEntryRecordingSession.stopRunning()
        print("Session stopped recording")
    }

    func initializeDiaryRecording() {
        
        guard let microphone = AVCaptureDevice.default(.builtInMicrophone, for: AVMediaType.audio, position: .unspecified) else {
            print("Failed to get the microphone device")
            return
        }
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: frontCamera)
            let audioInput = try AVCaptureDeviceInput(device: microphone)
            let output = AVCaptureMovieFileOutput()
            
            movieFileOutput = output
            
            diaryEntryRecordingSession.beginConfiguration()
            
            diaryEntryRecordingSession.addOutput(output)
            if let connection = output.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
            diaryEntryRecordingSession.sessionPreset = .cif352x288
            diaryEntryRecordingSession.addInput(cameraInput)
            diaryEntryRecordingSession.addInput(audioInput)
            diaryEntryRecordingSession.commitConfiguration()
            
        } catch {
            print(error)
            return
        }
    }

    func startCountdown() {
        countDownLabel.text = String(countDown)
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateCountdown)), userInfo: nil, repeats: true)
        print("Countdown started")
    }
    
    @objc func updateCountdown() {
        if countDown > 1 {
            countDown -= 1
        } else {
            print("Timer ended")
            countdownTimer.invalidate()
            countDownLabel.text = ""
            stopSessionRecording()
            videoPreviewLayer?.removeFromSuperlayer()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(outputFileURL)
        defaults.set(fileName, forKey: "lastEntry")
    }
    
    func addObservers() {
        recordingSessionObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.AVCaptureSessionDidStartRunning,
            object: diaryEntryRecordingSession,
            queue: OperationQueue.main,
            using: { notification in
                print(notification.name)
                // Start recording to a temporary file.
                let outputFileName = self.fileName
                let applicationSupportDirPath = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).path
                let outputFilePath = ( applicationSupportDirPath as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                self.movieFileOutput?.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                self.startCountdown()
        }
        )
        
        recordingSessionObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.AVCaptureSessionDidStopRunning,
            object: diaryEntryRecordingSession,
            queue: OperationQueue.main,
            using: { notification in
                print(notification.name)
                // TODO: Either show notification and and then segue back to main screen.
        }
        )
    }
    
    func initializePreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: diaryEntryRecordingSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        
        view.layer.insertSublayer(videoPreviewLayer!, below: countDownLabel.layer)
    }
}


