import Foundation
import Testing
@testable import OnePanel

struct WindowFrameStateTests {
    @Test
    func serializesAndDeserializesWithStableValues() throws {
        let original = WindowFrameState(x: 12, y: 34, width: 960, height: 720)
        let data = try JSONEncoder().encode(original)

        let decoded = try JSONDecoder().decode(WindowFrameState.self, from: data)

        #expect(decoded == original)
    }
}
