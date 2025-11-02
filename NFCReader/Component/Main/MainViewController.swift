//
//  MainViewController.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/02.
//

import UIKit
import ComposableArchitecture
import Combine

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
    }
    
    private func setupLaout() {
        view.addSubview(titleLabel)
        view.backgroundColor = .white
    }


}
