//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Bryan Morfe on 12/18/16.
//  Copyright © 2016 Morfe. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: Outlets

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // MARK: Other variables
    
    var audioRecorder: AVAudioRecorder!
    
    // MARK: Helper enumeration
    
    enum RecordingState {
        case recording, notRecording
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isEnabled = false
    }
    
    // MARK: Actions

    @IBAction func recordButton(_ sender: AnyObject) {
        setUI(toState: .recording)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let fileName = "recordedVoice.wav"
        let pathArray = [dirPath, fileName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
    }
    
    @IBAction func stopButton(_ sender: AnyObject) {
        setUI(toState: .notRecording)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Setup the next controller for playback
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

// MARK: Other methods

extension RecordSoundsViewController {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: self.audioRecorder.url)
        } else {
            print("Recording was not successful.")
        }
    }
    
    // MARK: Convenience method that sets up the UI according to the controller state
    
    func setUI(toState state: RecordingState) {
        switch(state) {
        case .recording:
            recordingLabel.text = "Recording"
            stopButton.isEnabled = true
            recordButton.isEnabled = false
        case .notRecording:
            recordingLabel.text = "Tap to Record"
            stopButton.isEnabled = false
            recordButton.isEnabled = true
        }
    }
    
}
