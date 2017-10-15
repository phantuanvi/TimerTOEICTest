//
//  TimerTOEICTestVC.swift
//  TimerTOEICTest
//
//  Created by Tuan-Vi Phan on 4/1/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import AVFoundation

class TimerTOEICTestVC: UIViewController {

    // IBOutlet
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // Variable
    var timer = Timer()
    var timeCount: TimeInterval = 0.0 // counter for the timer
    var timeInterval: TimeInterval = 1
    
    var player: AVAudioPlayer = AVAudioPlayer()
    
    // Model
    var parts: [Part]!
    var tempParts: [Part]!
    
    @IBAction func startPressed(_ sender: UIButton) {
        
        tableView.allowsSelection = false
        stopButton.isEnabled = true
        
        timeCount = checkMinute(true) * 60
        
        if (timeCount > 0) {
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(TimerTOEICTestVC.countDown), userInfo: nil, repeats: true)
            startButton.isEnabled = false
        }
        if timeCount == 0 {
            
            let alert = UIAlertController(title: "Alert", message: "Please choose the part first", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: { () -> Void in
                self.willStart()
            })
        }
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        
        timer.invalidate()
        
        willStart()
        
        resetAllPart()
    }
    
    // count
    @objc func countDown() {
        
        timeCount = timeCount - timeInterval
        if timeCount <= 0 {
            
            timer.invalidate()
            
            let audioPath = Bundle.main.path(forResource: "beep", ofType: "mp3")!
            do {
                try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
                player.play()
            } catch {
                print("error audio")
            }
            
            let alert = UIAlertController(title: "Alert", message: "Timer has finished", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
            willStart()
            resetAllPart()
        }
        timerLabel.text = timeString(timeCount)
    }
    
    // converter timeCount to time
    func timeString(_ time: TimeInterval) -> String {
        
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        
        return String(format: "%02i:%02i", minutes, Int(seconds))
    }
    
    // stage ready for start
    func willStart() {
        tableView.allowsSelection = true
        startButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    // reset timeCount
    func resetAllPart() {
        tempParts = parts
        timeCount = 0.0
        timerLabel.text = "00:00"
        
        tableView.reloadData()
    }
    
    // sum all min checked
    func checkMinute(_ flag: Bool) -> Double {
        var sumMinute = 0.0
        if flag {
            for i in 0..<tempParts.count {
                if tempParts[i].checked {
                    sumMinute += tempParts[i].toeicMin
                }
            }
        }
        print("\(sumMinute)")
        return sumMinute
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parts = [Part]()
        
        let listening = Part(Part: "Listening", Min: 45)
        parts.append(listening)
        let part5 = Part(Part: "Part 5", Min: 20)
        parts.append(part5)
        let part6 = Part(Part: "Part 6", Min: 10)
        parts.append(part6)
        let part7 = Part(Part: "Part 7", Min: 45)
        parts.append(part7)
        
        tempParts = parts
        
        // tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        
        startButton.isEnabled = false
        stopButton.isEnabled = false
        
    }

    

}

extension TimerTOEICTestVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? TOEICTableViewCell {
            
            let part = parts[(indexPath as NSIndexPath).row]
            part.toggleChecked()
            
            configureCheckmarkForCell(cell, part: part)
        }
        startButton.isEnabled = true
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TimerTOEICTestVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempParts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TOEICTableViewCell
        
        let part = tempParts[(indexPath as NSIndexPath).row]
        if (indexPath as NSIndexPath).row < tempParts.count {
            
            cell.partLabel.text = part.toeicPart
            cell.minLabel.text = "\(Int(part.toeicMin)) min"
            
            cell.backgroundColor = MAINCOLOR
            cell.partLabel.textColor = TEXTCOLOR
            cell.minLabel.textColor = TEXTCOLOR
            cell.checkedLabel.textColor = TEXTCOLOR
            
            configureCheckmarkForCell(cell, part: part)
        }
        
        return cell
    }
    
    func configureCheckmarkForCell(_ cell: TOEICTableViewCell, part: Part) {
        
        if (part.checked != false) {
            cell.checkedLabel.text = "√"
        } else {
            cell.checkedLabel.text = ""
        }
    }
}
