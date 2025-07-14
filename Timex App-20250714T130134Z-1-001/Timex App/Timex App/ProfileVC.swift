import UIKit

class ProfileVC: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!

    override func viewDidLoad() {
      super.viewDidLoad()
        tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.fill"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        loadUserProfile() // Initial profile load
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserProfile() // Refresh profile when coming back from edit
    }

    func loadUserProfile() {
        let defaults = UserDefaults.standard
        
        nameLabel.text = defaults.string(forKey: "userName") ?? "Guest"
        emailLabel.text = defaults.string(forKey: "userEmail") ?? "No Email Found"

        // Convert stored DOB to a formatted date string
        if let dobTimeInterval = defaults.value(forKey: "userDOB") as? TimeInterval {
            let dobDate = Date(timeIntervalSince1970: dobTimeInterval)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dobLabel.text = dateFormatter.string(from: dobDate)
        } else {
            dobLabel.text = "DOB Not Set"
        }
    }
    
    @IBAction func editProfileTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editProfileVC = storyboard.instantiateViewController(identifier: "EditProfileVC") as? EditProfileVC {
            
            let defaults = UserDefaults.standard
            editProfileVC.currentName = defaults.string(forKey: "userName")
            editProfileVC.currentEmail = defaults.string(forKey: "userEmail")
            editProfileVC.currentDOB = defaults.value(forKey: "userDOB") as? TimeInterval

            editProfileVC.onSave = { [weak self] in
                self?.loadUserProfile()
            }
            
            present(editProfileVC, animated: true)
        }
    }
}
