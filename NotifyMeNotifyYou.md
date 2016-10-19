![](images/postboxes.jpg)

# [fit] Notify Me, Notify You.
# [fit] Aha!
## User notifications in iOS 10
### Sam Davies [@iwantmyrealname](https://twitter.com/iwantmyrealname)

---
![original](images/sam.jpg)

# [fit] hi,
# [fit] i'm sam

---

# What are user notifications?

---
![](images/control.jpg)

# [fit] Not to be confused with
# [fit] notification
# [fit] centre

---
![](images/olde.jpg)

# Problems with ye olde way

- Conflated source and display
- Operating in a vacuum
- Evolved _not_ designed
- Manual _in-app_ display

---

![](images/crowd.jpg)

# The `UserNotifications` Framework

- Fixes the issues
- Query for permission status
- Management of local notifications
- Custom UI
- Mutate push notifications

---

![](images/security.jpg)

# [fit] Authorisation

---

![](images/security.jpg)

# Authorisation

- Very similar to other iOS authorisation requests
- Doesn't require __Info.plist__ usage string
- Still have to request for remote notifications


---
# Authorisation

```swift
UNUserNotificationCenter
  .current()
  .requestAuthorization(options: [.alert, .sound]) {
    (granted, error) in
    if granted {
      self.loadNotificationData()
    } else {
      print(error?.localizedDescription)
    }
}
```

---

# Authorisation

```swift
open class UNUserNotificationCenter : NSObject {
  
  ...

  open func getNotificationSettings(completionHandler:
    @escaping (UNNotificationSettings) -> ())

  ...
  
}
```

---
![](images/blackboard.jpg)

# [fit] demo

---
![](images/clock.jpg)

# [fit] Scheduling

---
![](images/clock.jpg)

# Scheduling

- Push notifications
- Time interval
- Calendar
- Geofence

---
# Notification Content

```swift
let attachment =
  try! UNNotificationAttachment(identifier: randomImageName,
                                url: imageURL, options: .none)
    
let content = UNMutableNotificationContent()
content.title = "New cuddlePix!"
content.subtitle = "What a treat"
content.attachments = [attachment]
content.body = "Cheer yourself up with a hug 🤗"
content.categoryIdentifier = newCuddlePixCategoryName
//content.threadIdentifier = "my-conversation-thread"
```

---
# Triggers & Requests

```swift
let trigger =
  UNTimeIntervalNotificationTrigger(timeInterval: inSeconds,
                                    repeats: false)
    
let request =
  UNNotificationRequest(identifier: randomImageName,
                        content: content, trigger: trigger)

UNUserNotificationCenter
  .current()
  .add(request, withCompletionHandler: {
    (error) in
    if let error = error {
      print(error)
    }
    completion()
})
```


---
![](images/desk.jpg)

# [fit] Management


---
# Management

```swift
open class UNUserNotificationCenter : NSObject {
  
  ...

  // PENDING
  open func getPendingNotificationRequests(
    completionHandler: @escaping ([UNNotificationRequest]) -> ())

  open func removePendingNotificationRequests(
    withIdentifiers identifiers: [String])

  open func removeAllPendingNotificationRequests()

  ...
```

---
# Management

```swift
  ...

  // DELIVERED
  open func getDeliveredNotifications(
    completionHandler: @escaping ([UNNotification]) -> ())

  open func removeDeliveredNotifications(
    withIdentifiers identifiers: [String])

  open func removeAllDeliveredNotifications()
}


```

---
![](images/delivery.jpeg)

# [fit] In-App Delivery

---
# In-App Delivery

```swift
UNUserNotificationCenter.current().delegate = self
```

Implement the delegate method:

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void {
  completionHandler(.alert)
}
```

---
# In-App Delivery

```swift
UNUserNotificationCenter.current().delegate = self
```

Implement the delegate method:

```swift
func userNotificationCenter(
  _ center: UNUserNotificationCenter,
  willPresent notification: UNNotification,
  withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> ()) {

      completionHandler(.alert)
}
```


---
![](images/blackboard.jpg)

# [fit] demo


---
![](images/paint.jpg)

# [fit] Custom UI

---
![](images/paint.jpg)

# Custom UI

- New extension type in iOS 10
- Provided a storyboard & a view controller
- `UNNotificationContentExtension` provides notification

---
# Custom UI


- Notification contains request
- Attachments aren't readily available to your extension

```swift
func didReceive(_ notification: UNNotification) {
  if let attachment = notification.request.content.attachments.first {
    if attachment.url.startAccessingSecurityScopedResource() {
      imageView.image = UIImage(contentsOfFile: attachment.url.path)
      attachment.url.stopAccessingSecurityScopedResource()
    }
  }
}
```

---
![](images/interaction.jpeg)

# [fit] Interactivity

---
# Interactivity

```swift
func didReceive(
  _ response: UNNotificationResponse,
  completionHandler completion:
  @escaping (UNNotificationContentExtensionResponseOption) -> ()) {

    if response.actionIdentifier == "star" {
      showStars()
    }
    
    let time = DispatchTime.now() + DispatchTimeInterval.milliseconds(2000)
    DispatchQueue.main.asyncAfter(deadline: time) {
      completion(.dismissAndForwardAction)
    }
} 
```


---
![](images/blackboard.jpg)

# [fit] demo


---
![](images/push.jpeg)

# [fit] Intercepting
# [fit] __Push__
# [fit] Notifications

---
![](images/push.jpeg)

# Intercepting push notifications

- via the Service Extension point
- Think of it as a `.filter()` operation
- Provided with notification request - return content
- Limited time to perform processing

---
# Content augmentation

```swift
override func didReceive(_ request: UNNotificationRequest,
  withContentHandler contentHandler:
    @escaping (UNNotificationContent) -> Void) {
  
  self.contentHandler = contentHandler
  bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
  
  if let bestAttemptContent = bestAttemptContent {
    if let attachmentString = bestAttemptContent.userInfo["attachment-url"] as? String,
      let attachmentUrl = URL(string: attachmentString)
    {
      // Do some downloading
      ...
      let attachment = try! UNNotificationAttachment(identifier: attachmentString,
        url: url, options: [UNNotificationAttachmentOptionsTypeHintKey : kUTTypePNG])
      bestAttemptContent.attachments = [attachment]
      contentHandler(bestAttemptContent)
    }
  }
}
```

---
# Handling timeout

```swift
override func serviceExtensionTimeWillExpire() {
  if let contentHandler = contentHandler,
     let bestAttemptContent = bestAttemptContent {
    contentHandler(bestAttemptContent)
  }
}
```


---
![](images/blackboard.jpg)
# [fit] demo


---
# Summary

- Central place for all (user) notification goodness
- Can query settings and manage enqueued local notifications
- Extend user experience with custom notification UI
- Enhance push notifications with service extensions

---
![](images/switch.jpg)

# Make the switch

## _well, if you can_

- iOS 10 only

[github.com/sammyd](github.com/sammyd)
[@iwantmyrealname](twitter.com/iwantmyrealname)




