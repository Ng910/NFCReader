//
//  MainStore.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/02.
//

import UIKit
import ComposableArchitecture

@Reducer
struct Main {
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        
        @CasePathable
        enum ViewAction {
            case onApear
            case onLoad
            case readButtonTapped
        }
        
        case view(ViewAction)
    }
    
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
        case .readButtonTapped:
            return .none
        }
    }
}
