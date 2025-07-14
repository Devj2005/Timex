import UIKit

protocol TaskUpdateDelegate: AnyObject {
    func didUpdateTasks()
}

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timerButton: UIButton!
    
    @IBOutlet weak var completedTasksLabel: UILabel!
    @IBOutlet weak var totalTasksLabel: UILabel!
    
    var tasks: [TaskItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        setupTableView()
        setupLabels()
        loadTasks()
        updateGreeting()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateTasks), name: NSNotification.Name("TasksUpdated"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks()
    }
    
    // MARK: - Setup Labels with UI Enhancements
    func setupLabels() {
        [totalTasksLabel, completedTasksLabel].forEach { label in
            label?.textAlignment = .center
            label?.font = UIFont.boldSystemFont(ofSize: 16)
            label?.textColor = .white
            label?.layer.cornerRadius = 10
            label?.layer.masksToBounds = true
            label?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            label?.alpha = 0 // Start hidden for animation
        }
    }
    
    // MARK: - Setup TableView
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
    }
    
    // MARK: - Update Greeting
    func updateGreeting() {
        if let userName = UserDefaults.standard.string(forKey: "userName") {
            greetingLabel.text = "Hello, \(userName)! 👋"
        }
    }
    
    // MARK: - Load Tasks with Animation
    func loadTasks() {
        if let savedData = UserDefaults.standard.data(forKey: "tasksData") {
            do {
                let decodedArray = try JSONDecoder().decode([TaskCategory].self, from: savedData)
                tasks = decodedArray.flatMap { $0.tasks }
            } catch {
                print("⚠️ Failed to decode tasks: \(error)")
                tasks = []
            }
        } else {
            tasks = []
        }
        
        // Task Stats
        let totalTasks = tasks.count
        let completedTasks = tasks.filter { $0.isCompleted }.count
        
        // Animate Label Updates
        UIView.transition(with: totalTasksLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.totalTasksLabel.text = totalTasks > 0 ? "Total Tasks: \(totalTasks)" : "No Tasks Yet"
        }, completion: nil)
        
        UIView.transition(with: completedTasksLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.completedTasksLabel.text = "Completed: \(completedTasks)"
        }, completion: nil)
        
        // Animate labels appearing
        UIView.animate(withDuration: 0.6) {
            self.totalTasksLabel.alpha = 1
            self.completedTasksLabel.alpha = 1
        }
        
        // Animate tableView reload
        UIView.transition(with: tableView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = "\(task.title) - [\(task.category)]"
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tabBarController?.selectedIndex = 1
    }
    
    // MARK: - Actions
    @IBAction func timerButtonTapped(_ sender: UIButton) {
        print("⏳ Timer button tapped!")
    }
    
    @IBAction func focusModeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let presetVC = storyboard.instantiateViewController(withIdentifier: "FocusPresetVC") as? FocusPresetVC {
            navigationController?.pushViewController(presetVC, animated: true)
        }
    }
    
    func clearTasksIfNeeded() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "resetTasks")
        if defaults.bool(forKey: "resetTasks") {
            defaults.removeObject(forKey: "tasksData")
            defaults.set(false, forKey: "resetTasks")
            defaults.synchronize()
            print("✅ Cleared saved tasks")
        }
    }
}

// MARK: - TaskUpdateDelegate
extension HomeVC: TaskUpdateDelegate {
    @objc func didUpdateTasks() {
        loadTasks()
    }
}
