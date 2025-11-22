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
        NFCSessionReaded: { session, tags async -> Result<Felica, Error> in
            guard let tag = tags.first, case let .feliCa(felicaTag) = tag else {
                return .success(.emptyHistroy)
            }
            
            return await withCheckedContinuation { continuation in
                session.connect(to: tag) { error in
                    if let error = error {
                        continuation.resume(returning: .failure(error))
                        return
                    }
                    
                    let serviceCode = Data([0x09, 0x0f].reversed())
                    felicaTag.requestService(nodeCodeList: [serviceCode]) { nodes, error in
                        if let error = error {
                            continuation.resume(returning: .failure(error))
                            return
                        }
                        
                        guard let data = nodes.first, data != Data([0xff, 0xff]) else {
                            continuation.resume(returning: .success(.emptyHistroy))
                            return
                        }
                        
                        let blockList = (0..<12).map { Data([0x80, UInt8($0)]) }
                        felicaTag.readWithoutEncryption(serviceCodeList: [serviceCode], blockList: blockList)
                        { status1, status2, dataList, error in
                            if let error = error {
                                continuation.resume(returning: .failure(error))
                                return
                            }
                            guard status1 == 0x00, status2 == 0x00 else {
                                continuation.resume(returning: .failure(
                                    NSError(domain: "FelicaError", code: Int(status1), userInfo: nil)))
                                return
                            }
                            session.invalidate()
                            
                            var felicaHistory = Felica(historys: [])
                            dataList.forEach { data in
                                let year: String = String(Int(data[4] >> 1) + 2000)
                                let month: String = String(((data[4] & 1) == 1 ? 8 : 0) + Int(data[5] >> 5))
                                let day: String = String(Int(data[5] & 0x1f))
                                
                                let useDate: String = year + "/" + month + "/" + day
                                let balance = Int(data[10]) + Int(data[11]) << 8
                                let historyDetail = Felica.HistoryDetail(useDate: useDate, balance: balance)
                                felicaHistory.historys.append(historyDetail)
                            }
                            continuation.resume(returning: .success(felicaHistory))
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
