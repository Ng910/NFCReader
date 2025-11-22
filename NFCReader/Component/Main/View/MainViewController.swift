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
    private let tableView = UITableView()
    
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
        setupTableView()
        setupBinding()
        setupEvent()
    }
    
    private func setupLaout() {
        view.addSubview(titleLabel)
        view.backgroundColor = .white
        
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
        
        view.addSubview(tableView)
        tableView.topAnchor == titleLabel.bottomAnchor + 32
        tableView.leftAnchor == view.leftAnchor
        tableView.rightAnchor == view.rightAnchor
        tableView.bottomAnchor == readButton.topAnchor - 20
        
        tableView.isHidden = true
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
    
    private func setupEvent() {
        viewStore.publisher
            .map(\.felica)
            .removeDuplicates()
            .sink { [weak self] felica in
                guard let self = self else { return }

                if let felica = felica, !felica.historys.isEmpty {
                    // データあり → tableView を表示、guideImage を非表示
                    self.tableView.isHidden = false
                    self.guideImage.isHidden = true
                    self.tableView.reloadData()
                } else {
                    // データなし → tableView 非表示、guideImage を表示
                    self.tableView.isHidden = true
                    self.guideImage.isHidden = false
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - TableView
    private func setupTableView() {
        tableView.register(FelicaDetailCell.self, forCellReuseIdentifier: "FelicaDetailCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        DispatchQueue.main.async {
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.hiddnSplashOverlay()
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        DispatchQueue.main.async {
            self.viewStore.send(.view(.readSuccess(session, tags)))
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        let readerError = error as! NFCReaderError
        print(readerError.code, readerError.localizedDescription)
    }
}


// MARK: - UITableViewDataSource / Delegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewStore.felica?.historys.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FelicaDetailCell", for: indexPath) as? FelicaDetailCell,
              let history = viewStore.felica?.historys[indexPath.row]
        else { return UITableViewCell() }

        cell.date = history.useDate
        cell.balance = history.balance
        return cell
    }
}
