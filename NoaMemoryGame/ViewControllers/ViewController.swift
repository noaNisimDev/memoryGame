//
//  ViewController.swift
//  NoaMemoryGame
//


import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapButton(){
        let vc = storyboard?.instantiateViewController(identifier: "game_screen") as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)	
    }
    
    @IBAction func didTapButtonTopTen(){
        let vc = storyboard?.instantiateViewController(identifier: "topten") as! TopTen
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }


}

