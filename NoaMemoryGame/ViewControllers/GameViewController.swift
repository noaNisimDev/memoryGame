//
//  GameViewController.swift
//  NoaMemoryGame
//

import UIKit
import CoreLocation


class GameViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    let game = MemoryGame()
    var cards = [Card]()
    var firstIndex:IndexPath?
    var secondIndext:IndexPath?
    var moves:Int = 0
    var timerCounter:Int = 0
    var lng: Double = 0.0
    var lat: Double = 0.0
    var timer:Timer?
    var locationManager = CLLocationManager()
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.cards = Utils.getCardsArray()
        self.startGame()
    }
    
    @objc func timerTick() { // every 1 sec
        let hours = timerCounter / 3600
        let minutes = timerCounter / 60 % 60
        let seconds = timerCounter % 60
        timerLabel.text = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        timerCounter += 1
    }
    
    func startGame() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        cards = game.newGame(cardsArray: self.cards)
        movesLabel.text = "Moves: \(moves)"
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if game.isPlaying {
            resetGame()
        }
    }
    
    func resetGame() {
        game.restartGame()
        moves = 0
        timerCounter = 0
    }
    
}

extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CardCell
        cell.showCard(false, animted: false)
        
        guard let card = game.cardAtIndex(indexPath.item) else { return cell }
        cell.card = card
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CardCell
        
        if cell.shown { return }
        game.didSelectCard(cell.card)
        moves += 1
        movesLabel.text = "Moves: \(moves / 2)"
        collectionView.deselectItem(at: indexPath, animated:true)
    }
}

extension GameViewController: MemoryGameProtocol {
    
    func memoryGameDidStart(_ game: MemoryGame) {
        collectionView.reloadData()
    }
    
    func memoryGame(_ game: MemoryGame, showCards cards: [Card]) {
        for card in cards {
            guard let index = game.indexForCard(card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! CardCell
            cell.showCard(true, animted: true)
        }
    }
    
    func memoryGame(_ game: MemoryGame, hideCards cards: [Card]) {
        for card in cards {
            guard let index = game.indexForCard(card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! CardCell
            cell.showCard(false, animted: true)
        }
    }
    
    func memoryGameDidEnd(_ game: MemoryGame) {
        showScoreDialog()
        timer?.invalidate() // Stop timer
        
    }
    func showEndGamedialog(){
        let alertController = UIAlertController(
            title: "Good Job!",
            message: "Want To play again?",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Nope", style: .cancel) { [weak self] (action) in
            self!.dismiss(animated: true, completion: nil)
        }
        let playAgainAction = UIAlertAction(title: "Yalla!", style: .default) { [weak self] (action) in
            self?.resetGame()
            self?.startGame()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(playAgainAction)
        
        present(alertController, animated: true) { }
    }
    func showScoreDialog() {
        let dialog = UIAlertController(title: "Part of history!", message: "Please enter your name:", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { UIAlertAction in
            let name = dialog.textFields![0].text
            print("lng: \(self.lng) lat: \(self.lat)")
            let score = Score(id: UUID().uuidString, name: name ?? "User", time: self.timerCounter, lng: self.lng, lat: self.lat)
            Utils.saveScore(score: score)
            self.showEndGamedialog()
        }
        submitAction.isEnabled = false
        dialog.addTextField { textField in
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                let textCounter = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCounter > 0
                submitAction.isEnabled = textIsNotEmpty
            }
        }
        
        dialog.addAction(submitAction)
        present(dialog, animated: true, completion: nil)
        
    }
}


extension GameViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = Int(view.frame.width) - 50
        let widthPerItem = width / 5
        var res = CGSize(width: widthPerItem, height: widthPerItem)
        res.height = (collectionViewLayout.collectionView!.visibleSize.height / 5 - CGFloat(25))
        return res
    }
}


extension GameViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else {
            return
        }
        lng = last.coordinate.longitude
        lat = last.coordinate.latitude
    }
}
