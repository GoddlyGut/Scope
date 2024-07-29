import UIKit

class CourseInfoViewController: UIViewController {
    var course: Course
    var block: Block
    var dayType: ScheduleType
    
    let tableView = UITableView()
    
    var meetingsByDay: [(date: Date, dayType: ScheduleType, meetings: [String])] = []
    var sortedDays: [(date: Date, dayType: ScheduleType)] = []


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
    
    init(course: Course, block: Block, dayType: ScheduleType) {
        self.course = course
        self.block = block
        self.dayType = dayType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentWeekSchoolDays = schoolDaysForCurrentWeek()
        
        var meetings: [(date: Date, dayType: ScheduleType, block: Block, startTime: String, endTime: String)] = []
        
        for daySchedule in course.schedule {
            let scheduleType = daySchedule.scheduleType
            let blocks: [Block]
            switch scheduleType {
            case .eDay:
                blocks = eDayBlocks
            case .hDay:
                blocks = hDayBlocks
            case .delayedOpening:
                blocks = delayedOpeningBlocks
            default:
                blocks = regularDayBlocks
            }
            
            for courseBlock in daySchedule.courseBlocks {
                if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                    for schoolDay in currentWeekSchoolDays where schoolDay.dayType == scheduleType {
                        meetings.append((date: schoolDay.date, dayType: scheduleType, block: block, startTime: block.startTime, endTime: block.endTime))
                    }
                }
            }
        }
        
        var groupedMeetings: [Date: [ScheduleType: [String]]] = [:]
        
        for meeting in meetings {
            formatter.dateFormat = "HH:mm"
            if let startTime = formatter.date(from: meeting.startTime),
               let endTime = formatter.date(from: meeting.endTime) {
                formatter.dateFormat = "h:mm a"
                let formattedStartTime = formatter.string(from: startTime)
                let formattedEndTime = formatter.string(from: endTime)
                
                let timeString = "\(formattedStartTime) - \(formattedEndTime) (Block \(meeting.block.blockNumber))"
                
                if groupedMeetings[meeting.date] != nil {
                    if groupedMeetings[meeting.date]![meeting.dayType] != nil {
                        groupedMeetings[meeting.date]![meeting.dayType]!.append(timeString)
                    } else {
                        groupedMeetings[meeting.date]![meeting.dayType] = [timeString]
                    }
                } else {
                    groupedMeetings[meeting.date] = [meeting.dayType: [timeString]]
                }
            }
        }
        
        meetingsByDay = groupedMeetings.flatMap { date, dayMeetings in
            dayMeetings.map { dayType, meetings in
                (date: date, dayType: dayType, meetings: meetings)
            }
        }
        
        sortedDays = meetingsByDay.map { ($0.date, $0.dayType) }
        sortedDays.sort { lhs, rhs in
            if lhs.date == rhs.date {
                return lhs.dayType.rawValue < rhs.dayType.rawValue
            }
            return lhs.date < rhs.date
        }
    }



    
    func scheduleDayOfWeek(for dayType: ScheduleType) -> [String] {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            
        let days = CourseViewModel.shared.schoolDays.filter { $0.dayType == dayType }
            let dayNames = days.map { formatter.string(from: $0.date) }
            return dayNames
        }
}

extension CourseInfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDays.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (date, dayType) = sortedDays[section]
        return meetingsByDay.first { $0.date == date && $0.dayType == dayType }?.meetings.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell", for: indexPath)
        let (date, dayType) = sortedDays[indexPath.section]
        if let meetings = meetingsByDay.first(where: { $0.date == date && $0.dayType == dayType })?.meetings {
            cell.textLabel?.text = meetings[indexPath.row]
        }
        return cell
    }
    
    func schoolDaysForCurrentWeek() -> [SchoolDay] {
        guard let startOfWeek = Date().startOfWeek(), let endOfWeek = Date().endOfWeek() else {
            return []
        }
        
        return CourseViewModel.shared.schoolDays.filter { $0.date >= startOfWeek && $0.date <= endOfWeek }
    }
}

extension CourseInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (date, dayType) = sortedDays[section]
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        let dateString = formatter.string(from: date)
        return "\(dayType.rawValue) - \(date.isToday() ? "Today" : dateString)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .label
        }
    }
}
