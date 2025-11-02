//
//  MainViewController.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/02.
//

import UIKit
import ComposableArchitecture
import Combine
import CombineCocoa
import Anchorage

class MainViewController: UIViewController {

    // MARK: - TCA
    private let store: StoreOf<Main>
    private let viewStore: ViewStoreOf<Main>
    private var cancellables: Set<AnyCancellable> = []
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "NFC Reader"
        label.textAlignment = .center
        return label
    }()
    
    let readButton: UIButton = {
        let button = UIButton()
        button.setTitle("読み取る", for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = .blue
        return button
    }()
    
    init(store: StoreOf<Main>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupLaout()
        setupBinding()
    }
    
    private func setupLaout() {
        view.addSubview(titleLabel)
        
        titleLabel.topAnchor == view.safeAreaLayoutGuide.topAnchor + 32
        titleLabel.leftAnchor == view.leftAnchor + 24
        titleLabel.rightAnchor == view.rightAnchor - 24
        
        view.addSubview(readButton)
        readButton.topAnchor >= titleLabel.bottomAnchor + 32
        readButton.leftAnchor == view.leftAnchor + 24
        readButton.rightAnchor == view.rightAnchor - 24
        readButton.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor - 20
        readButton.heightAnchor == 52
        view.backgroundColor = .white
    }

    private func setupBinding() {
        readButton
            .tapPublisher
            .sink { [weak self] _ in
                self?.viewStore.send(.view(.readButtonTapped))
            }
            .store(in: &cancellables)
    }

}
