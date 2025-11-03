//
//  MainStore.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/02.
//

import UIKit
import ComposableArchitecture
import Dependencies
import CoreNFC

@Reducer
struct Main {
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case onApear
            case onLoad
            case readButtonTapped(NFCTagReaderSessionDelegate)
            case readSuccess(NFCTagReaderSession, [NFCTag])
        }
        
        case view(ViewAction)
    }
    
    @Dependency(\.nfcClient)
    var nfcClient: NFCClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return viewAction(state: &state, action: action)
            }
        }
    }
    
    private func viewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onApear:
            return .none
        case .onLoad:
            return .none
        case let .readButtonTapped(delegate):
            return .run { _ in
                await nfcClient.NFCSessionStart(delegate)
            }
        case let .readSuccess(session, tags):
            return .run { _ in
                await nfcClient.NFCSessionReaded(session, tags)
            }
        }
    }
}
