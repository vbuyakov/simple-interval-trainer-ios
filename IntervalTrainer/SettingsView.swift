import SwiftUI

struct SettingsView: View {
    @AppStorage("rounds") private var rounds: Int = 6
    @AppStorage("workDuration") private var workDuration: Int = 4
    @AppStorage("restDuration") private var restDuration: Int = 8
    @AppStorage("vibrationEnabled") private var vibrationEnabled: Bool = true
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    
    @AppStorage("workColorHex") private var workColorHex: String = "#FF0000"
    @State private var workColor: Color = Color.red

    @AppStorage("restColorHex") private var restColorHex: String = "#00FF00"
    @State private var restColor: Color = Color.green

    @AppStorage("workVibrationCount") private var workVibrationCount: Int = 1
    @AppStorage("restVibrationCount") private var restVibrationCount: Int = 1


    let availableColors: [Color] = [
        Color(hex: "#FF0000"), // Red
        Color(hex: "#00FF00"), // Green
        Color(hex: "#0000FF"), // Blue
        Color(hex: "#FFA500"), // Orange
        Color(hex: "#800080")  // Purple
    ]
    
    init() {
        _workColor = State(initialValue: Color(hex: UserDefaults.standard.string(forKey: "workColorHex") ?? "#FF0000"))
        _restColor = State(initialValue: Color(hex: UserDefaults.standard.string(forKey: "restColorHex") ?? "#00FF00"))
    }


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("workout_parameters".localized)) {
                    Stepper("\("rounds".localized): \(rounds)", value: $rounds, in: 1...20)

                    VStack(alignment: .leading) {
                        Text("run_duration".localized)
                        DurationPicker(totalSeconds: $workDuration)
                    }

                    VStack(alignment: .leading) {
                        Text("rest_duration".localized)
                        DurationPicker(totalSeconds: $restDuration)
                    }
                }
                
                Section {
                    NavigationLink(destination: WorkoutView(viewModel: IntervalViewModel())) {
                        Label {
                            
                            Text("start_workout".localized)
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                        }
                        icon: {
                            Image(systemName: "figure.run")
                                .foregroundColor(Color(.magenta))
                        }
                        
                    }
                }
                //

                Section(header: Text("colors".localized)) {
                    ColorPicker("work_color".localized, selection: $workColor)
                        .onChange(of: workColor) { newValue in
                            workColorHex = newValue.toHex()
                        }

                        
                        
                    ColorPicker("rest_color".localized, selection: $restColor)
                        .onChange(of: restColor) { newValue in
                            restColorHex = newValue.toHex()
                        }

                }

                Section(header: Text("options".localized)) {
                    Toggle("vibration".localized, isOn: $vibrationEnabled)
                    if vibrationEnabled {
                        Section() {
                            Stepper("work_vibrations".localized + ": \(workVibrationCount)",
                                    value: $workVibrationCount,
                                    in: 1...6)
                            
                            Stepper("rest_vibrations".localized + ": \(restVibrationCount)",
                                    value: $restVibrationCount,
                                    in: 1...6)
                        }
                    }
                    Toggle("sound".localized, isOn: $soundEnabled)
                }

                
            }
            .navigationTitle("intervals".localized)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}


#Preview {
    SettingsView()
}
