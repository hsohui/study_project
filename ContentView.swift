// ContentView.swift
// 메인 앱 뷰: 텍스트 입력과 저장 기능

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var dailyTexts: [String: [String]] = [:]

    private let appGroup = "group.com.example.studyproject"
    private let dailyTextsKey = "dailyTexts"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("일별 텍스트 입력 (잔디밭 뷰)")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("입력할 텍스트")
                        .font(.headline)

                    TextField("텍스트 입력", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 4)

                    Button(action: saveText) {
                        Text("저장")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Text("선택된 날짜 \(formatDate(selectedDate))에 입력된 텍스트")
                    .font(.headline)
                    .padding(.horizontal)

                if selectedDateTexts.isEmpty {
                    Text("입력된 텍스트가 없습니다.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                } else {
                    VStack(alignment: .leading) {
                        ForEach(selectedDateTexts.indices, id: \ .self) { idx in
                            Text("\(idx + 1). \(selectedDateTexts[idx])")
                                .padding(.vertical, 2)
                        }
                    }
                    .padding(.horizontal)
                }

                Text("지난 30일 빈도")
                    .font(.headline)
                    .padding(.horizontal)

                contributionGrid
                    .padding(.horizontal)
            }
        }
        .onAppear(perform: loadDailyTexts)
    }

    private var selectedDateTexts: [String] {
        dailyTexts[dateKey(from: selectedDate)] ?? []
    }

    private var contributionGrid: some View {
        let cells = lastNDays(30)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(cells, id: \ .self) { date in
                let count = dailyTexts[dateKey(from: date)]?.count ?? 0
                Rectangle()
                    .foregroundColor(colorFor(count: count))
                    .frame(height: 20)
                    .cornerRadius(3)
                    .overlay(
                        Group {
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }
                    )
                    .accessibilityLabel("\(formatDate(date)): \(count)회")
            }
        }
    }

    private func saveText() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var mutable = dailyTexts
        let key = dateKey(from: selectedDate)
        var list = mutable[key] ?? []
        list.append(trimmed)
        mutable[key] = list
        dailyTexts = mutable
        inputText = ""

        saveDailyTexts(mutable)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func loadDailyTexts() {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: dailyTextsKey) else {
            dailyTexts = [:]
            return
        }

        if let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            dailyTexts = decoded
        } else {
            dailyTexts = [:]
        }
    }

    private func saveDailyTexts(_ texts: [String: [String]]) {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let encoded = try? JSONEncoder().encode(texts) else { return }

        defaults.setValue(encoded, forKey: dailyTextsKey)
    }

    private func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func lastNDays(_ n: Int) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<n).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    private func colorFor(count: Int) -> Color {
        switch min(max(count, 0), 5) {
        case 0: return Color.gray.opacity(0.2)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        case 4: return Color.green.opacity(0.85)
        default: return Color.green
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}