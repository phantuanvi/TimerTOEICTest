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
    var timer = NSTimer()
    var timeCount: NSTimeInterval = 0.0 // counter for the timer
    var timeInterval: NSTimeInterval = 1
    
    var player: AVAudioPlayer = AVAudioPlayer()
    
    // Model
    var parts: [Part]!
    var tempParts: [Part]!
    
    @IBAction func startPressed(sender: UIButton) {
        
        tableView.allowsSelection = false
        stopButton.enabled = true
        
        timeCount = checkMinute(true) * 60
        
        if (timeCount > 0) {
            timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(TimerTOEICTestVC.countDown), userInfo: nil, repeats: true)
            startButton.enabled = false
        }
        if timeCount == 0 {
            
            let alert = UIAlertController(title: "Alert", message: "Please choose the part first", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: { () -> Void in
                self.willStart()
            })
        }
    }
    
    @IBAction func stopPressed(sender: UIButton) {
        
        timer.invalidate()
        
        willStart()
        
        resetAllPart()
    }
    
    // count
    func countDown() {
        
        timeCount = timeCount - timeInterval
        if timeCount <= 0 {
            
            timer.invalidate()
            
            let audioPath = NSBundle.mainBundle().pathForResource("beep", ofType: "mp3")!
            do {
                try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioPath))
                player.play()
            } catch {
                print("error audio")
            }
            
            let alert = UIAlertController(title: "Alert", message: "Timer has finished", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
            
            willStart()
            resetAllPart()
        }
        timerLabel.text = timeString(timeCount)
    }
    
    // converter timeCount to time
    func timeString(time: NSTimeInterval) -> String {
        
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        
        return String(format: "%02i:%02i", minutes, Int(seconds))
    }
    
    // stage ready for start
    func willStart() {
        tableView.allowsSelection = true
        startButton.enabled = true
        stopButton.enabled = false
    }
    
    // reset timeCount
    func resetAllPart() {
        tempParts = parts
        timeCount = 0.0
        timerLabel.text = "00:00"
        
        tableView.reloadData()
    }
    
    // sum all min checked
    func checkMinute(flag: Bool) -> Double {
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
        
        startButton.enabled = false
        stopButton.enabled = false
        
    }

    

}

extension TimerTOEICTestVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TOEICTableViewCell {
            
            let part = parts[indexPath.row]
            part.toggleChecked()
            
            configureCheckmarkForCell(cell, part: part)
        }
        startButton.enabled = true
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension TimerTOEICTestVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempParts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TOEICTableViewCell
        
        let part = tempParts[indexPath.row]
        if indexPath.row < tempParts.count {
            
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
    
    func configureCheckmarkForCell(cell: TOEICTableViewCell, part: Part) {
        
        if (part.checked != false) {
            cell.checkedLabel.text = "√"
        } else {
            cell.checkedLabel.text = ""
        }
    }
}
