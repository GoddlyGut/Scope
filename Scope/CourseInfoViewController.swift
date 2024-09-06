import UIKit

class CourseInfoViewController: UIViewController {
    var course: Course
    var block: Block
    var dayType: ScheduleType
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    var closeButton = CloseButtonView()
    var editButton = UIButton()
    
    var meetingsByDay: [(date: Date, dayType: ScheduleType, meetings: [String])] = []
    var sortedDays: [(date: Date, dayType: ScheduleType)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: editButton)
        title = course.name
        view.backgroundColor = .systemGroupedBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MeetingCell")
        
        closeButton.circle.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        view.addSubview(tableView)
        
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(editCourse), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .didUpdateCourseList, object: nil)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
        
        loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateUI() {
        loadData()
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    @objc func editCourse() {
        navigationController?.pushViewController(NewCourseViewController(course: course), animated: true)
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
    
    func schoolDaysForCurrentWeek() -> [SchoolDay] {
        guard let startOfWeek = Date().startOfWeek(), let endOfWeek = Date().endOfWeek() else {
            return []
        }

        return CourseViewModel.shared.schoolDays.filter { $0.date >= startOfWeek && $0.date <= endOfWeek }
    }
    
    
    func loadData() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentWeekSchoolDays = schoolDaysForCurrentWeek()
        
        var meetings: [(date: Date, dayType: ScheduleType, block: Block, startTime: String, endTime: String)] = []
        
        for daySchedule in course.schedule {
            let scheduleType = daySchedule.scheduleType
            // Get the blocks for this schedule type dynamically
            guard let blocks = CourseViewModel.shared.blocksByScheduleType[scheduleType.id] else { continue }
            
            for courseBlock in daySchedule.courseBlocks {
                if let block = blocks.first(where: { $0.blockNumber == courseBlock.blockNumber }) {
                    for schoolDay in currentWeekSchoolDays where schoolDay.dayType.id == scheduleType.id {
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
                
                let timeString = "\(formattedStartTime) - \(formattedEndTime) • Block \(meeting.block.blockNumber)"
                
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
        
        // Ensure all weekdays from Monday to Friday are included
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return
        }
        
        for schoolDay in currentWeekSchoolDays {
            if groupedMeetings[schoolDay.date] == nil {
                groupedMeetings[schoolDay.date] = [schoolDay.dayType: ["No class"]]
            } else if groupedMeetings[schoolDay.date]?[schoolDay.dayType] == nil {
                groupedMeetings[schoolDay.date]?[schoolDay.dayType] = ["No class"]
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
                return lhs.dayType.name < rhs.dayType.name
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
            cell.textLabel?.textColor = meetings[indexPath.row] == "No class" ? .secondaryLabel : .label
            cell.selectionStyle = .none
        }
        return cell
    }
}

extension CourseInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (date, dayType) = sortedDays[section]
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        let dateString = formatter.string(from: date)
        return "\(dayType.name) - \(date.isToday() ? "Today" : dateString)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .label
            header.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        }
    }
}

extension Date {


    func isToday(using calendar: Calendar = .current) -> Bool {
        return calendar.isDateInToday(self)
    }
}



class CloseButtonView: UIView {
    
    var circle = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        circle.layer.cornerRadius = 30 / 2
    }
}

extension CloseButtonView {
    func style() {
        translatesAutoresizingMaskIntoConstraints = false
        
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.19, green: 0.19, blue: 0.19, alpha: 1) : UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        circle.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        circle.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor(red: 0.62, green: 0.62, blue: 0.62, alpha: 1) : UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1)
        
        addSubview(circle)
    }
    
    func layout() {
        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 30),
            circle.heightAnchor.constraint(equalToConstant: 30),
            circle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}
