//
//  TopTen.swift
//  NoaMemoryGame
//


import Foundation
import UIKit
import MapKit

class TopTen: UIViewController {
    
    @IBOutlet weak var scoresTable: UITableView!
    @IBOutlet weak var map: MKMapView!
    var scores: [Score] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoresTable.delegate = self
        scoresTable.dataSource = self
        scores = Utils.getScores() as [Score]
        print("scores count \(scores.count)")
        
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension TopTen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Click on row \(indexPath)")
        if(indexPath.row < scores.count){
            let score = scores[indexPath.row]
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: score.lat, longitude: score.lng)
            annotation.title = "\(indexPath.row + 1). \(score.name)"
            map.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            map.setRegion(region, animated: true)
        }
        
    }
}

extension TopTen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if(indexPath.row < scores.count){
            let record = scores[indexPath.row]
            let time = record.time
            let hours = time / 3600
            let minutes = time / 60 % 60
            let seconds = time % 60
            cell.textLabel?.text = "\(indexPath.row + 1). \(record.name) - \(String(format: "%02i:%02i:%02i", hours, minutes, seconds))\nLocation: \(record.lng),\(record.lat)"
            cell.textLabel?.numberOfLines = 2
        }
        return cell
    }
}
