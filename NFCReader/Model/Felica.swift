//
//  Felica.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/03.
//

struct Felica{
    var historys: [HistoryDetail]
    
    struct HistoryDetail {
        var year: String
        var month: String
        var day: String
        var entry: String
        var out: String
        var balance: Int
    }
}

extension Felica.HistoryDetail {
    init(yaer: String, month: String, day: String, entry: String, out: String, balance: Int) {
        self.year = yaer
        self.month = month
        self.day = day
        self.entry = entry
        self.out = out
        self.balance = balance
    }
}


extension Felica {
    static let emptyHistroy = Felica(historys: [])
}

extension Felica.HistoryDetail {
    static let emptyHistroyDetail = Felica.HistoryDetail(year: "", month: "", day: "", entry: "", out: "", balance: 0)
}
