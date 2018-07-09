//
//  ReplayViewController.swift
//  TimePortal
//
//  Created by Torsten Schmickler on 30/06/2018.
//  Copyright © 2018 Torsten Schmickler. All rights reserved.
//




import UIKit
import AVKit
import AVFoundation

class ReplayViewController: UIViewController {
    
    // TODO: Add Date as label overlay to the avplayer to see which Day of the month it was recorded
    // TODO: Upload application support folder to Icloud
    
  
    // MARK: Variables
    @IBOutlet var monthButtonCollection: [UIButton]!
    let monthStringToInt: [String:Int] = ["May": 5, "June": 6, "July": 7, "August": 8, "September": 9, "October": 10, "November": 11, "December": 12]
    let calendar = NSCalendar.current
    
    // MARK: Methods
    @IBAction func replaySelected(_ sender: UIButton) {
        let monthlyFilteredEntries = filterEntriesByMonth(monthStringToInt[sender.currentTitle!]!)
//        let sortedFilteredEntries = sortEntries(monthlyFilteredEntries)
        playEntries(monthlyFilteredEntries)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showOnlyFeasibleMonth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func showOnlyFeasibleMonth() {
        let currentMonth = calendar.component(.month, from: Date())
        print(currentMonth, "currenpenismonth")
        let defaults = UserDefaults.standard
        let penisArray: NSArray = [Date(), Date()]
        defaults.set(penisArray, forKey: "EntryArray")
        let storedPenisArray = defaults.array(forKey: "EntryArray") ?? []
        var monthWithEntries: [Int:String] = [:]
        for entryDate in storedPenisArray {
            let month = calendar.component(.month, from: entryDate as! Date)
            monthWithEntries[month-5] = "yepp"
        }
        monthWithEntries[0] = "penis"
//        monthWithEntries[1] = "penis"
        print(monthWithEntries)
        for index in 0..<8 {
            monthButtonCollection[index].isHidden = true
            print(index, monthButtonCollection[index].currentTitle, "unhidden")
            if (index < currentMonth - 5) && (monthWithEntries[index] != nil) {
//                print(index, monthButtonCollection[index].currentTitle, "unhidden")
                monthButtonCollection[index].isHidden = false
            }
        }
    }
    
    private func filterEntriesByMonth(_ month: Int) -> [AVPlayerItem] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var monthlyEntries: Array<AVPlayerItem> = []
        
        do {
            let entryUrls = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey])
            let sortedEntryUrls = entryUrls.map { url in
                (url, (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 < $1.1 }) // sort descending creation dates
                .map { $0.0 } // extract file names
            
            let filteredEntryUrls = try sortedEntryUrls.filter {
                let entryMonth = try calendar.component(.month, from: $0.resourceValues(forKeys: [.creationDateKey]).creationDate!)
                return entryMonth == month
            }

            for entryUrl in filteredEntryUrls {
                monthlyEntries.append(AVPlayerItem(asset: AVAsset(url: entryUrl)))
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        return monthlyEntries
        
    }
    
    private func playEntries(_ entries: [AVPlayerItem]) {
       
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        
        let player = AVQueuePlayer.init(items: entries)
        
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
}
