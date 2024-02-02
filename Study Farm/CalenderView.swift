


import SwiftUI
import Foundation

struct CalendarView: View {
    @ObservedObject private var dataModel = AuthViewModel()
    @State private var currentDate: Date = .init()
    @State private var weekSlider: [[Date.WeekDay]] = []
    @State private var currentWeekIndex : Int = 1
    @State private var createWeek: Bool = false
    //@State private var testTask: TaskInterval
    
    @Namespace private var animation
    var body: some View {
        ZStack{
            Color(red: 188/255, green: 224/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0){
                //HEADER VIEW
                HeaderView()
                
                
                
                TaskView()
                /*.onChange(of: currentDate) { newDate in
                 dataModel.fetchTasksFor(date: currentDate.formatted(date: .complete, time: .omitted))
                 print (currentDate.formatted())
                 print("Changed")
                 }*/
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .onAppear(perform: {
                if weekSlider.isEmpty {
                    let currentWeek = Date().fetchweek()
                    
                    if let firstDate = currentWeek.first?.date{
                        weekSlider.append(firstDate.createPreviousWeek())
                    }
                    weekSlider.append(currentWeek)
                    
                    if let lastDate = currentWeek.last?.date{
                        weekSlider.append(lastDate.createNextWeek())
                        
                    }
                    
                    
                }
                
                
            })
            
            
        }
        
    }
        
    
    
        
    
    
    
    
    @ViewBuilder
    func HeaderView() -> some View {
        
        VStack(alignment: .leading, spacing: 6){
            HStack(spacing: 5) {
                Text(currentDate.format("MMMM"))
                    .foregroundColor(Color.blue)
                Text(currentDate.format("YYYY"))
                    .foregroundColor(Color.gray)
            }
            .font(.title.bold())
            
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(Color.gray)
            
            //Week Slider
            TabView(selection: $currentWeekIndex){
                ForEach(weekSlider.indices, id:\.self) { index in
                    let week = weekSlider[index]
                    WeekView(week)
                        .padding(.horizontal, 15)
                        .tag(index)
                }
            }
            
            .padding(.horizontal, -15)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 90)
            
            
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing, content: {
            Button(action: {}, label: {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    
            })
        })
        .padding(15)
        .frame(minWidth: 100, alignment: .leading)
        .background(Color(red: 188/255, green: 224/255, blue: 247/255))
        .onChange(of: currentWeekIndex) {newValue in
            if newValue == 0 || newValue == (weekSlider.count - 1) {
                createWeek = true
            }
            
        }
    }
    
    @ViewBuilder
    func TaskView() -> some View{
        VStack{
            ScrollView{
                
                ForEach(dataModel.tasksForTheDay) { TaskInterval in
                    //print(TaskInterval.startHour.format("MMMM"))
                    indiTask(taskName: TaskInterval.title, startHour: TaskInterval.startHour, startMinute: TaskInterval.startMinute, endHour: TaskInterval.endHour, endMinute: TaskInterval.endMinute)
                    
                    //print(TaskInterval.startHour.format("MMMM"))
                    
                }
                
                
            }
                
            
            
            
            
            
            
        }
        
    }
        
    struct indiTask: View {
        var taskName: String
        var startHour: String
        var startMinute: String
        var endHour: String
        var endMinute: String
        
        var body: some View{
            
            HStack{
                
                
                Circle()
                
                    .fill(.cyan)
                    .frame( width: 15, height: 15)
                    .padding(5)
                    
                
                Button(action: {}, label: {
                    
                    
                    /// for each task {
                    /// create taskview,
                    ///
                    ///
                    ///
                    Text("\(startHour):\(startMinute) - \(endHour):\(endMinute)   \(taskName)")
                    
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 350, alignment: .center)
                        .background(Color(red: 186/255, green: 233/255, blue: 217/255))
                        .cornerRadius(15)
                    //.frame(width: 150, alignment: .center)
                    
                    
                })
            }
            
            
        }
        
        
    }
    
    
    @ViewBuilder
    func WeekView(_ week: [Date.WeekDay]) -> some View {
        HStack(spacing: 0){
            ForEach(week) { day in
                VStack(spacing: 8) {
                    Text(day.date.format("E"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.gray)
                    
                    Text(day.date.format("dd"))
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundStyle(isSameDate(day.date, currentDate) ? .white: Color.gray)
                        .frame(width: 35, height: 35)
                        .background(content: {
                            if isSameDate(day.date, currentDate) {
                                
                                Circle()
                                    
                                    .fill(Color.blue)
                                   // .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
                                
                                
                                
                            }
                            
                        
                            // Indicator to show which is todays date
                            if day.date.isToday {
                                
                                Circle()
                                    .fill(.cyan)
                                    .frame( width: 5, height: 5)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .offset(y: 12 )
                            }
                            
                            Color(red: 186/255, green: 233/255, blue: 217/255)
                                .cornerRadius(20)
                            
                            
                            
                        })
                        .background(.white.shadow(.drop(radius: 1)), in: Circle())
                        
                }
                
                .frame(maxWidth: .infinity, alignment: .center)
                .contentShape(Rectangle())
                .onTapGesture{
                    withAnimation(Animation.default){
                        currentDate = day.date
                        print(currentDate.formatted(date: .complete, time: .omitted))
                        dataModel.fetchTasksFor(date: currentDate.formatted(date: .complete, time: .omitted))
                        
                        
                    }
                }
                
            }
        }
        
        
        
       
        
        
        
    }
    
    
    
    
    
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}




struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
struct TaskInterval: Identifiable{
    
    
    var id = UUID()
    var title: String
    var startHour: String // starting from 0 to 23
    var startMinute: String // from 0 to 59
    var endHour: String // ending on 1 to 24
    var endMinute: String // from 0 to 59
    var formatDate: String // formatted date
    //var date: Date
}

extension Date{
    
    //Custom Date Format
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
    
    
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    
    func fetchweek(_ date : Date = .init()) -> [WeekDay] {
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: date)
        
        var week: [WeekDay] = []
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        guard let startOfWeek = weekForDate?.start else {
            return []
        }
        
        
        (0..<7).forEach { index in
            if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                week.append(.init(date: weekDay))
            }
        }
        
        return week
        
    }
    
    
    
    /// Creation of next week based on current weeks date
    ///
    func createNextWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfLastDate = calendar.startOfDay(for: self)
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
            return []
        }
                return fetchweek(nextDate)
    }
    
    
    func createPreviousWeek() -> [WeekDay] {
        let calendar = Calendar.current
        let startOfFirstDate = calendar.startOfDay(for: self)
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else{
            
            return []
        }
                return fetchweek(previousDate)
    }
    
    struct WeekDay: Identifiable {
        var id: UUID = .init()
        var date: Date
    }
}
