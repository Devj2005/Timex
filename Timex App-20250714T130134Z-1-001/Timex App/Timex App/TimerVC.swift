import UIKit

class TimerVC: UIViewController, FocusPresetDelegate {

    // Outlets
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // Timer Variables
    var timer: Timer?
    var secondsRemaining: Int = 60 // Default 1-minute timer
    var initialDuration: Int = 0
    var isTimerRunning = false
    var isPaused = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem = UITabBarItem(
            title: "Time",
            image: UIImage(systemName: "clock.fill"),
            selectedImage: UIImage(systemName: "clock.fill")
        )
        // Set Date Picker Mode
        timePicker.datePickerMode = .countDownTimer
        timePicker.addTarget(self, action: #selector(timePickerChanged), for: .valueChanged)

        updateTimerLabel()
    }

    // Updates the timer label
    func updateTimerLabel() {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }


    // Delegate method to receive selected preset time
    func didSelectPreset(duration: Int) {
        secondsRemaining = duration
        updateTimerLabel()
    }


    // Start/Resume Timer
    @IBAction func startTimer(_ sender: UIButton) {
        if !isTimerRunning {
            isTimerRunning = true
            isPaused = false
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }

    // Pause/Resume Timer
    @IBAction func pauseTimer(_ sender: UIButton) {
        if isTimerRunning {
            if isPaused {
                // Resume Timer
                isPaused = false
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            } else {
                // Pause Timer
                isPaused = true
                timer?.invalidate()
            }
        }
    }

    // Reset Timer
    @IBAction func resetTimer(_ sender: UIButton) {
        timer?.invalidate()
        isTimerRunning = false
        isPaused = false
        secondsRemaining = initialDuration // Reset to Picker Time
        updateTimerLabel()
    }

    // Timer Countdown Logic
    @objc func updateTime() {
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            isTimerRunning = false
            showAlert()
        }
    }

    // Show Alert When Timer Ends
    func showAlert() {
        let alert = UIAlertController(title: "Time's Up!", message: "Your timer has finished.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        secondsRemaining = Int(sender.countDownDuration)
        updateTimerLabel()
    }

}
