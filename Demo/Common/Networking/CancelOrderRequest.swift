//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal struct CancelOrderRequest: Request {

    internal typealias ResponseType = CancelOrderResponse

    internal let order: PartialPaymentOrder

    internal let path = "orders/cancel"

    internal var counter: UInt = 0

    internal var method: HTTPMethod = .post

    internal var headers: [String: String] = [:]

    internal var queryParameters: [URLQueryItem] = []

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(order, forKey: .order)
        try container.encode(Configuration.merchantAccount, forKey: .merchantAccount)
    }

    private enum CodingKeys: String, CodingKey {
        case order
        case merchantAccount
    }
}

internal struct CancelOrderResponse: Response {

    internal let resultCode: PaymentsResponse.ResultCode

    internal let pspReference: String
}
