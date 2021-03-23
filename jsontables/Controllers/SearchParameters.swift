//
//  SearchParameters.swift
//  jsontables
//
//  Created by Robert Diamond on 3/22/21.
//

import UIKit

class SearchParametersController : UIViewController {
  var count : Int = 5
  var difficulty : Int = 1
  var delegate : SearchingProtocol?
  @IBOutlet weak var countLabel: UILabel!

  @IBOutlet weak var difficultyButtons: UISegmentedControl!
  @IBOutlet weak var numberOfStudies: UISlider!

  override func viewDidLoad() {
    super.viewDidLoad()
    numberOfStudies.isContinuous = false
    countLabel.text = "\(count)"
  }

  @IBAction func updateNumberOfStudies(_ sender: UISlider) {
    count = Int(sender.value)
    countLabel.text = "\(count)"
  }
  @IBAction func updateDifficulty(_ sender: UISegmentedControl) {
    difficulty = sender.selectedSegmentIndex + 1
  }

  @IBAction func doSearch(_ sender: Any) {
    delegate?.searchStudies(difficulty: difficulty, count: count)
    self.dismiss(animated: true, completion: nil)
  }

}
