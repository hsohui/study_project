// MyWidget.swift
// 위젯 구현: 입력된 텍스트를 표시

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "플레이스홀더")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: UserDefaults(suiteName: "group.com.example.studyproject")?.string(forKey: "widgetText") ?? "기본 텍스트")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, text: UserDefaults(suiteName: "group.com.example.studyproject")?.string(forKey: "widgetText") ?? "기본 텍스트")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let text: String
}

struct MyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.text)
            .font(.title)
            .padding()
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
        .description("사용자 정의 텍스트를 표시하는 위젯입니다.")
    }
}

struct MyWidget_Previews: PreviewProvider {
    static var previews: some View {
        MyWidgetEntryView(entry: SimpleEntry(date: Date(), text: "샘플 텍스트"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}