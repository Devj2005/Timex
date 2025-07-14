import UIKit

struct TaskItem: Codable {
    var title: String
    var category: String
    var isCompleted: Bool
}

struct TaskCategory: Codable {
    let category: String
    var tasks: [TaskItem]
}

class TasksVC: UIViewController, UITableViewDelegate, UITableViewDataSource, AddListVCDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTaskButton: UIBarButtonItem!

    var tasksByCategory: [String: [TaskItem]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadTasksFromUserDefaults()
        tabBarItem = UITabBarItem(title: "Tasks", image: UIImage(systemName: "list.bullet.rectangle"), selectedImage: UIImage(systemName: "list.bullet.rectangle.fill"))
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasksByCategory.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Array(tasksByCategory.keys)[section]
        return tasksByCategory[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(tasksByCategory.keys)[section]
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let category = Array(tasksByCategory.keys)[indexPath.section]
        if let task = tasksByCategory[category]?[indexPath.row] {
            cell.textLabel?.text = task.title
            cell.accessoryType = task.isCompleted ? .checkmark : .none
        }
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = Array(tasksByCategory.keys)[indexPath.section]
        if var tasks = tasksByCategory[category] {
            tasks[indexPath.row].isCompleted.toggle()
            tasksByCategory[category] = tasks
            saveTasksToUserDefaults()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            NotificationCenter.default.post(name: NSNotification.Name("TasksUpdated"), object: nil)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = Array(tasksByCategory.keys)[indexPath.section]
            tasksByCategory[category]?.remove(at: indexPath.row)
            if tasksByCategory[category]?.isEmpty == true {
                tasksByCategory.removeValue(forKey: category)
            }
            saveTasksToUserDefaults()
            tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name("TasksUpdated"), object: nil)
        }
    }

    // MARK: - AddListVC Delegate
    func didAddTask(_ task: TaskItem) {
        if tasksByCategory[task.category] == nil {
            tasksByCategory[task.category] = []
        }
        tasksByCategory[task.category]?.append(task)
        saveTasksToUserDefaults()
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name("TasksUpdated"), object: nil)
    }

    // MARK: - UserDefaults Handling
    func saveTasksToUserDefaults() {
        let taskArray = tasksByCategory.map { TaskCategory(category: $0.key, tasks: $0.value) }
        if let encodedData = try? JSONEncoder().encode(taskArray) {
            UserDefaults.standard.set(encodedData, forKey: "tasksData")
        }
    }

    func loadTasksFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "tasksData"),
           let decodedArray = try? JSONDecoder().decode([TaskCategory].self, from: savedData) {
            tasksByCategory = Dictionary(uniqueKeysWithValues: decodedArray.map { ($0.category, $0.tasks) })
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddListVC",
           let destinationVC = segue.destination as? AddListVC {
            destinationVC.delegate = self
        }
    }

    @IBAction func addTaskButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toAddListVC", sender: nil)
    }
}
