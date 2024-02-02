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
    @State private var newUsername: String = ""
    @State private var showingEditUsernameView: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("Username:")
                            .foregroundColor(.white)
                        Text(authViewModel.username ?? "")
                            .foregroundColor(.white)
                            .font(.title) // Bigger font for the username
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.showingEditUsernameView = true
                    }) {
                        Text("Edit")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.pastelGreen)

                // Add the AAChartKitView here, only if aaChartModel is not nil
                if let chartModel = self.aaChartModel {
                    AAChartKitView(chartModel: chartModel)
                        .frame(height: 300) // Set a proper frame according to your needs
                        .padding()
                }

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
                
                Text(errorMessage) // Display the error message
                    .foregroundColor(.red)
                    .padding()
            }
            .padding()
        }
        .background(Color.pastelGreen.edgesIgnoringSafeArea(.all)) // Apply the pastel green to the entire ScrollView
        .onAppear {
            authViewModel.getUsername()
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
        .sheet(isPresented: $showingEditUsernameView) {
                VStack {
                    Text("Edit Username")
                        .font(.headline)
                    TextField("Username", text: $newUsername)
                        .padding()
                    Button("Save", action: {
                        authViewModel.updateUsername(newUsername: newUsername) { error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                            } else {
                                authViewModel.getUsername() // fetch the updated username
                                showingEditUsernameView = false
                                errorMessage = ""
                            }
                        }
                    })
                    .padding()
                }
                .padding()
            }
        }
}

extension Color {
    static let pastelGreen = Color(red: 188/255, green: 224/255, blue: 247/255)
}


