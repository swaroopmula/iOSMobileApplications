
import UIKit

class CardsVC: UIViewController {

    @IBOutlet var cardImages: UIImageView!
    var cards: [UIImage] = Cards.allcards
    var timer: Timer!
    
    override func viewDidLoad() {
        startTimer()
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showRandomImage), userInfo: nil, repeats: true)
    }
    
    
    @objc func showRandomImage() {
        cardImages.image = cards.randomElement() ?? UIImage(named: "AS")
    }

    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        timer.invalidate()
    }
    
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        timer.invalidate()
        startTimer()
    }
}

