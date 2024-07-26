import UIKit

class CourseInfoViewController: UIViewController {
    var course: Course
    var block: Block
    var day: DaysOfTheWeek
    
    let tableView = UITableView()
    
    var meetingsByDay: [DaysOfTheWeek: [String]] = [:]
    var sortedDays: [DaysOfTheWeek] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = course.name
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MeetingCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        loadData()
    }
    
    init(course: Course, block: Block, day: DaysOfTheWeek) {
        self.course = course
        self.block = block
        self.day = day
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        var meetings: [(day: DaysOfTheWeek, block: Block, startTime: String, endTime: String)] = []
        
        for daySchedule in course.schedule {
            let scheduleType = daySchedule.scheduleType
            let blocks: [Block]
            switch scheduleType {
            case .regular:
                blocks = regularDayBlocks
            case .eDay:
                blocks = eDayBlocks
            case .hDay:
                blocks = hDayBlocks
            case .delayedOpening:
                blocks = delayedOpeningBlocks
            }
            
            for courseBlock in daySchedule.courseBlocks {
                if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                    meetings.append((day: daySchedule.day, block: block, startTime: block.startTime, endTime: block.endTime))
                }
            }
        }
        
        for meeting in meetings {
            formatter.dateFormat = "HH:mm"
            if let startTime = formatter.date(from: meeting.startTime),
               let endTime = formatter.date(from: meeting.endTime) {
                formatter.dateFormat = "h:mm a"
                let formattedStartTime = formatter.string(from: startTime)
                let formattedEndTime = formatter.string(from: endTime)
                
                let timeString = "\(formattedStartTime) - \(formattedEndTime) (Block \(meeting.block.blockNumber))"
                if meetingsByDay[meeting.day] != nil {
                    meetingsByDay[meeting.day]?.append(timeString)
                } else {
                    meetingsByDay[meeting.day] = [timeString]
                }
            }
        }
        
        sortedDays = meetingsByDay.keys.sorted { $0.rawValue < $1.rawValue }
    }
}

extension CourseInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDays.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = sortedDays[section]
        return meetingsByDay[day]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath)
        let day = sortedDays[indexPath.section]
        if let times = meetingsByDay[day] {
            cell.textLabel?.text = times[indexPath.row]
        }
        return cell
    }
}

extension CourseInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let day = sortedDays[section]
        return "\(day)".capitalized
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .label
        }
    }
}
