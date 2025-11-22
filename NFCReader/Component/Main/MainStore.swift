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
        var felica: Felica? = nil
    }
    
    enum Action {
        @CasePathable
        enum ViewAction {
            case onApear
            case onLoad
            case readButtonTapped(NFCTagReaderSessionDelegate)
            case readSuccess(NFCTagReaderSession, [NFCTag])
        }
        case readFelicaResult(Result<Felica, Error>)
        case view(ViewAction)
    }
    
    @Dependency(\.nfcClient)
    var nfcClient: NFCClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return viewAction(state: &state, action: action)
                
            case let .readFelicaResult(.success(result)):
                state.felica = result
                print(state.felica ?? "nil")
                return .none
                
            case .readFelicaResult(.failure):
                return .none
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
            return .run { [weak delegate] _ in
                guard let delegate else { return }
                await nfcClient.NFCSessionStart(delegate)
            }
            
        case let .readSuccess(session, tags):
            return .run { send in
                let result = await nfcClient.NFCSessionReaded(session, tags)
                await send(.readFelicaResult(result))
            }
        }
    }
}
