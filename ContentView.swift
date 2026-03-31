// ContentView.swift
// 메인 앱 뷰: 텍스트 입력과 저장 기능

import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @AppStorage("widgetText") private var widgetText: String = "기본 텍스트"

    var body: some View {
        VStack {
            Text("위젯에 표시할 텍스트를 입력하세요")
                .font(.headline)
                .padding()

            TextField("텍스트 입력", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                widgetText = inputText
            }) {
                Text("저장")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Text("현재 위젯 텍스트: \(widgetText)")
                .padding()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}