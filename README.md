# ShareOurCost <img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/ShareOurCost/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60%403x.png" width="40">

ShareOurCost is an application for recording common expense between you and your friends in a careful way. Instead of using your personal information like phone number or e-mail, you can unique user ID for connecting with your friends. And you can send expense sharing invitation to your friend and track the status and details of expenses.

## Requirements
iOS 10.0+<br/>
Xcode 8.3+

## Features


## Screen Shots

### Login View<br/>
 - Use e-mail for registration or login, use Firebase Authorization for user account management.
 - Enter user ID for user identification and sending friend invitation, the application will check if it is unique while registration.

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/login.png" width = "275" height = "500" align=center />
</kbd>

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/Registration.png" width = "275" height = "500" align=center />
</kbd>

### Search Friend<br/>
 - Search friend by user ID, which is set up during registration.
 - Send friend invitation by touching "ADD" button.

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/searchFriendID1.png" width = "275" height = "500" align=center />
</kbd>

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/searchFriendID2.png" width = "275" height = "500" align=center />
</kbd>

### Friend List<br/>
 - Friend list for existing friends and received friend requests.
 - Touch friend name label will show accepted expenses between you and friend.
 - Touch expense label will show the details of corresponding expense.

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/friendList.png" width = "275" height = "500" align=center />
</kbd>

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/friendBalance.png" width = "275" height = "500" align=center />
</kbd>

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/expenseDetail.png" width = "275" height = "500" align=center />
</kbd>

### Add expense<br/>
 - Choose a friend to share your common expense with date, description and shared amount. 
 - Shared amount can be set by number directly or by percent.
 
<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/addExpense1.png" width = "275" height = "500" align=center />
</kbd>

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/addExpense2.png" width = "275" height = "500" align=center />
</kbd>

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/addExpense3.png" width = "275" height = "500" align=center />
</kbd>

### Expense List<br/>

 - There are five expense statuses:<br/>
  `-` Accepted: Expenses accepted by user who recieved this expense sharing invitation.<br/>
  `-` Denied: Expenses denied by the friend you want to share expense with.<br/>
  `-` Received: Expenses your friend wants to share with you, waiting for your approval.<br/>
  `-` Sent: Expenses sharing invitation you sent, waiting for the approval from your firend.<br/>
  `-` Delete?: Expenses was accepted before but your friend wants to delete it afterwards, waiting for your approval.
 - Can directly choose accept or deny by touching "check" or "cross" image.
 - Touch expense label will show the details of corresponding expense.

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/expenseList-Accepted.png" width = "275" height = "500" align=center />
</kbd>

<kbd>
<img src="https://github.com/BoyLeeTW/ShareOurCost/blob/master/Screenshots/expenseList-Received.png" width = "275" height = "500" align=center />
</kbd>

## Libraries

- Crashlytics (3.8.5)
- Fabric (1.6.12)
- Firebase/Core (4.0.2)
- Firebase/Auth (4.0.0)
- Firebase/Database (4.0.2)
- IQKeyboardManager (4.0.10)
- NVActivityIndicatorView (3.7.0)
- PageMenu (2.0.0)

## Contact

Brad Lee <br/>
:email: <boy0726@gmail.com><br/>
