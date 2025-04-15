import SwiftUI

struct DurationPicker: View {
    @Binding var totalSeconds: Int

    private let minutes = Array(0...59)
    private let seconds = Array(0...59)

    var body: some View {
        HStack(spacing: 0) {
            Picker(selection: minutesBinding, label: Text("minutes".localized)) {
                ForEach(minutes, id: \.self) { value in
                    Text("\(value) \(Text("min".localized))")
                }
            }
            .frame(width: 100)
            .clipped()
            .compositingGroup()

            Picker(selection: secondsBinding, label: Text("seconds".localized)) {
                ForEach(seconds, id: \.self) { value in
                    Text("\(value) \(Text("sec".localized))")
                }
            }
            .frame(width: 100)
            .clipped()
            .compositingGroup()
        }
        .pickerStyle(.wheel)
    }

    private var minutesBinding: Binding<Int> {
        Binding {
            totalSeconds / 60
        } set: { newValue in
            totalSeconds = newValue * 60 + totalSeconds % 60
        }
    }

    private var secondsBinding: Binding<Int> {
        Binding {
            totalSeconds % 60
        } set: { newValue in
            totalSeconds = (totalSeconds / 60) * 60 + newValue
        }
    }
}

#Preview {
    DurationPicker(totalSeconds: .constant(75))
}
