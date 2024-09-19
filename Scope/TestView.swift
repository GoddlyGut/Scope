//
//  TestView.swift
//  Scope
//
//  Created by Ari Reitman on 9/17/24.
//

import SwiftUI

class CreateNewCourseViewController: UIViewController, CreateNewCourseDelegate {
    var course: Course?

    init(course: Course?) {
        super.init(nibName: nil, bundle: nil)
        self.course = course
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = SwiftUIViewController(course: course, delegate: self)
        
        
        // Add SwiftUIViewController as a child view controller
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    // MARK: - CreateNewCourseDelegate Methods

    func didSaveCourse(_ course: Course) {
        self.course = course
        // Perform save operation or update the model as needed

        if let index = CourseViewModel.shared.courses.firstIndex(where: { $0.id == course.id }) {
            CourseViewModel.shared.courses[index] = course
            NotificationCenter.default.post(name: .didUpdateCourseListFromCourseManager, object: nil)
        } else {
            // Create new course
            CourseViewModel.shared.courses.append(course)
            NotificationCenter.default.post(name: .didUpdateCourseListFromCourseManager, object: nil)
        }

        dismiss(animated: true, completion: nil)
    }

    func didCancel() {
        dismiss(animated: true, completion: nil)
    }
}

class SwiftUIViewController: UIHostingController<SwiftUIView> {
    

    var course: Course?

    init(course: Course?, delegate: CreateNewCourseDelegate) {
        self.course = course
        var swiftUIView = SwiftUIView(course: course, delegate: delegate) // Create the SwiftUIView
        
        super.init(rootView: swiftUIView)
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


struct SwiftUIView: View {
    @State private var courseName: String
    @State private var instructorName: String
    @State private var schedule: [CourseDaySchedule]
    var course: Course?
    @State private var showAlert = false
    @State private var isPresentingAddDayView = false

    init(course: Course?, delegate: CreateNewCourseDelegate) {
        self.course = course
        _courseName = State(initialValue: course?.name ?? "")
        _instructorName = State(initialValue: course?.instructor ?? "")
        _schedule = State(initialValue: course?.schedule ?? [])
        self.delegate = delegate
    }
    
    var delegate: CreateNewCourseDelegate?
    
    var body: some View {
        NavigationStack {
            Form {
                Group {
                    
                    
                    Section("Course Information") {
                        HStack {
                            Text("Course Name:")
                            TextField("Enter course name", text: $courseName)
                        }
                        
                        HStack {
                            Text("Instructor:")
                            TextField("Enter instructor's name", text: $instructorName)
                        }
                    }
                    
                    
                    //Section {
                        //if let schedule = course?.schedule {
                        if schedule.isEmpty {
                            Text("None")
                                .foregroundStyle(.gray)
                        }
                    else {
                        ForEach(schedule.indices, id: \.self) { dayIndex in
                            let daySchedule = schedule[dayIndex]
                            Section {
                                ForEach(daySchedule.courseBlocks.indices, id: \.self) { blockIndex in
                                    let block = daySchedule.courseBlocks[blockIndex]
                                    HStack {
                                        Text("Block \(block.blockNumber)")
                                        Spacer()
                                    }
                                    
                                }
                                .onDelete { offsets in
                                    delete(dayIndex: dayIndex, blockOffsets: offsets)
                                }
                            } header: {
                                HStack {
                                    Text(daySchedule.scheduleType.name)
                                    Spacer()
                                    EditButton()
                                    
                                }
                            }
                        }
                    }
                            
                        
                        //}
                        
                        //                else {
                        //                    Text("None")
                        //                        .foregroundStyle(.gray)
                        //                }
//                    } header: {
//                        HStack {
//                            Text("Schedule")
//                            Spacer()
//                            
//                            EditButton()
//                            
//                        }
//                    } footer: {
//                        
//                    }
                    
                    Section {
                        Button(action: {
                            isPresentingAddDayView = true
                        }) {
                            Text("New Schedule")
                        }
                        .sheet(isPresented: $isPresentingAddDayView) {
                            AddDayView(courseSchedule: $schedule, isPresentingAddDayView: $isPresentingAddDayView)
                        }
                        
                    } header: {
                        
                    } footer: {
                        
                    }
                    
                    
                }
                
            }
            .navigationTitle((course != nil) ? "Edit Course" : "New Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                        save()
                        
                    } label: {
                        Text((course != nil) ? "Save" : "Create")
                    }
                    
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                        delegate?.didCancel()
                        
                    } label: {
                        Text("Cancel")
                    }
                    
                }
            }
            .alert(isPresented: $showAlert) {
                 Alert(title: Text("Please fill in all fields"))
             }
            
        }
        
    }
    
