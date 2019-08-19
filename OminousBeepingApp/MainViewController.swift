//
//  MainViewController.swift
//  OminousBeepingApp
//
//  Created by Jake on 7/22/19.
//  Copyright © 2019 jake. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    // An accumulator to check if the user is tapping the screen a lot (possibly in confusion).
    private var _tapAccumulator: Int = 0
    
    // Audio player for playing beeps.
    private var _audioPlayer: AVAudioPlayer?
    // Path to the beep file.
    private let kBeepFileUrl: String? = Bundle.main.path(forResource: "beep", ofType: "wav")
    
    private var _beepTimer: Foundation.Timer?
    // The max speed of the beeping.
    private let kBeepMaxInterval: Double = 0.3
    // The threshold of beeps after which we will speed up the beeping to twice as fast.
    private let kDoubleTimeThreshold: Int = 4
    
    // Diameter of the beepy circle thing.
    private let kBeepyCircleDiameter: CGFloat = {
        let val = (UIScreen.main.nativeBounds.width / UIScreen.main.scale) * 0.7
        if val > 500.0 {
            return 500.0
        }
        return val
    }()
    
    private let _titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 128.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.textColor = .appGreen
        label.text = "OMINOUS\nBEEPING\nAPP"
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(lessThanOrEqualToConstant: (UIScreen.main.nativeBounds.width / UIScreen.main.scale) * 0.8).isActive = true
        return label
    }()
    
    private lazy var _beepyCircle: BeepCircleView = BeepCircleView(frame: CGRect(x: 0.0, y: 0.0, width: kBeepyCircleDiameter, height: kBeepyCircleDiameter))
    
    private let _messageAlert: UIAlertController = {
        let alert = UIAlertController(title: "Shake it!", message: "To start the beeping, shake your device.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }()
    
    // Ensure we have a light status bar here for legibility purposes.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Just in case message alert is displayed.
            _messageAlert.dismiss(animated: true, completion: nil)
            _tapAccumulator = 0
            startBeeping()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
        
        // Set up the beep audio player.
        do {
            if let fileURL = kBeepFileUrl {
                _audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                _audioPlayer?.prepareToPlay()
            } else {
                print("No file with specified name exists.")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription).")
        }
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.background
        
        let contentView = UIStackView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.isUserInteractionEnabled = true
        contentView.alignment = .center
        contentView.axis = .vertical
        contentView.distribution = .equalSpacing
        contentView.addArrangedSubview(_beepyCircle)
        
        let titleContainer = UIView()
        titleContainer.addSubview(_titleLabel)
        _titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor).isActive = true
        _titleLabel.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor).isActive = true
        contentView.addArrangedSubview(titleContainer)
        
        let topMargin: CGFloat = (UIScreen.main.nativeBounds.height / UIScreen.main.nativeScale) * 0.07
        
        self.view.addSubview(contentView)
        contentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: topMargin).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        // Tap gesture that stops the beeping.
        let tap = UITapGestureRecognizer(target: self, action: #selector(stopBeeping))
        tap.cancelsTouchesInView = true
        contentView.addGestureRecognizer(tap)
    }
    
    /// Play a beep sound once.
    private func beep() {
        _audioPlayer?.prepareToPlay()
        _audioPlayer?.play()
        _beepyCircle.beep(speed: self.kBeepMaxInterval * 0.5)
    }
    
    private func startBeeping() {
        if _beepTimer == nil {
            var count: Int = 0
            // Start by playing a beep every two intervals.
            var reducer: Int = 2
            _beepTimer = Timer.scheduledTimer(withTimeInterval: kBeepMaxInterval, repeats: true, block: { (timer) in
                if count % reducer == 0 {
                    // Play beep.
                    self.beep()
                }
                if count == 1 + self.kDoubleTimeThreshold * 2 {
                    reducer = 1
                }
                count += 1
            })
        }
    }
    
    @objc private func stopBeeping() {
        if _beepTimer != nil {
            _beepTimer?.invalidate()
            _beepTimer = nil
        } else if _tapAccumulator == 10 {
            _tapAccumulator = 0
            // The user may be confused. Present an informative alert.
            self.present(_messageAlert, animated: true)
        } else {
            _tapAccumulator += 1
        }
    }
    
}
