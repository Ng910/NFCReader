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
            session?.alertMessage = "デバイスにカードをかざしてください"
            session?.begin()
        },
        NFCSessionReaded: { session, tags in
            
            let tag = tags.first!
            session.connect(to: tag) { (error) in
                if let error = error {
                    session.invalidate(errorMessage: error.localizedDescription)
                    return
                }
                
                guard case NFCTag.feliCa(let feliCaTag) = tag else {
                    session.invalidate(errorMessage: "読み取りできないカードです")
                    return
                }
                
                session.alertMessage = "カードを読み取っています…"
                
                let idm = feliCaTag.currentIDm.map { String(format: "%.2hhx", $0) }.joined()
                print("IDm:", idm)
                
                /// FeliCa サービスコード
                let serviceCode = Data([0x00, 0x8B].reversed())
                
                /// ブロック数
                let blocks = 1
                let blockList = (0..<blocks).map { (block) -> Data in
                    Data([0x80, UInt8(block)])
                }
                
                feliCaTag.readWithoutEncryption(serviceCodeList: [serviceCode], blockList: blockList) { (status1, status2, blockData, error) in
                    if let error = error {
                        session.invalidate(errorMessage: error.localizedDescription)
                        return
                    }
                    
                    guard status1 == 0x00, status2 == 0x00 else {
                        print("ステータスフラグがエラーを示しています", status1, status2)
                        session.invalidate(errorMessage: "ステータスフラグがエラーを示しています s1:\(status1), s2:\(status2)")
                        return
                    }
                    
                    blockData.forEach { data in
                        print("年: ", Int(data[4] >> 1) + 2000)
                        print("月: ", ((data[4] & 1) == 1 ? 8 : 0) + Int(data[5] >> 5))
                        print("日: ", Int(data[5] & 0x1f))
                        print("入場駅コード: ", data[6...7].map { String(format: "%02x", $0) }.joined())
                        print("出場駅コード: ", data[8...9].map { String(format: "%02x", $0) }.joined())
                        print("入場地域コード: ", String(Int(data[15] >> 6), radix: 16))
                        print("出場地域コード: ", String(Int((data[15] & 0x30) >> 4), radix: 16))
                        print("残高: ", Int(data[10]) + Int(data[11]) << 8)
                    }
                    
                    let data = blockData.first!
                    let balance = data.toIntReversed(11, 12)

                    print(data as NSData)
                    print("残高: ¥\(balance)")
                    session.alertMessage = "残高: ¥\(balance)"
                    session.invalidate()
                }
            }
        }
    )
}

extension Data {
    func toIntReversed(_ startIndex: Int, _ endIndex: Int) -> Int {
        var s = 0
        for (n, i) in (startIndex...endIndex).enumerated() {
            s += Int(self[i]) << (n * 8)
        }
        return s
    }
}