    func save() {
        if (courseName.isEmpty || instructorName.isEmpty) {
            showAlert = true
            return
        }
        print(delegate)
        delegate?.didSaveCourse(Course(id: course?.id ?? UUID(), name: courseName, instructor: instructorName, schedule: schedule))
    }
    
    func delete(dayIndex: Int, blockOffsets: IndexSet) {
        // Get the day at the specified index
        var day = schedule[dayIndex]
        
        // Remove the block at the specified offsets
        day.courseBlocks.remove(atOffsets: blockOffsets)
        
        // If no more blocks are left in this day, remove the day itself
        if day.courseBlocks.isEmpty {
            schedule.remove(at: dayIndex)
        } else {
            // Otherwise, update the day in the schedule
            schedule[dayIndex] = day
        }
    }

    

    
    
}


//#Preview {
//    SwiftUIView(course: nil)
//}


struct AddDayView: View {
    @Binding var courseSchedule: [CourseDaySchedule]
    @State private var selectedDayType: ScheduleType?
    @State private var selectedBlock: Block?
    @State private var showAlert = false
    var delegate: AddNewCourseDelegate?

    // Assuming CourseViewModel is available
    @State private var currentBlocks: [Block] = []
    
    
    @Binding var isPresentingAddDayView: Bool
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Select Day Type")) {
                        Picker("Day Type", selection: $selectedDayType) {
                            if CourseViewModel.shared.scheduleTypes.isEmpty {
                                Text("None").tag(ScheduleType?.none)
                            } else {
                                ForEach(CourseViewModel.shared.scheduleTypes, id: \.id) { type in
                                    Text(type.name).tag(type as ScheduleType?)
                                }
                            }
                        }
                        .onChange(of: selectedDayType) { newValue in
                            updateBlocks(for: newValue)
                        }
                    }
                    
                    Section(header: Text("Select Block")) {
                        Picker("Block", selection: $selectedBlock) {
                            if currentBlocks.isEmpty {
                                Text("None").tag("none")
                            } else {
                                ForEach(currentBlocks, id: \.blockNumber) { block in
                                    Group {
                                        if let startTime = CourseViewModel.shared.combineDateAndTime(date: Date(), time: block.startTime)?.formattedHMTime(),
                                           let endTime = CourseViewModel.shared.combineDateAndTime(date: Date(), time: block.endTime)?.formattedHMTime() {
                                           Text(currentBlocks.isEmpty ? "None" : "Block \(block.blockNumber): \(startTime) - \(endTime)")
                                        } else {
                                            Text(currentBlocks.isEmpty ? "None" : "Block \(block.blockNumber): \(block.startTime) - \(block.endTime)")
                                        }
                                    }.tag(block)
                                    
                                    
                                }
                            }
                        }
                    }
                }
                
                Button(action: addDay) {
                    Text("Add Day")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Add Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddDayView = false
                    } label: {
                        Text("Close")
                    }

                }
            }
            .onAppear {
                selectedDayType = CourseViewModel.shared.scheduleTypes.first
                updateBlocks(for: selectedDayType)
            }
            .alert(isPresented: $showAlert) {
                 Alert(title: Text("Please select a block and day type"))
             }
        }
    }
    
    private func updateBlocks(for dayType: ScheduleType?) {
        guard let selectedDay = dayType else { return }
        
        // Filter blocks that have already been used
        let blocks = CourseViewModel.shared.blocksByScheduleType[selectedDay.id] ?? []
        let usedBlockNumbers = courseSchedule
            .first(where: { $0.scheduleType.id == selectedDay.id })?
            .courseBlocks.map { $0.blockNumber } ?? []
        
        currentBlocks = blocks.filter { !usedBlockNumbers.contains($0.blockNumber) }
        currentBlocks.sort { $0.blockNumber < $1.blockNumber }
        
        // Reset selected block when updating blocks
        selectedBlock = currentBlocks.first
    }
    
    private func addDay() {
        guard let selectedDayType = selectedDayType, let selectedBlock = selectedBlock else {
            showAlert = true
            return
        }
        
        if let index = courseSchedule.firstIndex(where: { $0.scheduleType.id == selectedDayType.id }) {
            // Modify the existing schedule
            if courseSchedule[index].courseBlocks.contains(where: { $0.blockNumber == selectedBlock.blockNumber }) {
                // Show error if block number is already in use
                showAlert = true
                return
            } else {
                courseSchedule[index].courseBlocks.append(CourseBlock(courseName: "", blockNumber: selectedBlock.blockNumber))
            }
        } else {
            // Add a new schedule if none exists
            let newSchedule = CourseDaySchedule(id: UUID(), scheduleType: selectedDayType, courseBlocks: [CourseBlock(courseName: "", blockNumber: selectedBlock.blockNumber)])
            courseSchedule.append(newSchedule)
        }
        
        isPresentingAddDayView = false
    }

}
