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


protocol TableSectionCellProvider {
  func prepare(cell: UITableViewCell) -> UITableViewCell
}

protocol TableSectionProvider {
  var name: String { get }
  var numberOfCells: Int { get }
  func cellProvider(at index: Int) -> TableSectionCellProvider?
}

enum NotificationTableSection: Int {
  case settings, pending, delivered
}

struct SettingTableSectionProvider: TableSectionProvider {
  let settings: UNNotificationSettings
  let name: String
  
  var numberOfCells: Int {
    return 8
  }
  
  func cellProvider(at index: Int) -> TableSectionCellProvider? {
    switch index {
    case 0:
      return BooleanCellProvider(name: "Authorisation Status", value: settings.authorizationStatus == .authorized)
    case 1:
      return BooleanCellProvider(name: "Show in Notification Center", value: settings.notificationCenterSetting == .enabled)
    case 2:
      return BooleanCellProvider(name: "Sound Enabled?", value: settings.soundSetting == .enabled)
    case 3:
      return BooleanCellProvider(name: "Badges Enabled?", value: settings.badgeSetting == .enabled)
    case 4:
      return BooleanCellProvider(name: "Alerts Enabled?", value: settings.alertSetting == .enabled)
    case 5:
      return BooleanCellProvider(name: "Show on lock screen?", value: settings.lockScreenSetting == .enabled)
    case 6:
      return BooleanCellProvider(name: "Show in Car Play?", value: settings.carPlaySetting == .enabled)
    case 7:
      return BooleanCellProvider(name: "Alert banners?", value: settings.alertStyle == .banner)
    default:
      return .none
    }
  }
}

struct PendingNotificationsTableSectionProvider: TableSectionProvider {
  let requests: [UNNotificationRequest]
  let name: String
  
  var numberOfCells: Int {
    return requests.count
  }
  
  func cellProvider(at index: Int) -> TableSectionCellProvider? {
    return PendingNotificationCellProvider(request: requests[index])
  }
  
  struct PendingNotificationCellProvider: TableSectionCellProvider {
    let request: UNNotificationRequest
    
    func prepare(cell: UITableViewCell) -> UITableViewCell {
      cell.textLabel?.text = request.content.title
      if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
        cell.detailTextLabel?.text = "Scheduled: \(trigger.nextTriggerDate()!)"
      }
      return cell
    }
  }
}

struct DeliveredNotificationsTableSectionProvider: TableSectionProvider {
  let notifications: [UNNotification]
  let name: String
  
  var numberOfCells: Int {
    return notifications.count
  }
  
  func cellProvider(at index: Int) -> TableSectionCellProvider? {
    return DeliveredNotificationCellProvider(notification: notifications[index])
  }
  
  struct DeliveredNotificationCellProvider: TableSectionCellProvider {
    let notification: UNNotification
    
    func prepare(cell: UITableViewCell) -> UITableViewCell {
      cell.textLabel?.text = notification.request.content.title
      cell.detailTextLabel?.text = "Delivered: \(notification.date)"
      return cell
    }
  }
}


struct BooleanCellProvider: TableSectionCellProvider {
  let name: String
  let value: Bool
  
  func prepare(cell: UITableViewCell) -> UITableViewCell {
    cell.textLabel?.text = name
    cell.detailTextLabel?.text = .none
    cell.accessoryType = value ? .checkmark : .none
    return cell
  }
}




