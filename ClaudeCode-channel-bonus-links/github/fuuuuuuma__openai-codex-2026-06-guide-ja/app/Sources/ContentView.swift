// ContentView.swift — 最初の画面（テンプレート）
// まずはこの「ようこそ画面」が表示されることを確認し、そこから一緒に育てていきます。
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "swift")
                .font(.system(size: 48))
            Text("{{APP_NAME}} へようこそ")
                .font(.title2)
                .bold()
            Text("ここから AI と一緒に作っていきます。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
