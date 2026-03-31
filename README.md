# study_project

이 프로젝트는 iOS 앱과 위젯을 포함합니다. 앱에서 텍스트를 입력하면 위젯에 그 텍스트가 표시됩니다.

## 파일 설명
- `ContentView.swift`: 메인 앱의 UI. 텍스트 입력 필드와 저장 버튼.
- `MyWidget.swift`: 위젯 구현. 앱에서 저장된 텍스트를 표시.

## 설정 방법
1. Xcode에서 새 iOS 프로젝트를 만드세요 (SwiftUI).
2. 위 파일들을 프로젝트에 추가하세요.
3. App Group을 설정하세요: Capabilities > App Groups > group.com.example.studyproject
4. 위젯 타겟도 같은 App Group을 사용하세요.
5. 앱을 빌드하고 실행하세요.
6. 홈 화면에 위젯을 추가하세요.

## 사용법
- 앱을 열고 텍스트를 입력한 후 저장 버튼을 누르세요.
- 위젯에 텍스트가 표시됩니다.