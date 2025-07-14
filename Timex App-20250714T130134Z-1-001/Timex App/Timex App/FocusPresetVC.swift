import UIKit

protocol FocusPresetDelegate: AnyObject {
    func didSelectPreset(duration: Int)
}

class FocusPresetVC: UIViewController {
    
    weak var delegate: FocusPresetDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    var selectedTime: Int = 1500 // Default time
    
    @IBAction func presetButtonTapped(_ sender: UIButton) {
        let presetTimes: [Int] = [1500, 2700, 3600] // 25 min, 45 min, 60 min
        selectedTime = presetTimes[sender.tag]
        
        performSegue(withIdentifier: "goToTimerVC", sender: self) // Use your segue identifier
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTimerVC",
              let timerVC = segue.destination as? TimerVC {
               timerVC.secondsRemaining = selectedTime
               timerVC.initialDuration = selectedTime // Store the original preset time
        }
    }
}
