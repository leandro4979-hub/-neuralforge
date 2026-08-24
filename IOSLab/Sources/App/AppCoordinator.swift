import Foundation
import Core

/// Coordinates app navigation and flow.
public final class AppCoordinator: ObservableObject {
    private let logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
}
