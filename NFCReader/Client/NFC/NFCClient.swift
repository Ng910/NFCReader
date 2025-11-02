//
//  NFCClient.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/03.
//

import Dependencies

struct NFCClient {
    var NFCSessionStart: () -> Void = { }
}

extension DependencyValues {
    var lureClient: NFCClient {
        get { self[NFCClient.self] }
        set { self[NFCClient.self] = newValue }
      }
}
