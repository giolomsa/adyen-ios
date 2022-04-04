//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// API Client to handle `Session` related requests.
/// All session related responses containing `sessionData` require updating the session data of the main `session` property,
/// which is passed as a weak reference to this class.
internal final class SessionAPIClient: APIClientProtocol {
    
    private let apiClient: APIClientProtocol
    
    private weak var session: Session?
    
    internal init(apiClient: APIClientProtocol, session: Session) {
        self.apiClient = apiClient
        self.session = session
    }
    
    internal func perform<R>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) where R: Request {
        apiClient.perform(request) { [weak self] result in
            if let response = try? result.get() as? SessionResponse {
                self?.session?.sessionContext.data = response.sessionData
            }
            completionHandler(result)
        }
    }
}