//
//  MessagingViewController.swift
//  chat
//
//  Created by Christian Ayscue on 12/29/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import UIKit

class MessagingViewController: UIViewController, UIBubbleTableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var chatInfo: [String:AnyObject] = NSUserDefaults.standardUserDefaults().dictionaryForKey(selectedChat) as Dictionary<String, AnyObject>
    var messageArray: [[String:AnyObject]]
    var imageToSend: UIImage? = nil
    var bubbleData: [NSBubbleData] = [NSBubbleData]()
    var blurView = UIScrollView()
    
    required init(coder aDecoder: NSCoder) {
        
        messageArray = chatInfo["Messages"]! as Array<Dictionary<String,AnyObject>>
        
        super.init(coder: aDecoder)
    }

    @IBOutlet weak var sendProgressView: UIProgressView!

    @IBOutlet weak var textInputView: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var bubbleTable: UIBubbleTableView!
    
    @IBAction func getPhoto(sender: AnyObject) {
        
        var whereFrom = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        whereFrom.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }))
        whereFrom.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.allowsEditing = false
            self.presentViewController(picker, animated: true, completion: nil)
        }))
        whereFrom.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        }))
        self.presentViewController(whereFrom, animated: true, completion: nil)
        
    }
    
    @IBAction func send(sender: AnyObject) {
        sendProgressView.alpha = 1
        //if message is an image
        if imageToSend != nil{
            var date: NSDate = NSDate(timeIntervalSinceNow: 0)
            
            //creates an image file to store locally with the image
            var localImageData = UIImageJPEGRepresentation(imageToSend, 0.3)
            
            //create a random string to identify the image - this string will never be displayed
            var string = "Image-"
            for var i = 0; i<10; i+=1 {
                var num = arc4random_uniform(10)
                string += (String(num))
            }
            
            //local message object is created
            var message = [String:AnyObject]() 
            message["date"] = date
            message["localImageData"] = localImageData
            message["person"] = chatInfo["YourID"]! as String
            message["string"] = string
            
            messageArray.append(message)
            chatInfo["Messages"] = messageArray
            NSUserDefaults.standardUserDefaults().setObject(chatInfo, forKey: selectedChat)
            
            //bubble table is reloaded
            var sayBubble = NSBubbleData(image:imageToSend, date:date, type:BubbleType2Mine)
            bubbleData.append(sayBubble)
            bubbleTable.reloadData()
            bubbleTable.scrollBubbleViewToBottomAnimated(true)
            
            //revert the appearance of the text field
            textField.text = ""
            textField.background = nil
            textField.backgroundColor = UIColor.whiteColor()

            //bellow code does not work for some reason - above code has the same effect 
            //textField.borderStyle = UITextBorderStyle.RoundedRect
            
            //make the message to be put in the cloud
            let cloudImageFile = PFFile(name:"imageFile", data: UIImageJPEGRepresentation(imageToSend, 0.3))
            imageToSend = nil
            
            var newMessage = message
            newMessage.removeValueForKey("localImageData")
            newMessage["PFImageFile"] = cloudImageFile
            
            sendProgressView.setProgress(0.3, animated: true)
            //get the chat from parse and add the message to it
            var query = PFQuery(className: "Chat")
            query.whereKey("chatID", equalTo: selectedChat)
            var error = NSError()
            query.getFirstObjectInBackgroundWithBlock { (chat, error) -> Void in
                if chat != nil && error == nil{//if the chat was found
                    var messages = chat["messages"] as Array<AnyObject>
                    //keep the cloud array at 25 length
                    if messages.count >= 25 {
                        messages.removeAtIndex(0)
                    }
                    messages.append(newMessage)
                    chat["messages"] = messages
                    chat.saveInBackgroundWithBlock({ (bool, error) -> Void in
                        self.sendProgressView.setProgress(1.0, animated: true)
                        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("hideProgressBar:"), userInfo: nil, repeats: false)
                    })
                }
            }
            //if message is text
        }else if (textField.text != ""){
            var date: NSDate = NSDate(timeIntervalSinceNow: 0)
            
            //message object is created
            var message: [String:AnyObject] = ["date": date, "string": textField.text, "person": chatInfo["YourID"]! as String]
            
            //message is appended to local chat array
            messageArray.append(message)
            chatInfo["Messages"] = messageArray
            NSUserDefaults.standardUserDefaults().setObject(chatInfo, forKey: selectedChat)
            
            //bubble table is reloaded
            
            var sayBubble = NSBubbleData(text:textField.text, date:date, type:BubbleType2Mine)
            bubbleData.append(sayBubble)
            bubbleTable.reloadData()
            bubbleTable.scrollBubbleViewToBottomAnimated(true)

            textField.text = ""
            sendProgressView.setProgress(0.3, animated: true)
            //textField.text = ""
            
            //message is appended to cloud version of chat array
            
            //get the chat from parse
            var query = PFQuery(className: "Chat")
            query.whereKey("chatID", equalTo: selectedChat)
            var error = NSError()
            query.getFirstObjectInBackgroundWithBlock { (chat, error) -> Void in
                if chat != nil && error == nil{//if the chat was found
                    var messages = chat["messages"] as Array<AnyObject>
                    //keep the cloud array at 25 length
                    if messages.count >= 25 {
                        messages.removeAtIndex(0)
                    }
                    messages.append(message)
                    chat["messages"] = messages
                    chat.saveInBackgroundWithBlock({ (bool, error) -> Void in
                        self.sendProgressView.setProgress(1.0, animated: true)
                        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("hideProgressBar:"), userInfo: nil, repeats: false)
                    })
                }
            }
            
        }
        self.reloadBlurView()
    }
    
    //add a message received by push notification for this chat
    func incomingMessage(){
        
        self.downloadMessages()
        self.reloadBubbleData()
        
    }
    
    //download messages
    func downloadMessages(){
        //download all new messages associated with the chat
        var query = PFQuery(className: "Chat")
        query.whereKey("chatID", equalTo: selectedChat)
        var error = NSError()
        var chat = query.getFirstObject()
        if chat != nil{
            var messages: [[String:AnyObject]] = chat["messages"] as Array<Dictionary<String,AnyObject>>
            
            //for every message downloaded, append only new messages to the array
            for message in messages{
                for var i = (messageArray.count-messages.count < 0 ? 0 : messageArray.count-messages.count); i <= messageArray.count; i += 1{
                    //messageArray did not aleady contain the message, so append it
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
                        
                        //break if the message is already there
                        if  (message["string"] as String == message2["string"] as String){
                            break
                        }
                    }
                }
            }
        }
        //save the updated message array
        chatInfo["Messages"] = messageArray
        NSUserDefaults.standardUserDefaults().setObject(chatInfo, forKey: selectedChat)
    }
    
    //refresh the table w/ new data
    func reloadBubbleData(){
        //create bubble data with each message and append it to the bubbleData array
        for message in messageArray{
            var bubbleType = (chatInfo["YourID"] as String == message["person"] as String) ? BubbleTypeMine: BubbleTypeSomeoneElse
            if message["localImageData"] == nil{
                //create bubble from text
                var newBubble = NSBubbleData(text: message["string"] as String, date:message["date"] as NSDate, type:bubbleType)
                bubbleData.append(newBubble)
            }else{
                //create a bubble with the image
                var image = UIImage(data: message["localImageData"] as NSData)
                var newBubble = NSBubbleData(image: image, date: message["date"] as NSDate, type: bubbleType)
                self.bubbleData.append(newBubble)
                
            }
        }
        bubbleTable.reloadData()
        bubbleTable.scrollBubbleViewToBottomAnimated(false)
    }
    
    func hideProgressBar(timer: NSTimer) -> Void{
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.sendProgressView.alpha = 0
            }, completion: { (bool) -> Void in
                self.sendProgressView.progress = 0
        })
    }
    
