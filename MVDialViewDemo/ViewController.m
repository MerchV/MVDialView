//
//  ViewController.m
//  MVDialViewDemo
//
//  Created by Merch on 12/5/2013.
//  Copyright (c) 2013 Merch Visoiu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<MVDialViewDataSource, MVDialViewDelegate>
@property (nonatomic, strong) NSArray* dataArray;
@property (nonatomic, strong) IBOutlet MVDialView* dialView1;
@property (nonatomic, strong) MVDialView* dialView2;
@property (nonatomic, strong) MVDialView* dialView3;
@property (nonatomic, strong) IBOutlet UILabel* dial3SelectLabel;
@end

@implementation ViewController


#pragma mark - UIViewController

- (void)viewDidLoad {

    [self.dialView1 insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DialTopBackgroundImage.png"]] atIndex:0];
    [self.dialView1 loadInitialLabel];

    self.dataArray = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten", @"Eleven", @"Twelve", @"Thirteen", @"Fourteen", @"Fifteen", @"Sixteen", @"Seventeen"];
    [self.view addSubview:self.dialView2];
    [self.dialView2 insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DialMiddleBackgroundImage.png"]] atIndex:0];
    [self.dialView2 loadInitialLabel];
    [self.view addSubview:self.dialView3];
    [self.dialView3 insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DialBottomBackgroundImage.png"]] atIndex:0];
    [self.dialView3 loadInitialLabel];
    [super viewDidLoad];
}

#pragma mark - Getters

- (MVDialView*)dialView2 {
    if(!_dialView2) {
        _dialView2 = [[MVDialView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dialView1.frame), 320, 44)];
        _dialView2.dataSource = self;
        _dialView2.delegate = self;
    }
    return _dialView2;
}

- (MVDialView*)dialView3 {
    if(!_dialView3) {
        _dialView3 = [[MVDialView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dialView2.frame), 320, 44)];
        _dialView3.dataSource = self;
        _dialView3.delegate = self;
    }
    return _dialView3;
}

#pragma mark - MVDialViewDataSource

- (UILabel*)labelForColumn:(NSInteger)column dial:(MVDialView *)dialView {
    UILabel* label = nil;
    if(dialView == self.dialView1) {
        NSDateComponents* c1 = [[NSDateComponents alloc] init];
        c1.day = column;
        NSDate* newDate = [[NSCalendar currentCalendar] dateByAddingComponents:c1 toDate:NSDate.date options:0];

        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEE MMM dd, yyyy"];
        NSString* ds = [df stringFromDate:newDate];

        UIFont* font = [UIFont boldSystemFontOfSize:16];
        CGSize size = [ds sizeWithFont:font];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        label.text = ds;
        label.tag = column;
        label.font = font;
    } else if(dialView == self.dialView2) {
        NSInteger dataArrayCount = self.dataArray.count;
        NSInteger index = column % dataArrayCount;
        if(index < 0) index += self.dataArray.count;
        NSString* labelString = self.dataArray[index];
        label = [[UILabel alloc] init];
        label.text = labelString;
        label.tag = column;
    } else if(dialView == self.dialView3) {
        NSDateComponents* c1 = [[NSDateComponents alloc] init];
        c1.day = column;
        NSDate* newDate = [[NSCalendar currentCalendar] dateByAddingComponents:c1 toDate:NSDate.date options:0];

        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEE MMM dd, yyyy"];
        NSString* ds = [df stringFromDate:newDate];

        UIFont* font = [UIFont boldSystemFontOfSize:16];
        CGSize size = [ds sizeWithFont:font];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        label.text = ds;
        label.tag = column;
        label.font = font;
    }
    return label;
}

#pragma mark - MVDialViewDelegate

- (void)didSelectColumn:(NSInteger)column dial:(MVDialView *)dial {
    if(dial == self.dialView1) {
        NSDateComponents* c1 = [[NSDateComponents alloc] init];
        c1.day = column;
        NSDate* newDate = [[NSCalendar currentCalendar] dateByAddingComponents:c1 toDate:NSDate.date options:0];

        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEE MMM dd, yyyy"];
        NSString* ds = [df stringFromDate:newDate];
        self.navigationItem.title = ds;
    } else if(dial == self.dialView2) {
        NSInteger dataArrayCount = self.dataArray.count;
        NSInteger index = column % dataArrayCount;
        if(index < 0) index += self.dataArray.count;
        NSString* labelString = self.dataArray[index];
        [[[UIAlertView alloc] initWithTitle:nil message:labelString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if(dial == self.dialView3) {
        NSDateComponents* c1 = [[NSDateComponents alloc] init];
        c1.day = column;
        NSDate* newDate = [[NSCalendar currentCalendar] dateByAddingComponents:c1 toDate:NSDate.date options:0];

        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEE MMM dd, yyyy"];
        NSString* ds = [df stringFromDate:newDate];
        self.dial3SelectLabel.text = ds;
    }
}

@end
