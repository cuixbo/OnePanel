import Testing
@testable import OnePanel

struct StatusMenuContentTests {
    @Test
    func showsOpenActionWhenPanelIsHidden() {
        let items = StatusMenuContent.makeItems(isPanelVisible: false)

        #expect(items.map(\.title) == ["打开 OnePanel", "设置", "退出 OnePanel"])
    }

    @Test
    func showsHideActionWhenPanelIsVisible() {
        let items = StatusMenuContent.makeItems(isPanelVisible: true)

        #expect(items.map(\.title) == ["隐藏 OnePanel", "设置", "退出 OnePanel"])
    }
}
