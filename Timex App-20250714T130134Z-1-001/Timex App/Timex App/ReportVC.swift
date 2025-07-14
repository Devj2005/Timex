import UIKit
import DGCharts

class ReportVC: UIViewController {
    @IBOutlet weak var chartView: BarChartView!
    
    var totalTasks = 0
    var completedTasks = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem = UITabBarItem(
            title: "Reports",
            image: UIImage(systemName: "chart.bar.fill"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        setupChart()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchTaskCompletionData), name: NSNotification.Name("TasksUpdated"), object: nil)
        
        fetchTaskCompletionData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func fetchTaskCompletionData() {
        guard let savedData = UserDefaults.standard.data(forKey: "tasksData") else {
            updateChart(total: 0, completed: 0)
            return
        }

        do {
            let taskCategories = try JSONDecoder().decode([TaskCategory].self, from: savedData)
            let allTasks = taskCategories.flatMap { $0.tasks }
            totalTasks = allTasks.count
            completedTasks = allTasks.filter { $0.isCompleted }.count
            
            DispatchQueue.main.async {
                self.updateChart(total: self.totalTasks, completed: self.completedTasks)
            }
            
        } catch {
            print("⚠️ Error decoding tasks: \(error)")
            updateChart(total: 0, completed: 0)
        }
    }
    
    func setupChart() {
        let xAxis = chartView.xAxis
        xAxis.labelFont = .boldSystemFont(ofSize: 16) // Increased text size
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.valueFormatter = IndexAxisValueFormatter(values: ["Total", "Completed"])
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .boldSystemFont(ofSize: 16) // Increased text size
        leftAxis.axisMinimum = 0
        leftAxis.granularity = 1
        leftAxis.drawGridLinesEnabled = false
        
        chartView.rightAxis.enabled = false
        chartView.legend.font = .boldSystemFont(ofSize: 14) // Increased legend size
        chartView.animate(yAxisDuration: 1.5)
    }

    func updateChart(total: Int, completed: Int) {
        let dataEntries: [BarChartDataEntry] = [
            BarChartDataEntry(x: 0, y: Double(total)),
            BarChartDataEntry(x: 1, y: Double(completed))
        ]
        
        let dataSet = BarChartDataSet(entries: dataEntries, label: "Tasks Overview")
        dataSet.colors = [UIColor.blue, UIColor.green] // Adjusted colors to match your screenshot
        
        let chartData = BarChartData(dataSet: dataSet)
        chartData.setValueFont(.boldSystemFont(ofSize: 16)) // Increased text size for values
        
        chartView.data = chartData
        chartView.notifyDataSetChanged()
    }
}
