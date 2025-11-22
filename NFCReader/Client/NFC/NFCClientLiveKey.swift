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
            guard let tag = tags.first, case let .feliCa(felicaTag) = tag else { return }
            
            session.connect(to: tag) { error in
                if let error = error {
                    print("Error: ", error)
                    return
                }
                
                let serviceCode = Data([0x09, 0x0f].reversed())
                felicaTag.requestService(nodeCodeList: [serviceCode]) { nodes, error in
                    if let error = error {
                        print("Error: ", error)
                        return
                    }
                    
                    guard let data = nodes.first, data != Data([0xff, 0xff]) else {
                        print("サービスが存在しない")
                        return
                    }
                    
                    let blockList = (0..<12).map { Data([0x80, UInt8($0)]) }
                    felicaTag.readWithoutEncryption(serviceCodeList: [serviceCode], blockList: blockList)
                    { status1, status2, dataList, error in
                        if let error = error {
                            print("Error: ", error)
                            return
                        }
                        guard status1 == 0x00, status2 == 0x00 else {
                            print("ステータスフラグエラー: ", status1, " / ", status2)
                            return
                        }
                        session.invalidate()
                        
                        dataList.forEach { data in
                            let year: String = String(Int(data[4] >> 1) + 2000)
                            let month: String = String(((data[4] & 1) == 1 ? 8 : 0) + Int(data[5] >> 5))
                            let day: String = String(Int(data[5] & 0x1f))
                            
                            let date: String = year + "/" + month + "/" + day
                            let balance = Int(data[10]) + Int(data[11]) << 8
                            print("利用日: ",date)
                            print("残高: ", balance)
//                            print("入場駅コード: ", data[6...7].map { String(format: "%02x", $0) }.joined())
//                            print("出場駅コード: ", data[8...9].map { String(format: "%02x", $0) }.joined())
//                            print("入場地域コード: ", String(Int(data[15] >> 6), radix: 16))
//                            print("出場地域コード: ", String(Int((data[15] & 0x30) >> 4), radix: 16))
                        }
                    }
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
