import SwiftUI
import Firebase
import AAInfographics

struct AAChartKitView: UIViewRepresentable {
    var chartModel: AAChartModel

    func makeUIView(context: Context) -> AAChartView {
        let chartView = AAChartView()
        chartView.aa_drawChartWithChartModel(chartModel)
        chartView.isClearBackgroundColor = true // Try making the chart background clear
        return chartView
    }

    func updateUIView(_ uiView: AAChartView, context: Context) {
        // Redraw chart with current data
        uiView.aa_refreshChartWholeContentWithChartModel(chartModel)
    }
}
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var selectedInterval = Interval.day
    @State private var aaChartModel: AAChartModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                .padding()
                .background(Color.pastelGreen)

                // Interval Picker
                Picker("Select Interval", selection: $selectedInterval) {
                    Text("Day").tag(Interval.day)
                    Text("Week").tag(Interval.week)
                    Text("Month").tag(Interval.month)
                    Text("Year").tag(Interval.year)
                }
                .pickerStyle(SegmentedPickerStyle())

                // Bar chart
                if let chartModel = self.aaChartModel {
                    AAChartKitView(chartModel: chartModel)
                        .frame(height: 300)  // Specify a frame height for the chart view
                        .background(Color.pastelGreen)
                } else {
                    Text("No data available")
                }

                Spacer()

                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15)
                }
            }
            .padding()
        }
        .background(Color.pastelGreen.edgesIgnoringSafeArea(.all)) // Apply the pastel green to the entire ScrollView
        .onAppear {
            authViewModel.getStudySessionData(interval: selectedInterval) { sessions in
                // map sessions to AAChartModel
                let chartData = sessions.map { Double($0.value) }
                let chartCategories = sessions.map { $0.key }
                self.aaChartModel = AAChartModel()
                    .chartType(.column)
                    .animationType(.easeOutBack)
                    .title("Study Sessions")
                    .subtitle("Duration of study sessions")
                    .dataLabelsEnabled(true)
                    .tooltipValueSuffix(" minutes")
                    .categories(chartCategories)
                    .backgroundColor("#CAECD9") // Set chart background to pastel green (Hex color)
                    .series([
                        AASeriesElement()
                            .name("Study Duration")
                            .data(chartData)
                            .toDic()!
                    ])
            }
        }
    }
}

extension Color {
    static let pastelGreen = Color(red: 202 / 255, green: 220 / 255, blue: 157 / 255)
}
