//
//  UIBubbleHeaderTableViewCell.m
//  UIBubbleTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import "UIBubbleHeaderTableViewCell.h"

@interface UIBubbleHeaderTableViewCell ()

@property (nonatomic, retain) UILabel *label;

@end

@implementation UIBubbleHeaderTableViewCell

@synthesize label = _label;
@synthesize date = _date;
@synthesize width = _width;


+ (CGFloat)height
{
    return 25.0;
}

- (void)setDate:(NSDate *)value
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *textDay = [dateFormatter stringFromDate:value];
    
    //string with todays date
    NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *nowDateText = [dateFormatter stringFromDate:nowDate];
    //string with yesterdays date
    NSDate *yesterDate = [NSDate dateWithTimeIntervalSinceNow:86400];
    NSString *yesterDateText = [dateFormatter stringFromDate:yesterDate];
    
    //gives the correctly formatted date string to display
    NSString *text;
    if ([nowDateText isEqualToString:textDay]){
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        text = [@"Today, " stringByAppendingString: [dateFormatter stringFromDate:value]];
    }else if ([yesterDateText isEqualToString:textDay]){
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        text = [@"Yesterday, " stringByAppendingString: [dateFormatter stringFromDate:value]];
    }else{
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        text = [dateFormatter stringFromDate:value];
    }

    
    
    if (self.label)
    {
        self.label.text = text;
        return;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, *_width, [UIBubbleHeaderTableViewCell height])];
    self.label.text = text;
    self.label.font = [UIFont boldSystemFontOfSize:12];
    self.label.textAlignment = NSTextAlignmentCenter;
    //self.label.shadowOffset = CGSizeMake(0, 1);
    //self.label.shadowColor = [UIColor whiteColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}



@end
