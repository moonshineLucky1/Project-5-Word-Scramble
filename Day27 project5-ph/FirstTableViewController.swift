//
//  FirstTableViewController.swift
//  Day27 project5-ph
//
//  Created by 李沐軒 on 2019/3/12.
//  Copyright © 2019 李沐軒. All rights reserved.
//

import UIKit

class FirstTableViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptforAnswer))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["swift"]
        }
        
        startGame()
        
    }

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptforAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
            
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true, completion: nil)
        
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    
                    if !lowerAnswer.isEmpty {
                        if  lowerAnswer.count > 3 {
                            
                            if title?.lowercased() != lowerAnswer {
                                
                                usedWords.insert(lowerAnswer, at: 0)
                                
                                let indexPath = IndexPath(row: 0, section: 0)
                                tableView.insertRows(at: [indexPath], with: .automatic)
                                
                                return
                                
                            } else {
                                showErrorMessage(title: "Word can't be the same one.", message: "Try another word")
                            }
                            
                        } else {
                            showErrorMessage(title: "Word too short", message: "Need to input more than 3 letters at least.")
                        }
                       
                    } else {
                       showErrorMessage(title: "Nothing here.", message: "Please input something.")
                    }
                    
                } else {
                    showErrorMessage(title: "Word not recognized", message: "You can't just make them up")
                }
                
            } else {
                showErrorMessage(title: "Word already used.", message: "Be more original.")
            }
            
        } else {
            guard let title = title else { return }
            showErrorMessage(title: "Word not possible.", message: "Try to spell another word from \(title.lowercased())")
        }

    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
        
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
            
        
//        意思：checker沒有找到有拼錯的狀況, 也就是拼對return true
    
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usedWords.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)

        cell.textLabel?.text = usedWords[indexPath.row]

        return cell
    }
    
    

}
