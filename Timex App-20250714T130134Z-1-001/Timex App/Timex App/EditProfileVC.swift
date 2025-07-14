import UIKit

class EditProfileVC: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var dobPicker: UIDatePicker!
    
    var currentName: String?
    var currentEmail: String?
    var currentDOB: TimeInterval?
    
    var onSave: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = currentName ?? ""
        emailTextField.text = currentEmail ?? ""
        
        if let currentDOB = currentDOB {
            dobPicker.date = Date(timeIntervalSince1970: currentDOB)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let updatedName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let updatedEmail = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let updatedDOB = dobPicker.date.timeIntervalSince1970
        
        UserDefaults.standard.set(updatedName, forKey: "userName")
        UserDefaults.standard.set(updatedEmail, forKey: "userEmail")
        UserDefaults.standard.set(updatedDOB, forKey: "userDOB")

        onSave?()  // Notify ProfileVC to update UI
        dismiss(animated: true)
    }
}
