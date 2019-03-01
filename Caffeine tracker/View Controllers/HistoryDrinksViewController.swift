//
//  RecentsDrinksViewController.swift
//  Caffeine tracker
//
//  Created by Tobias Ruano on 14/6/18.
//  Copyright © 2018 Tobias Ruano. All rights reserved.
//

import UIKit

class HistoryDrinksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var todaysCaffeine: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var mgLabel: UILabel!
    @IBOutlet weak var yesterdaysCaffeine: UILabel!
    @IBOutlet weak var tablewView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    
    var caffeineLimit = 400
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablewView.reloadData()
        
        progressViewStyle()
        
        tablewView.tableFooterView = UIView()
    }
    
    
    func displayCaffeineProgress() {
        checkTodaysAndYesterdaysCaffeine()
        let value = caffeineLimit - Int(todaysCaffeine.text!)!
        progress.setProgress((Float(value) / Float(caffeineLimit)), animated: true)
        
        changeLabelColor()
    }
    
    func changeLabelColor() {
        if progress.progress == 0 {
            UIView.transition(with: todaysCaffeine, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.todaysCaffeine.textColor = .red
                self.mgLabel.textColor = .red
                self.todayLabel.textColor = .red
            }, completion: nil)
        }else {
            UIView.transition(with: todaysCaffeine, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.todaysCaffeine.textColor = .black
                self.mgLabel.textColor = .black
                self.todayLabel.textColor = .black
            }, completion: nil)
        }
    }
    
    func checkTodaysAndYesterdaysCaffeine() {
        let date = Date()
        let calanderDate = Calendar.current.dateComponents([.day, .year, .month], from: date)
        
        //Today's
        todaysCaffeine.text = "0"
        for element in arrayDrinksAdded {
            let day = Calendar.current.dateComponents([.day, .year, .month], from: element.date!).day
            let month = Calendar.current.dateComponents([.day, .year, .month], from: element.date!).month
            if day == calanderDate.day && month == calanderDate.month {
                let caffeineNumber = Int(todaysCaffeine.text!)
                
                todaysCaffeine.text = "\(caffeineNumber! + element.caffeineMg)"
            }
        }
        
        //Yesterday's
        yesterdaysCaffeine.text = "0"
        for element in arrayDrinksAdded {
            var yesterday = date
            yesterday.addTimeInterval(-86400)
            let yesterdaysDate = Calendar.current.dateComponents([.day, .year, .month], from: yesterday)
            let day = Calendar.current.dateComponents([.day, .year, .month], from: element.date!).day
            let month = Calendar.current.dateComponents([.day, .year, .month], from: element.date!).month
            if day == yesterdaysDate.day && month == yesterdaysDate.month {
                let caffeineNumber = Int(yesterdaysCaffeine.text!)
                
                yesterdaysCaffeine.text = "\(caffeineNumber! + element.caffeineMg)"
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let string = UserDefaults.standard.value(forKey: "maxCaf") as? String {
            
            let stringArray = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
            for item in stringArray {
                caffeineLimit = 0
                caffeineLimit = caffeineLimit * 10
                if let number = Int(item) {
                    caffeineLimit = caffeineLimit + number
                }
            }
        }
        
        if let data = UserDefaults.standard.value(forKey: arrayDrinksAddedKey) as? Data {
            let ArrayAddedData = try? PropertyListDecoder().decode(Array<drink>.self, from: data)
            arrayDrinksAdded = ArrayAddedData!
        }
        
        displayCaffeineProgress()
        tablewView.reloadData()
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "All your drinks:"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = UserDefaults.standard.value(forKey: arrayDrinksAddedKey) as? Data {
            let ArrayAddedData = try? PropertyListDecoder().decode(Array<drink>.self, from: data)
            arrayDrinksAdded = ArrayAddedData!
        }
        return arrayDrinksAdded.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: historyTableViewCell, for: indexPath) as! CustomCellClass
        
        cell.DrinkName.text = arrayDrinksAdded.reversed()[indexPath.row].type
        cell.caffeineMg.text = "\(String(arrayDrinksAdded.reversed()[indexPath.row].caffeineMg))mg"
        cell.miliLiters.text = "\(String(arrayDrinksAdded.reversed()[indexPath.row].mililiters))ml"
        cell.imageView?.image = UIImage(named: arrayDrinksAdded.reversed()[indexPath.row].icon)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let alert = UIAlertController(title: "", message: "Are you sure you want to delete \(arrayDrinksAdded.reversed()[indexPath.row].caffeineMg)mg of \(arrayDrinksAdded.reversed()[indexPath.row].type)?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
                print("User click Delete button")
                let indice = (arrayDrinksAdded.count - (indexPath.row + 1))
                arrayDrinksAdded.remove(at: indice);
                UserDefaults.standard.set(try? PropertyListEncoder().encode(arrayDrinksAdded), forKey: arrayDrinksAddedKey)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                //Taptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                
                self.checkTodaysAndYesterdaysCaffeine()
                self.displayCaffeineProgress()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                print("User click Cancel button")
            }))
            
            self.present(alert, animated: true, completion: {
                print("ActionSheet action completed!")
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func progressViewStyle() {
        // Progress View Style
        let gradientView = GradientView(frame: progress.bounds)
        //convert gradient view to image, flip horizontally and assign as the track image
        progress.trackImage = UIImage(view: gradientView).withHorizontallyFlippedOrientation()
        //invert the progress view
        progress.transform = CGAffineTransform(scaleX: -1.0, y: -1.0)
        progress.progressTintColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        progress.layer.cornerRadius = 8.0
        progress.layer.shadowColor = UIColor.lightGray.cgColor
        progress.layer.shadowOpacity = 1
        progress.layer.shadowOffset = CGSize.zero
        progress.layer.shadowRadius = 5
        self.progress.clipsToBounds = true
    }
}

extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}
