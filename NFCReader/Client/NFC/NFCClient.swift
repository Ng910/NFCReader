//
//  NFCClient.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/03.
//

import Dependencies
import CoreNFC

struct NFCClient {
    var NFCSessionStart: ( _ delegate: NFCTagReaderSessionDelegate) -> Void = { delegate in }
}

extension DependencyValues {
    var nfcClient: NFCClient {
        get { self[NFCClient.self] }
        set { self[NFCClient.self] = newValue }
      }
}
