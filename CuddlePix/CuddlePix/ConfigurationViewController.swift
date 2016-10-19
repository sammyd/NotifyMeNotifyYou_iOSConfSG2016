/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import UserNotifications
import AssetsLibrary

class ConfigurationViewController: UIViewController {
  
  var delegate: ConfigurationViewControllerDelegate?

  @IBOutlet weak var cuddlePixCount: UISegmentedControl!
  
  @IBAction func handleScheduleTapped(_ sender: UIButton) {
    guard let selectedString = cuddlePixCount.titleForSegment(at: cuddlePixCount.selectedSegmentIndex),
      let selectedNumber = Int(selectedString)
      else {
        delegate?.configurationCompleted(newNotifications: false)
        return
    }
    scheduleRandomNotifications(number: selectedNumber) { 
      DispatchQueue.main.async(execute: {
        self.delegate?.configurationCompleted(newNotifications: selectedNumber > 0)
      })
    }
  }
  
  @IBAction func handleCuddleMeNow(_ sender: UIButton) {
    scheduleRandomNotification(inSeconds: 5) { 
      DispatchQueue.main.async(execute: { 
        self.delegate?.configurationCompleted(newNotifications: true)
      })
    }
  }
}


extension ConfigurationViewController {
  fileprivate func scheduleRandomNotifications(number: Int, completion: @escaping () -> ()) {
    guard number > 0  else {
      completion()
      return
    }
    
    let group = DispatchGroup()
    
    for _ in 0..<number {
      let randomTimeInterval = TimeInterval(arc4random_uniform(3600))
      group.enter()
      scheduleRandomNotification(inSeconds: randomTimeInterval, completion: {
        group.leave()
      })
    }
    
    group.notify(queue: DispatchQueue.main) { 
      completion()
    }
  }
  
  fileprivate func scheduleRandomNotification(inSeconds: TimeInterval, completion: @escaping () -> ()) {
    let randomImageName = "hug\(arc4random_uniform(12) + 1)"
    let imageURL = Bundle.main.url(forResource: randomImageName, withExtension: "jpg")!
    
    let attachment = try! UNNotificationAttachment(identifier: randomImageName, url: imageURL, options: .none)
    
    let content = UNMutableNotificationContent()
    content.title = "New cuddlePix!"
    content.subtitle = "What a treat"
    content.attachments = [attachment]
    content.body = "Cheer yourself up with a hug 🤗"
    content.categoryIdentifier = newCuddlePixCategoryName
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
    
    let request = UNNotificationRequest(identifier: randomImageName, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { (error) in
      if let error =  error {
        print(error)
      }
      completion()
    }

  }
}

protocol ConfigurationViewControllerDelegate {
  func configurationCompleted(newNotifications new: Bool)
}
