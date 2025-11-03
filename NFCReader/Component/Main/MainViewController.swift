//
//  MainViewController.swift
//  NFCReader
//
//  Created by 長岡巧敏 on 2025/11/02.
//

import UIKit
import ComposableArchitecture
import Combine
import Anchorage
import CombineCocoa
import CoreNFC

class MainViewController: UIViewController, NFCTagReaderSessionDelegate {

    // MARK: - TCA
    private let store: StoreOf<Main>
    private let viewStore: ViewStoreOf<Main>
    private var cancellables: Set<AnyCancellable> = []
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ICカードを読み取ってください"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    let guideImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "NFCReader")
        return image
    }()
    
    let readButton: UIButton = {
        let button = UIButton()
        button.setTitle("読み取る", for: .normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor.buttonColor
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
        
        view.addSubview(guideImage)
        guideImage.topAnchor == titleLabel.bottomAnchor + 32
        guideImage.leftAnchor == view.leftAnchor + 24
        guideImage.rightAnchor == view.rightAnchor - 24
        
        view.addSubview(readButton)
        readButton.topAnchor >= guideImage.bottomAnchor + 32
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
                guard let self else { return }
                self.viewStore.send(.view(.readButtonTapped(self)))
            }
            .store(in: &cancellables)
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("tagReaderSessionDidBecomeActive(_:)")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("tagReaderSession(_:didDetect:)")
        DispatchQueue.main.async {
            self.viewStore.send(.view(.readSuccess(session, tags)))
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        let readerError = error as! NFCReaderError
        print(readerError.code, readerError.localizedDescription)
    }
}
