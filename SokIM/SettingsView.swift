import SwiftUI

/** 툴바 탭으로 나뉜 설정 화면 */
func makeSettingsViewController() -> NSViewController {
    let tabs = SettingsTabViewController()
    tabs.tabStyle = .toolbar
    tabs.addTabViewItem(settingsTab("일반", "gearshape", GeneralSettingsView()))
    tabs.addTabViewItem(settingsTab("정보", "info.circle", AboutSettingsView()))
    return tabs
}

/** 선택한 탭 이름을 창 제목으로 사용 */
private class SettingsTabViewController: NSTabViewController {
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.title = tabView.selectedTabViewItem?.label ?? ""
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        view.window?.title = tabViewItem?.label ?? ""
    }
}

private func settingsTab<Content: View>(_ label: String, _ symbol: String, _ view: Content) -> NSTabViewItem {
    let controller = NSHostingController(rootView: view)
    controller.sizingOptions = .preferredContentSize
    controller.title = label

    let item = NSTabViewItem(viewController: controller)
    item.label = label
    item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)
    return item
}

// MARK: - 일반

private struct GeneralSettingsView: View {
    @State private var rotateShortcuts = Preferences.rotateShortcuts
    @State private var graveOverWon = Preferences.graveOverWon
    @State private var debugMode = Preferences.debug

    var body: some View {
        Form {
            Section("한/A 전환") {
                Toggle("한/A (⇪)", isOn: rotateShortcut(.capsLock))
                Toggle("오른쪽 ⌘", isOn: rotateShortcut(.rightCommand))
                Toggle("오른쪽 ⌥", isOn: rotateShortcut(.rightOption))
                Toggle("⌘스페이스", isOn: rotateShortcut(.commandSpace))
                Toggle("⇧스페이스", isOn: rotateShortcut(.shiftSpace))
                Toggle("⌃스페이스", isOn: rotateShortcut(.controlSpace))
            }

            Section("기타") {
                Toggle("한글 입력 시 ₩ 대신 ` 입력", isOn: $graveOverWon)
                Toggle("디버그 모드", isOn: $debugMode)
            }
        }
        .formStyle(.grouped)
        .toggleStyle(.switch)
        .scrollDisabled(true)
        .frame(width: 420)
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: rotateShortcuts) { Preferences.rotateShortcuts = $0 }
        .onChange(of: graveOverWon) { Preferences.graveOverWon = $0 }
        .onChange(of: debugMode) { Preferences.debug = $0 }
    }

    private func rotateShortcut(_ type: RotateShortcutType) -> Binding<Bool> {
        Binding(
            get: { rotateShortcuts.contains(type) },
            set: { isOn in
                if isOn {
                    rotateShortcuts.insert(type)
                } else {
                    rotateShortcuts.remove(type)
                }
            }
        )
    }
}

// MARK: - 정보

private struct AboutSettingsView: View {
    private let version = Bundle.main.releaseVersionNumber ?? "0.0"
    private let build = Bundle.main.buildVersionNumber ?? "0"

    var body: some View {
        HStack(spacing: 24) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 128, height: 128)

            VStack(alignment: .leading, spacing: 6) {
                Text("속 입력기")
                    .font(.headline)
                Text("버전 \(version) (\(build))")
                Text("GPL-3.0 라이선스")
                Link("소스 코드 저장소", destination: URL(string: "https://github.com/kiding/SokIM")!)
                Link("최신 버전", destination: URL(string: "https://github.com/kiding/SokIM/releases")!)
            }
        }
        .padding(32)
        .frame(width: 420)
    }
}
