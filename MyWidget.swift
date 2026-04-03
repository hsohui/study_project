// MyWidget.swift
// 위젯 구현: 일별 입력 횟수를 잔디밭 스타일로 표시

import WidgetKit
import SwiftUI
import Intents

private let appGroup = "group.com.example.studyproject"
private let dailyTextsKey = "dailyTexts"

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dayCounts: [:])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), dayCounts: loadDayCounts()))
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [SimpleEntry(date: Date(), dayCounts: loadDayCounts())]
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadDayCounts() -> [String: Int] {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: dailyTextsKey),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }
        var counts: [String: Int] = [:]
        decoded.forEach { counts[$0] = min($1.count, 5) }
        return counts
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dayCounts: [String: Int]
}

struct MyWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("오늘까지 잔디촌")
                .font(.system(.caption, design: .rounded))
                .bold()

            contributionGrid
                .frame(maxWidth: .infinity)

            HStack {
                Text("1~5단계")
                    .font(.system(.caption2))
                    .foregroundColor(.secondary)
                Spacer()
                Text("업데이트: \(timeString(entry.date))")
                    .font(.system(.caption2))
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
    }

    private var contributionGrid: some View {
        let days = lastNDays(35)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(days, id: \ .self) { date in
                let key = dateKey(from: date)
                let count = entry.dayCounts[key] ?? 0
                Rectangle()
                    .foregroundColor(colorFor(count: count))
                    .cornerRadius(2)
                    .frame(height: 12)
                    .overlay(
                        Group {
                            if count > 0 {
                                Text("")
                            }
                        }
                    )
                    .accessibilityLabel("\(dateLabel(date)): \(count)회")
            }
        }
    }

    private func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }

    private func dateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
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

@main
struct MyWidget: Widget {
    let kind: String = "MyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("내 위젯")
        .description("잔디밭 단계로 하루 입력 횟수를 보여주는 위젯입니다.")
    }
}

struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyWidgetEntryView(entry: SimpleEntry(date: Date(), dayCounts: ["2026-04-01":1, "2026-04-02":3, "2026-04-03":5]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}