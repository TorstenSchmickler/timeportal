//
//  RecordDairyViewController.swift
//  TimePortal
//
//  Created by Torsten Schmickler on 15/05/2018.
//  Copyright © 2018 Torsten Schmickler. All rights reserved.
//

import UIKit
import AVFoundation

class RecordDairyViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(outputFileURL)
    }
    
    
    private var diaryRecordingSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var recordingSessionObserver: NSObjectProtocol?
    private var movieFileOutput: AVCaptureMovieFileOutput?

    override func viewDidLoad() {

        super.viewDidLoad()
        
        
        recordingSessionObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.AVCaptureSessionDidStartRunning,
            object: diaryRecordingSession,
            queue: OperationQueue.main,
            using: { notification in
                print(notification.name)
                // Start recording to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                self.movieFileOutput?.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                // TODO: Start running the countdown
            }
        )
        
        recordingSessionObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.AVCaptureSessionDidStopRunning,
            object: diaryRecordingSession,
            queue: OperationQueue.main,
            using: { notification in
                print(notification.name)
                // TODO: Either show notification and and then segue back to main screen.
            }
        )
        
        // Initialize the diary recording session
        initializeDiaryRecording()
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: diaryRecordingSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        diaryRecordingSession.startRunning()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.diaryRecordingSession.stopRunning()
            print("Session stopped recording")
        }
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
            
            diaryRecordingSession.beginConfiguration()
            
            diaryRecordingSession.addOutput(output)
            if let connection = output.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
            
            diaryRecordingSession.sessionPreset = .vga640x480
            diaryRecordingSession.addInput(cameraInput)
            diaryRecordingSession.addInput(audioInput)
            diaryRecordingSession.commitConfiguration()
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
}


