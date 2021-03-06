//
//  UserCardTableCell.m
//  iphoneduiai
//
//  Created by Cloud Dai on 12-9-24.
//  Copyright (c) 2012年 duiai.com. All rights reserved.
//

#import "UserCardTableCell.h"
#import "Utils.h"

@interface UserCardTableCell ()

@property (strong, nonatomic) NSArray *arry;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel, *contentLabel;

@end

@implementation UserCardTableCell

- (void)dealloc
{
    self.delegate = nil;
    [_arry release];
    [_timeLabel release];
    [_contentLabel release];
    [_leftCard release];
    [_middleCard release];
    [_rightCard release];
    [_users release];
    [super dealloc];
}

- (void)awakeFromNib
{
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(gestureAction:)] autorelease];
    UITapGestureRecognizer *tap2 = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(gestureAction:)] autorelease];
    UITapGestureRecognizer *tap3 = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(gestureAction:)] autorelease];
    [self.leftCard addGestureRecognizer:tap];
    [self.middleCard addGestureRecognizer:tap2];
    [self.rightCard addGestureRecognizer:tap3];
}

- (NSArray *)arry
{
    if (_arry == nil) {
        _arry = [[NSArray alloc] initWithArray:@[self.leftCard, self.middleCard, self.rightCard]];
    }
    
    return _arry;
}

- (void)setUsers:(NSArray *)users
{
    if (![_users isEqualToArray:users]) {
        _users = [users retain];
        
        for (int i=0; i< MIN(users.count, self.arry.count); i++) {
            UserCardView *view = [self.arry objectAtIndex:i];
            NSDictionary *user = [users objectAtIndex:i];
            view.hidden = NO;
            
            if ([user[@"photo"] isEqualToString:@""]) {
                [view.imageView loadImage:DEFAULTAVATAR];
            } else{
                [view.imageView loadImage:user[@"photo"]];
            }
            
            if ([user[@"photocount"] integerValue] > 0) {
                view.picNumLabel.hidden = NO;

                view.picNumLabel.text = [NSString stringWithFormat:@"%@P", [user objectForKey:@"photocount"]];
            } else{
                view.picNumLabel.hidden = YES;
            }
            
            NSString *desc = @"";
            if ([user[@"distance"] floatValue] > 0) {
                desc = [[Utils descriptionForDistance:[user[@"distance"] intValue]] stringByAppendingString:@" "];
            }

            view.infoLabel.text = [desc stringByAppendingString: [NSString stringWithFormat:@"%@岁 %@cm",
                                   [user objectForKey:@"age"], [user objectForKey:@"height"]]];
        }
        
        for (int i=users.count; i<self.arry.count; i++) {
            UserCardView *view = [self.arry objectAtIndex:i];
            view.hidden = YES;
        }
    }
}

- (void)gestureAction:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged ||
        gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateBegan) {
        // something
        
        CGSize size = gesture.view.frame.size;
        UIView *coverView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)] autorelease];
        coverView.backgroundColor = RGBACOLOR(0, 0, 0, 0.35);
        [gesture.view addSubview:coverView];
        
//        int64_t delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            [coverView removeFromSuperview];
        });
        
        NSString *pos = [NSString stringWithFormat:@"%d", [self.arry indexOfObject:gesture.view]];

        if ([self.delegate respondsToSelector:@selector(didChangeStatus:toStatus:)]) {
            [self.delegate didChangeStatus:self toStatus:pos];
        }
    }
}

@end
