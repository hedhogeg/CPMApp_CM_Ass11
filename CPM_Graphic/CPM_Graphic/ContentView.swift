//
//  ContentView.swift
//  CPM_Graphic
//
//  Created by 김형관 on 4/2/24.
//
import SwiftData
import SwiftUI
struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @State private var path = NavigationPath()
    @Query var activities: [Activity]
    @State private var projectResult: String?
    @State private var isShowingProjectResults = false
    @State private var startDateInput: String = "1"
    @State private var isShowingAddActivityPopup = false
    @State private var isShowingResetConfirmation = false

    
    var body: some View {
        NavigationStack (path: $path) {
            ProjectView(startDateInput: $startDateInput)
                .navigationTitle("Activity List")
                .navigationDestination(for: Activity.self ) { activity in
                EditActivityView(navigationPath: $path, activity: activity)
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        calculateSchedule()
                    } label: {
                        Label("Schedule", systemImage: "calendar")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddActivityPopup = true
                    } label: {
                        Label("Add Activity", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingResetConfirmation = true
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingProjectResults) {
                if let resultString = projectResult {
                    ProjectResultView(resultString: resultString)
                }
            }
            .alert(isPresented: .constant(isShowingAddActivityPopup || isShowingResetConfirmation)) {
                if isShowingAddActivityPopup {
                    return Alert(
                        title: Text("Add Activity"),
                        message: Text("Would you like to add a new activity?"),
                        primaryButton: .default(Text("Yes")) {
                            addActivity()
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                            isShowingAddActivityPopup = false
                        }
                    )
                } else {
                    return Alert(
                        title: Text("Reset Schedule"),
                        message: Text("Reset?"),
                        primaryButton: .destructive(Text("Yes")) {
                            reset()
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                            isShowingResetConfirmation = false
                        }
                    )
                }
            }
        }
    }
    
    func addActivity() {
        let newId = (activities.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let activity =  Activity(id: newId, name: "", duration: 0)
        modelContext.insert(activity)
        path.append(activity)
        isShowingAddActivityPopup = false
    }
    
    func calculateSchedule() {
        
        guard let startDate = Int(startDateInput) else {
            print("Invalid start date input")
            return
        }

        let schedule = Schedule(startDate: startDate, schedule: activities)
        let project = Project(schedules: [schedule])
        project.scheduleCalculation()
        
        self.projectResult = project.result
        
        isShowingProjectResults = true
    }
    func reset() {
        path = NavigationPath()
        projectResult = nil
        isShowingProjectResults = false
        activities.forEach { modelContext.delete($0) }
        isShowingResetConfirmation = false
    }
}
