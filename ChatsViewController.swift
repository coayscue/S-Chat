//
//  TableViewController.swift
//  chat
//
//  Created by Christian Ayscue on 12/16/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import UIKit

var selectedChat: String = ""

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    var chatOrder: Array<String> = NSUserDefaults.standardUserDefaults().arrayForKey("chatOrder") as! Array<String>
    
    var blurView = UIScrollView()
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func addChat(sender: AnyObject) {
        
        //create an alert with options to create a chat, enter a chat, or cancel
        var alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        var createAction = UIAlertAction(title: "Create Chat", style: UIAlertActionStyle.Default) { (action) -> Void in
            var isCreator = NSUserDefaults.standardUserDefaults().boolForKey("chatCreator")
//            if isCreator == false{
//                var productSet = NSMutableSet()
//                productSet.addObject("chatCreator")
//                var productsRequest = SKProductsRequest(productIdentifiers: productSet)
//                productsRequest.delegate = self;
//                productsRequest.start()
//            }else{
                self.performSegueWithIdentifier("createChat", sender: self)
            //}
        }
        var enterAction = UIAlertAction(title: "Enter Chat", style: UIAlertActionStyle.Default) { (enterAction) -> Void in
            self.performSegueWithIdentifier("enterChat", sender: self)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (cancelAction) -> Void in
        }
        alert.addAction(createAction)
        alert.addAction(enterAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
//    override func viewWillLayoutSubviews() {
//        var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(self.view.frame.width/2-50, self.view.frame.height/2-100, 100, 100))
//        activityIndicator.color = UIColor.cyanColor()
//        activityIndicator.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
//        self.view.addSubview(activityIndicator)
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.startAnimating()
//    }
    
    //runs before the table view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        
        tableView.backgroundColor = UIColor.grayColor()
        
        tableView.tableFooterView = UIView(frame:CGRectZero)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        selectedChat = ""
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

        //refreshes the tables data
        self.refreshTable()
        
    }
    
    //gets all new messages and reloads the table
    func refreshTable(){
        //download all new messages associated with the chat
        
        var error = NSError()
        for var i = 0; i<chatOrder.count; i+=1{
            var chatID = chatOrder[i];
            var query = PFQuery(className: "Chat")
            query.whereKey("chatID", equalTo: chatID)
            var index = i;
            query.getFirstObjectInBackgroundWithBlock({ (chat, error) -> Void in
                
                //gets the chat info and its message array to be modified
                var chatInfo = NSUserDefaults.standardUserDefaults().objectForKey(chatID) as Dictionary<String, AnyObject>!
                var messageArray = chatInfo["Messages"]! as Array<Dictionary<String, AnyObject>>
                
                if chat != nil{
                    
                    var messages: [[String:AnyObject]] = chat["messages"] as Array<Dictionary<String,AnyObject>>
                    
                    //for every message downloaded, check if the message has already been downloaded. If not, add it to the array.
                    for message in messages{
                        for var i = (messageArray.count-messages.count < 0 ? 0 : messageArray.count-messages.count); i <= messageArray.count; i += 1{
                            println(i)
                            //after we've checked every element of the messageArray, append the cloud message
                            if i == messageArray.count{
                                var newMessage = message
                                if var file = message["PFImageFile"] as? PFFile{
                                    newMessage["localImageData"] = file.getData()
                                    newMessage["PFImageFile"] = nil
                                }
                                messageArray.append(newMessage)
                                chatInfo["Seen"] = false
                                break
                            }else{
                                var message2 = messageArray[i]
                                
                                //break if the message is already in your the array
                                if  (message["string"] as String == message2["string"] as String){
                                    break
                                }
                            }
                        }
                    }
                }
                //save the new message array to local storage
                chatInfo["Messages"] = messageArray
                NSUserDefaults.standardUserDefaults().setObject(chatInfo, forKey: chatID)
                if index == self.chatOrder.count-1{
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatOrder.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "chatCell");
        
        //set cell content
        if indexPath.row < chatOrder.count {
            
            var chatInfo = NSUserDefaults.standardUserDefaults().objectForKey(chatOrder[indexPath.row]) as Dictionary<String, AnyObject>!
            
            //set up the cell with the correct data
            cell.textLabel?.text = chatOrder[indexPath.row]
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(22)
            var peopleNames = chatInfo["People"] as String
            cell.detailTextLabel?.text = peopleNames
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(15)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            //set up the dot image if chat has unseen messages
            if !(chatInfo["Seen"] as Bool){
                var imv = UIImageView(frame: CGRectMake(12, 21.5, 10, 10))
                imv.image = UIImage(named: "selectionDot.png")
                imv.tag = 20
                cell.contentView.addSubview(imv)
            }
            
        }
        
        //set cell protperties
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.grayColor()
        cell.separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedChat = chatOrder[indexPath.row]
        var chatInfo = NSUserDefaults.standardUserDefaults().objectForKey(chatOrder[indexPath.row]) as Dictionary<String, AnyObject>!
        chatInfo["Seen"] = true
        NSUserDefaults.standardUserDefaults().setObject(chatInfo, forKey: chatOrder[indexPath.row])
        
        //to remove "unseen dot" when user returns to this view
        tableView.reloadData()
        
        //avoid wierd blurview effect
        var colorView = UIImageView(image: UIImage(named: "grayGround.png")?.applyTintEffectWithColor(UIColor.blackColor().colorWithAlphaComponent(0.7)))
        colorView.frame = CGRectMake(0,0,self.view.frame.width, self.navigationController!.navigationBar.frame.height+UIApplication.sharedApplication().statusBarFrame.height)
        self.view.addSubview(colorView)
        
        self.performSegueWithIdentifier("showChat", sender: self)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        //remove the chat from the app
        NSUserDefaults.standardUserDefaults().removeObjectForKey(chatOrder[indexPath.row])
        
        // unsubscribe user from the chat's notifications
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.removeObject(chatOrder[indexPath.row], forKey: "channels")
        currentInstallation.saveInBackgroundWithBlock(nil)
        
        // remove the object from the chat
        chatOrder.removeAtIndex(indexPath.row)
        
        //remove the object from the tableView
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.Right)
        
    }
    
    //make an image with the view
    func imageWithView(view: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        var img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img;
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        blurView.contentOffset = scrollView.contentOffset
    }
    
    override func viewWillAppear(animated: Bool) {
        
        selectedChat = ""
        blurView = UIScrollView(frame: CGRectMake(0,0,self.view.frame.width, self.navigationController!.navigationBar.frame.height+UIApplication.sharedApplication().statusBarFrame.height))
        
        var colorView = UIImageView(image: UIImage(named: "grayGround.png")?.applyTintEffectWithColor(UIColor.blackColor().colorWithAlphaComponent(0.7)))
        
        colorView.frame = CGRectMake(0,-300,self.view.frame.width, 300)
        
        var imageView = UIImageView(image: imageWithView(tableView).applyTintEffectWithColor(UIColor.blackColor().colorWithAlphaComponent(0.7)))
        
        blurView.addSubview(imageView)
        blurView.addSubview(colorView)
        blurView.showsHorizontalScrollIndicator = false
        blurView.showsVerticalScrollIndicator = false
        
        self.view.addSubview(blurView)
        
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        for invalidProductId in response.invalidProductIdentifiers
        {
            println(invalidProductId)
        }
//                var createChatProduct = response.products[0] as SKProduct
//        
//                var storeAlert = UIAlertController(title: "One-Time-Purchase", message: "$0.99 to create chats. Entering chats is free.", preferredStyle: UIAlertControllerStyle.Alert)
//                var buyAction = UIAlertAction(title: "Purchase", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//        
//                    var payment = SKMutablePayment(product: createChatProduct)
//                    SKPaymentQueue.defaultQueue().addPayment(payment)
//                    storeAlert.dismissViewControllerAnimated(true, completion: nil)
//                })
//                var restoreAction = UIAlertAction(title: "Restore", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//                    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
//                    storeAlert.dismissViewControllerAnimated(true, completion: nil)
//                })
//                var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
//                storeAlert.addAction(buyAction)
//                storeAlert.addAction(restoreAction)
//                storeAlert.addAction(cancelAction)
//                
//                self.presentViewController(storeAlert, animated: true, completion: nil)
//        
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions as [SKPaymentTransaction]{
            switch (transaction.transactionState) {
                // Call the appropriate custom method.
                //if the transaction succeeded, enter create chat view
            case SKPaymentTransactionState.Purchased:
                fallthrough
            case SKPaymentTransactionState.Restored:
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "chatCreator")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                self.performSegueWithIdentifier("createChat", sender: self)
                break
                //if failed, do nothing
            case SKPaymentTransactionState.Failed:
                var successAlert = UIAlertController(title: "Failed", message: "The transaction failed.", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(successAlert, animated: true, completion: nil)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break
            default:
                break
            }
        }
    }

 }
