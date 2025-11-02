//
//  ViewController.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/02.
//

import UIKit
import Combine
import ComposableArchitecture

class SplashViewController: UIViewController {
    
    // MARK: - TCA
    private let store: StoreOf<Splash>
    private let viewStore: ViewStoreOf<Splash>
    private var cancellables: Set<AnyCancellable> = []
    
    let splashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "SplashIcon")
        return imageView
    }()
    
    init(store: StoreOf<Splash>) {
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
        viewStore.send(.view(.onLoad))
        setupLayout()
        setupBinding()
    }
    
    private func setupLayout() {
        view.addSubview(splashImageView)
        splashImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashImageView.widthAnchor.constraint(equalToConstant: 200),
            splashImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupBinding() {
        
    }
}

