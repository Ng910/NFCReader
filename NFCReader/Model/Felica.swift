//
//  Felica.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/03.
//

struct Felica{
    var historys: [HistoryDetail]
    
    struct HistoryDetail {
        var useDate: String
        var balance: Int
    }
}

extension Felica {
    static let emptyHistroy = Felica(historys: [])
}

extension Felica.HistoryDetail {
    static let emptyHistroyDetail = Felica.HistoryDetail(useDate: "", balance: 0)
}
