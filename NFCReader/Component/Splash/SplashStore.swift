//
//  SplashStore.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/02.
//
import UIKit
import ComposableArchitecture

@Reducer
struct Splash {
    @ObservableState
    struct State: Equatable {
        var mainState: Main.State? = nil
    }
    
    enum Action: Equatable {
        
        @CasePathable
        enum ViewAction {
            case onApear
            case onLoad
            case showMain
        }
        
        case view(ViewAction)
        case mainAction(Main.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(action):
                return viewAction(state: &state, action: action)
            case .mainAction:
                return .none
            }
        }
        .ifLet(\.mainState, action: \.mainAction) {
            Main()
        }
    }
    
    private func viewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onApear:
            return .none
        case .onLoad:
            return .run { send in
                try await Task.sleep(nanoseconds: 1_500_000_000)
                await send(.view(.showMain))
            }
        case .showMain:
            state.mainState = Main.State()
            return .none
        }
    }
}
