//
//  NFCClientLiveKey.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/03.
//

import Dependencies

extension NFCClient: DependencyKey {
    static let liveValue = Self(
        NFCSessionStart: {
            
        }
    )
}
