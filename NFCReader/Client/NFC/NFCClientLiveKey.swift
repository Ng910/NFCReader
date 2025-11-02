//
//  NFCClientLiveKey.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/03.
//

import Dependencies
import CoreNFC


extension NFCClient: DependencyKey {
    static let liveValue = Self(
        NFCSessionStart: { delegate in
            let session = NFCTagReaderSession(pollingOption: [.iso18092], delegate: delegate)
            session?.alertMessage = "カードを平らな面に置き、カードの下半分を隠すように iPhone をその上に置きます。"
            session?.begin()
        }
    )
}
