import UIKit

protocol AddListVCDelegate: AnyObject {
    func didAddTask(_ task: TaskItem)}
class AddListVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    weak var delegate: AddListVCDelegate?

    let categories = ["Work", "Personal", "Health", "Finance"]
    var selectedCategory: String = "Work"

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }

    // MARK: - Picker View Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let taskTitle = taskTextField.text, !taskTitle.isEmpty else { return }

        let newTask = TaskItem(title: taskTitle, category: selectedCategory, isCompleted: false)
        delegate?.didAddTask(newTask)

        dismiss(animated: true)
    }
}