//    func rotated(){
//        self.bubbleTable.reloadData()
//        var frame = CGRectMake(0, 0, self.navigationController!.navigationBar.frame.width, self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height)
//        bubbleTable.tableHeaderView = UIView(frame: frame)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = CGRectMake(0, 0, self.navigationController!.navigationBar.frame.width, self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height)
        bubbleTable.tableHeaderView = UIView(frame: frame)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        //sets up the sendProgresView
        self.sendProgressView.alpha = 0
        self.sendProgressView.progress = 0
        self.sendProgressView.layer.zPosition = 100

        self.navigationItem.title = selectedChat
        
        //sets all the properties for the bubbleTable
        bubbleTable.bubbleDataSource = self
        bubbleTable.snapInterval = 120
        bubbleTable.showAvatars = false
        bubbleTable.typingBubble = NSBubbleTypingTypeNobody
        
        self.reloadBubbleData()
        
//        var swipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
//        self.view.addGestureRecognizer(swipeGesture)
//        bubbleTable.addGestureRecognizer(swipeGesture)
        
        // Keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeShown:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
//    func hideKeyboard(gesture:UISwipeGestureRecognizer){
//        println("hiding")
//        if gesture.direction == UISwipeGestureRecognizerDirection.Down{
//            self.textField.resignFirstResponder()
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bubbleTableView(tableView: UIBubbleTableView!, dataForRow row: NSInteger) -> NSBubbleData! {
        return bubbleData[row]
    }
    
    func rowsForBubbleTable(tableView: UIBubbleTableView!) -> Int {
        return bubbleData.count
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.textField.resignFirstResponder()
    }
    
    func keyboardWillBeShown(aNotification: NSNotification)
    {
        var info = aNotification.userInfo! as Dictionary<NSObject,AnyObject>
        var kbSize = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size
        
        //slides text input view with keyboard
        UIView.animateWithDuration(0.2, animations: { () -> Void in

            println("shown")
            
            var frame = self.textInputView.frame
            frame.origin.y = self.view.frame.height - self.textInputView.frame.height - kbSize!.height
            self.textInputView.frame = frame
            
            var bubframe = self.bubbleTable.frame
            bubframe.size.height = self.view.frame.height - self.textInputView.frame.height - kbSize!.height
            self.bubbleTable.frame = bubframe

            }) { (bool) -> Void in
                self.bubbleTable.scrollBubbleViewToBottomAnimated(true)
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification){
        //var info = aNotification.userInfo! as Dictionary<NSObject,AnyObject>
        //var kbSize = info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        println("hidden")
        
        //slides text input view with keyboard

        UIView.animateWithDuration(0.2, animations:{ () -> Void in
            self.textInputView.frame.origin.y = self.view.frame.height - self.textInputView.frame.height
            
            self.bubbleTable.frame.size.height = self.view.frame.height - self.navigationController!.navigationBar.frame.size.height - UIApplication.sharedApplication().statusBarFrame.height - self.textInputView.frame.height
            
            }) { (bool) -> Void in
                self.bubbleTable.scrollBubbleViewToBottomAnimated(true)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if imageToSend != nil{
            imageToSend = nil
            textField.background = nil
            textField.borderStyle = UITextBorderStyle.RoundedRect
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.text = "\(textField.text)\n"
        return false
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion:nil)
        self.resignFirstResponder()
        imageToSend = image
        textField.text = ""
        textField.background = imageToSend
        textField.borderStyle = UITextBorderStyle.Line
    }
    
    override func viewWillAppear(animated: Bool) {
        self.reloadBlurView()
    }
    
    func reloadBlurView(){
        blurView = UIScrollView(frame: CGRectMake(0,0,self.view.frame.width, self.navigationController!.navigationBar.frame.height+UIApplication.sharedApplication().statusBarFrame.height))
        
        var preBlurView = UIView(frame: CGRectMake(0, 0, bubbleTable.contentSize.width, bubbleTable.contentSize.height+600))
        
        //make gray area above table
        var topGrayGround = UIImageView(image: UIImage(named: "grayGround.png")?.applyTintEffectWithColor(UIColor.blackColor().colorWithAlphaComponent(0.3)))
        topGrayGround.frame = CGRectMake(0,-300,self.view.frame.width, 300)
        blurView.addSubview(topGrayGround)
        
        //create an image for every cell and add each image to the blurView bellow the previous
        var nextYCoord = CGFloat(0);
        for var i = 0; i < bubbleTable.numberOfSections(); ++i{
            for var j = 0; j < bubbleTable.numberOfRowsInSection(i); ++j{
                bubbleTable.contentOffset = CGPointMake(0, nextYCoord)
                var cell = bubbleTable.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i))? as UITableViewCell?
                
                //if var tempCell: UITableViewCell = cell? {
                    var tempArchiveView = NSKeyedArchiver.archivedDataWithRootObject(cell!)
                    var copiedCell = NSKeyedUnarchiver.unarchiveObjectWithData(tempArchiveView) as UITableViewCell
                    copiedCell.frame.origin = CGPointMake(0, -nextYCoord)
                    
                    nextYCoord += copiedCell.frame.height
                    
                    preBlurView.addSubview(copiedCell)
                
                    //once all images are added, add a grey area beneath the image
                    if i == bubbleTable.numberOfSections() - 1 && j == bubbleTable.numberOfRowsInSection(i) - 1{
                        var bottomGrayGround = UIImageView(image: UIImage(named: "grayGround.png"))
                        bottomGrayGround.frame = CGRectMake(0,nextYCoord,bubbleTable.frame.width,600)
                        preBlurView.addSubview(bottomGrayGround)
                    }
                //}
            }
        }
        //adds the blurred image to the blurview
        var imageView = UIImageView(image: imageWithView(preBlurView).applyTintEffectWithColor(UIColor.blackColor().colorWithAlphaComponent(0.3)))
        blurView.addSubview(preBlurView)
        
        //sets up the blur views location and properties
        blurView.contentOffset = CGPointMake(0, -self.navigationController!.navigationBar.frame.height - UIApplication.sharedApplication().statusBarFrame.height)
        blurView.showsHorizontalScrollIndicator = false
        blurView.showsVerticalScrollIndicator = false
        
        self.view.addSubview(blurView)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        blurView.contentOffset = CGPointMake(0, scrollView.contentOffset.y - self.navigationController!.navigationBar.frame.height - UIApplication.sharedApplication().statusBarFrame.height)
    }
    
    //make an image with the view
    func imageWithView(view: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        var img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return img;
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
