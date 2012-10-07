//
//  ProfileListViewController.m
//  iphoneduiai
//
//  Created by Cloud Dai on 12-9-8.
//  Copyright (c) 2012年 duiai.com. All rights reserved.
//

#import "ProfileListViewController.h"
#import "CustomBarButtonItem.h"
#import "SettingViewController.h"
#import "SeniorViewController.h"
#import "Utils.h"
#import <RestKit/RestKit.h>
#import <RestKit/JSONKit.h>
#import "SVProgressHUD.h"
#import "ShowPhotoView.h"
#import "AvatarView.h"
#import "MarrayReqView.h"
#import "MoreUserInfoView.h"
#import "WeiyuWordCell.h"

static CGFloat dHeight = 0.0f;
static CGFloat dHeight2 = 0.0f;
static NSInteger kActionChooseImageTag = 201;

@interface ProfileListViewController () <CustomCellDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ShowPhotoDelegate>

@property (retain, nonatomic) IBOutlet ShowPhotoView *showPhotoView;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSDictionary *userInfo, *userBody, *userLife, *userInterest, *userWork, *marrayReq, *searchIndex;
@property (retain, nonatomic) IBOutlet UILabel *nameAgeLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeDistanceLabel;

@property (retain, nonatomic) IBOutlet UITextField *incomeField, *areaField, *heightField, *weightField, *degreeField, *careerField;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UILabel *phoneLabel;
@property (retain, nonatomic) IBOutlet UIImageView *phoneImageView;
@property (retain, nonatomic) IBOutlet UIButton *snsbtn0;
@property (retain, nonatomic) IBOutlet UIButton *snsbtn1;
@property (retain, nonatomic) IBOutlet UIButton *snsbtn2;
@property (retain, nonatomic) IBOutlet MoreUserInfoView *moreUserInfoView;
@property (retain, nonatomic) IBOutlet MarrayReqView *marrayReqView;
@property (retain, nonatomic) IBOutlet UIView *move2View;
@property (retain, nonatomic) IBOutlet UIView *move1View;
@property (retain, nonatomic) IBOutlet UILabel *dySexLabel;
@property (retain, nonatomic) IBOutlet CountView *countView;
@property (retain, nonatomic) IBOutlet UIView *basicView;
@property (retain, nonatomic) IBOutlet UIView *snsBtnView;
@property (retain, nonatomic) IBOutlet UIView *moreView;
@property (retain, nonatomic) IBOutlet UIView *nameView;
@property (retain, nonatomic) IBOutlet UIView *posView;
@property (retain, nonatomic) IBOutlet UIView *mobileView;
@property (retain, nonatomic) IBOutlet UIView *careerView;

@property (strong, nonatomic) NSMutableArray *weiyus;
@property (strong, nonatomic) UITableViewCell *moreCell;
@property (nonatomic) NSInteger curPage, totalPage;
@property (nonatomic) BOOL loading;
@property (retain, nonatomic) IBOutlet UIView *editorBtnsView;
@property (retain, nonatomic) IBOutlet UIImageView *img1;
@property (retain, nonatomic) IBOutlet UIImageView *img2;
@property (retain, nonatomic) IBOutlet UIImageView *img3;
@property (retain, nonatomic) IBOutlet UIImageView *img4;
@property (retain, nonatomic) IBOutlet UIImageView *img5;
@property (retain, nonatomic) IBOutlet UIImageView *img6;

@property (strong, nonatomic) UIBarButtonItem *cancelBarItem, *saveBarItem, *settingBarItem, *changeBaritem;
@property (nonatomic) BOOL isUploadPhoto;

@end

@implementation ProfileListViewController

- (void)dealloc
{
    [_photos release];
    [_showPhotoView release];
    [_avatarView release];
    [_userInfo release];
    [_nameAgeLabel release];
    [_timeDistanceLabel release];
    [_heightField release];
    [_areaField release];
    [_incomeField release];
    [_weightField release];
    [_degreeField release];
    [_careerField release];
    [_addressLabel release];
    [_phoneLabel release];
    [_phoneImageView release];
    [_userBody release];
    [_userLife release];
    [_userInterest release];
    [_userWork release];
    [_marrayReq release];
    [_snsbtn0 release];
    [_snsbtn1 release];
    [_snsbtn2 release];
    [_marrayReqView release];
    [_move2View release];
    [_move1View release];
    [_dySexLabel release];
    [_moreUserInfoView release];
    [_weiyus release];
    [_moreCell release];
    [_countView release];
    [_searchIndex release];
    [_editorBtnsView release];
    [_basicView release];
    [_snsBtnView release];
    [_moreView release];
    [_nameView release];
    [_posView release];
    [_mobileView release];
    [_careerView release];
    [_img1 release];
    [_img2 release];
    [_img3 release];
    [_img4 release];
    [_img5 release];
    [_img6 release];
    [super dealloc];
}

- (void)setSearchIndex:(NSDictionary *)searchIndex
{
    if (![_searchIndex isEqualToDictionary:searchIndex]) {
        _searchIndex = [searchIndex retain];
        
        self.timeDistanceLabel.text = [NSString stringWithFormat:@"%@/900m", [Utils descriptionForTime:[NSDate dateWithTimeIntervalSince1970:[[searchIndex objectForKey:@"acctime"] integerValue]]]];
        self.countView.count = [[searchIndex objectForKey:@"digocount"] description];
    }
}

- (void)setWeiyus:(NSMutableArray *)weiyus
{
    if (![_weiyus isEqualToArray:weiyus]) {
        if (self.curPage > 1) {
            [_weiyus addObjectsFromArray:weiyus];
        } else{
            _weiyus = [[NSMutableArray alloc] initWithArray:weiyus];
        }
        
        [self.tableView reloadData];
    }
}

- (void)setMarrayReq:(NSDictionary *)marrayReq
{
    if (![_marrayReq isEqualToDictionary:marrayReq]) {
        _marrayReq = [marrayReq retain];
        self.marrayReqView.marrayReq = marrayReq;
    }
}

- (void)setUserInterest:(NSDictionary *)userInterest
{
    if (![_userInterest isEqualToDictionary:userInterest]) {
        _userInterest = [userInterest retain];
        self.moreUserInfoView.moreUserInfo = userInterest;
    }
}

- (void)setPhotos:(NSMutableArray *)photos
{
    if (![_photos isEqualToArray:photos]) {
        _photos = [photos retain];
        self.showPhotoView.photos = photos;
    }
}

- (void)setUserInfo:(NSDictionary *)userInfo
{
    if (![_userInfo isEqualToDictionary:userInfo]) {
        _userInfo = [userInfo retain];
        
        self.avatarView.sex = [userInfo objectForKey:@"sex"];
        [self.avatarView.imageView loadImage:[userInfo objectForKey:@"photo"]];
        self.nameAgeLabel.text = [NSString stringWithFormat:@"%@, %@岁", [userInfo objectForKey:@"niname"], [userInfo objectForKey:@"age"]];
        
        self.heightField.text = [NSString stringWithFormat:@"%@cm", [userInfo objectForKey:@"height"]];
        self.areaField.text = [userInfo objectForKey:@"area"];
        self.incomeField.text = [userInfo objectForKey:@"income"];
        self.degreeField.text = [userInfo objectForKey:@"degree"];
        self.careerField.text = [userInfo objectForKey:@"industry"];
        
        self.dySexLabel.text = @"我的动态"/*[NSString stringWithFormat:@"%@的动态", [userInfo objectForKey:@"ta"]]*/;
        
        self.navigationItem.title = [userInfo objectForKey:@"niname"];
    }
}

- (void)setUserBody:(NSDictionary *)userBody
{
    if (![_userBody isEqualToDictionary:userBody]) {
        _userBody = [userBody retain];
        
        self.weightField.text = [userBody objectForKey:@"weight"];
    }
}

- (void)viewDidUnload
{

    [self setShowPhotoView:nil];
    [self setAvatarView:nil];
    [self setNameAgeLabel:nil];
    [self setTimeDistanceLabel:nil];
    [self setHeightField:nil];
    [self setAreaField:nil];
    [self setIncomeField:nil];
    [self setWeightField:nil];
    [self setDegreeField:nil];
    [self setCareerField:nil];
    [self setAddressLabel:nil];
    [self setPhoneLabel:nil];
    [self setPhoneImageView:nil];
    [self setSnsbtn0:nil];
    [self setSnsbtn1:nil];
    [self setSnsbtn2:nil];
    [self setMarrayReqView:nil];
    [self setMove2View:nil];
    [self setMove1View:nil];
    [self setDySexLabel:nil];
    [self setMoreUserInfoView:nil];
    
    [self setCountView:nil];
    [self setEditorBtnsView:nil];
    [self setBasicView:nil];
    [self setSnsBtnView:nil];
    [self setMoreView:nil];
    [self setNameView:nil];
    [self setPosView:nil];
    [self setMobileView:nil];
    [self setCareerView:nil];
    [self setImg1:nil];
    [self setImg2:nil];
    [self setImg3:nil];
    [self setImg4:nil];
    [self setImg5:nil];
    [self setImg6:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dHeight = self.marrayReqView.frame.size.height;
    dHeight2 = self.moreUserInfoView.frame.size.height;
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.changeBaritem = [[[CustomBarButtonItem alloc] initRightBarButtonWithTitle:@"转"target:self action:@selector(settingModeAction)] autorelease];
    self.cancelBarItem = [[[CustomBarButtonItem alloc] initRightBarButtonWithTitle:@"取消"target:self action:@selector(cancelModeAction)] autorelease];
    self.saveBarItem = [[[CustomBarButtonItem alloc] initRightBarButtonWithTitle:@"保存"target:self action:@selector(saveAction)] autorelease];
    self.settingBarItem = [[[CustomBarButtonItem alloc] initRightBarButtonWithTitle:@"设置"target:self action:@selector(settingAction)] autorelease];
    self.navigationItem.leftBarButtonItem = self.changeBaritem;
    self.navigationItem.rightBarButtonItem = self.settingBarItem;
    
    self.showPhotoView.delegate = self;
    
    [self grabUserInfoDetailRequest];
    [self grabMyWeiyuListReqeustWithPage:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)saveAction
{
    // do some save here
    
    [self cancelModeAction];
}

- (void)settingModeAction
{

    [self.tableView setEditing:YES animated:YES];

    [self changeToEditingView];

    self.navigationItem.leftBarButtonItem = self.cancelBarItem;
    self.navigationItem.rightBarButtonItem = self.saveBarItem;
}

- (void)cancelModeAction
{
    [self.tableView setEditing:NO animated:YES];
    
    [self changeToNonEditingView];
    
    self.navigationItem.leftBarButtonItem = self.changeBaritem;
    self.navigationItem.rightBarButtonItem = self.settingBarItem;
}

- (void)settingAction
{
    
    SettingViewController *settingViewController = [[[SettingViewController alloc]initWithStyle:UITableViewStylePlain] autorelease];
    [self.navigationController pushViewController:settingViewController animated:YES];
    
}

- (void)changeToEditingView
{
    // remove some things
    [self.nameView removeFromSuperview];
    [self.moreView removeFromSuperview];
    [self.move1View removeFromSuperview];
    [self.snsBtnView removeFromSuperview];
    [self.posView removeFromSuperview];
    [self.mobileView removeFromSuperview];
    
    self.heightField.enabled = YES;
    self.incomeField.enabled = YES;
    self.degreeField.enabled = YES;
    self.areaField.enabled = YES;
    self.weightField.enabled = YES;
    self.careerField.enabled = YES;
    
    self.img1.hidden = NO;
    self.img2.hidden = NO;
    self.img3.hidden = NO;
    self.img4.hidden = NO;
    self.img5.hidden = NO;
    self.img6.hidden = NO;
    
    // add some
    self.editorBtnsView.frame = CGRectMake(self.nameView.frame.origin.x, self.nameView.frame.origin.y, self.editorBtnsView.frame.size.width, self.editorBtnsView.frame.size.height);
    // move some
    CGRect basicFrame = self.basicView.frame;
    basicFrame.origin.y = self.editorBtnsView.frame.origin.y + self.editorBtnsView.frame.size.height + 20;
    basicFrame.size.height = self.careerView.frame.origin.y + self.careerView.frame.size.height + 1;
    self.basicView.frame = basicFrame;
    // add ...
    [self.tableView.tableHeaderView addSubview:self.editorBtnsView];
    
    CGRect move2Frame = self.move2View.frame;
    move2Frame.origin.y = self.basicView.frame.origin.y + self.basicView.frame.size.height + 20;
    self.move2View.frame = move2Frame;
    
    UIView *headerView = self.tableView.tableHeaderView;
    CGRect frame = headerView.frame;
    frame.size.height = self.move2View.frame.origin.y + self.move2View.frame.size.height + 10;
    headerView.frame = frame;
    self.tableView.tableHeaderView = headerView;
    
    // avatar
    self.avatarView.editing = YES;
    // show images
    self.showPhotoView.editing = YES;
}

- (void)changeToNonEditingView
{
   // add some
    [self.editorBtnsView removeFromSuperview];
    
    [self.tableView.tableHeaderView addSubview:self.nameView];
    [self.tableView.tableHeaderView addSubview:self.moreView];
    [self.tableView.tableHeaderView addSubview:self.move1View];
    [self.tableView.tableHeaderView addSubview:self.snsBtnView];
    [self.basicView addSubview:self.posView];
    [self.basicView addSubview:self.mobileView];
    
    self.heightField.enabled = NO;
    self.incomeField.enabled = NO;
    self.degreeField.enabled = NO;
    self.areaField.enabled = NO;
    self.weightField.enabled = NO;
    self.careerField.enabled = NO;
    
    self.img1.hidden = YES;
    self.img2.hidden = YES;
    self.img3.hidden = YES;
    self.img4.hidden = YES;
    self.img5.hidden = YES;
    self.img6.hidden = YES;
    
    // move some
    CGRect basicFrame = self.basicView.frame;
    basicFrame.origin.y = self.nameView.frame.origin.y + self.nameView.frame.size.height + 20;
    basicFrame.size.height = self.mobileView.frame.origin.y + self.mobileView.frame.size.height + 1;
    self.basicView.frame = basicFrame;
    
    CGRect move2Frame = self.move2View.frame;
    move2Frame.origin.y = self.move1View.frame.origin.y + self.move1View.frame.size.height + 20;
    self.move2View.frame = move2Frame;
    
    UIView *headerView = self.tableView.tableHeaderView;
    CGRect frame = headerView.frame;
    frame.size.height = self.move2View.frame.origin.y + self.move2View.frame.size.height + 10;
    headerView.frame = frame;
    self.tableView.tableHeaderView = headerView;
    
    // avatar
    self.avatarView.editing = NO;
    // showimages
    self.showPhotoView.editing = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.heightField resignFirstResponder];
    [self.incomeField resignFirstResponder];
    [self.degreeField resignFirstResponder];
    [self.areaField resignFirstResponder];
    [self.weightField resignFirstResponder];
    [self.careerField resignFirstResponder];
    

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.totalPage <= self.curPage) {
        return self.weiyus.count;
    } else{
        return self.weiyus.count + 1;
    }
    
}

-(UITableViewCell *)createMoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moretag"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UILabel *labelNumber = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 100, 20)];
    labelNumber.textAlignment = UITextAlignmentCenter;
    
    if (self.totalPage <= self.curPage){
        labelNumber.text = @"";
    } else {
        labelNumber.text = @"更多";
    }
    
	[labelNumber setTag:1];
	labelNumber.backgroundColor = [UIColor clearColor];
	labelNumber.font = [UIFont boldSystemFontOfSize:18];
	[cell.contentView addSubview:labelNumber];
	[labelNumber release];
	
    self.moreCell = cell;
    
    return self.moreCell;
}

- (UITableViewCell *)creatNormalCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"weiyuWordCell";
    WeiyuWordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:2];
        cell.delegate = self;
    }
    
    // Configure the cell...
    cell.weiyu = [self.weiyus objectAtIndex:indexPath.row];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.weiyus.count) {
        return [self createMoreCell:tableView cellForRowAtIndexPath:indexPath];
    }else {
        return [self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.weiyus.count) {
        
        return 40.0f;
    }else {
        WeiyuWordCell *cell = (WeiyuWordCell *)[self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
        return [cell requiredHeight];
        
    }
}

- (void)loadNextInfoList
{
    UILabel *label = (UILabel*)[self.moreCell.contentView viewWithTag:1];
    label.text = @"正在加载..."; // bug no reload table not show it.
    
    if (!self.loading) {
        [self grabMyWeiyuListReqeustWithPage:self.curPage+1];
        self.loading = YES;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.weiyus.count) {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadNextInfoList];
        });
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.weiyus.count == indexPath.row) {
        return NO;
    }
    
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableDictionary *weiyu = self.weiyus[indexPath.row];

        NSMutableDictionary *dParams = [Utils queryParams];
        [dParams setObject:weiyu[@"id"] forKey:@"id"];
        [SVProgressHUD show];
        [[RKClient sharedClient] get:[@"/v/delete.api" stringByAppendingQueryParameters:dParams] usingBlock:^(RKRequest *request){
            [request setOnDidFailLoadWithError:^(NSError *error){
                NSLog(@"delete weiyu error: %@", [error description]);
                [SVProgressHUD showErrorWithStatus:@"网络链接错误"];
            }];
            [request setOnDidLoadResponse:^(RKResponse *response){
                if (response.isOK && response.isJSON) {
                    NSDictionary *data = [[response bodyAsString] objectFromJSONString];
                    NSInteger code = [data[@"error"] integerValue];
                    if (code == 0) {
                        [self.weiyus removeObject:weiyu];
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [SVProgressHUD dismiss];
                    } else{
                        [SVProgressHUD showErrorWithStatus:data[@"message"]];
                    }
                } else{
                    [SVProgressHUD showErrorWithStatus:@"错误返回"];
                }
            }];
        }];
        
    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)grabUserInfoDetailRequest
{
    NSMutableDictionary *dParams = [Utils queryParams];
    NSDictionary *info = [[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] objectForKey:@"info"];
    NSLog(@"user info: %@", info);
    [dParams setObject:[info objectForKey:@"uid"] forKey:@"uid"];
    
    [[RKClient sharedClient] get:[@"user" stringByAppendingQueryParameters:dParams] usingBlock:^(RKRequest *request){
        [request setOnDidLoadResponse:^(RKResponse *response){
            if (response.isOK && response.isJSON) {
                NSMutableDictionary *data = [[response bodyAsString] mutableObjectFromJSONString];
                NSLog(@"data: %@", data);
                NSInteger code = [[data objectForKey:@"error"] integerValue];
                if (code == 0) {
                    NSDictionary *dataData = [data objectForKey:@"data"];
                    self.photos = [dataData objectForKey:@"photo"];
                    self.userInfo = [dataData objectForKey:@"user_info"];
                    self.userBody = [dataData objectForKey:@"user_body"];
                    self.userLife = [dataData objectForKey:@"user_life"];
                    self.userInterest = [dataData objectForKey:@"user_interest"];
                    self.userWork = [dataData objectForKey:@"user_work"];
                    self.marrayReq = [dataData objectForKey:@"marray_req"];
                    self.searchIndex = [dataData objectForKey:@"searchindex"];
                } else{
                    [SVProgressHUD showErrorWithStatus:data[@"message"]];
                }

            }
        }];
        
        [request setOnDidFailLoadWithError:^(NSError *error){
            NSLog(@"error: %@", [error description]);
        }];
        
    }];
}

- (void)grabMyWeiyuListReqeustWithPage:(NSInteger)page
{
    NSMutableDictionary *dParams = [Utils queryParams];
    //    [dParams setObject:@"photo" forKey:@"a"];
    [dParams setObject:@"myv" forKey:@"a"];
    [dParams setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    [dParams setObject:@"10" forKey:@"pagesize"];
    
    [[RKClient sharedClient] get:[@"/v" stringByAppendingQueryParameters:dParams] usingBlock:^(RKRequest *request){
        [request setOnDidLoadResponse:^(RKResponse *response){
            if (response.isOK && response.isJSON) {
                NSMutableDictionary *data = [[response bodyAsString] mutableObjectFromJSONString];
                NSLog(@"my weiyu data: %@", data);
                if (![[data objectForKey:@"data"] isKindOfClass:[NSString class]]) {
                    self.loading = NO;
                    self.totalPage = [[[data objectForKey:@"pager"] objectForKey:@"pagecount"] integerValue];
                    self.curPage = [[[data objectForKey:@"pager"] objectForKey:@"thispage"] integerValue];
                    // 此行须在前两行后面
                    self.weiyus = [data objectForKey:@"data"];
                }
            }
        }];
        
        [request setOnDidFailLoadWithError:^(NSError *error){
            NSLog(@"error: %@", [error description]);
        }];
        
    }];
}

- (IBAction)moreDetailAction:(UIButton *)sender
{
    
    if (sender.tag == 0) {
        UIView *view = sender.superview;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect move1 = self.move1View.frame;
            CGRect move2 = self.move2View.frame;
            move1.origin.y += dHeight2;
            move2.origin.y += dHeight2;
            self.move1View.frame = move1;
            self.move2View.frame = move2;
            
            UIView *headerView = self.tableView.tableHeaderView;
            CGRect frame = headerView.frame;
            frame.size.height += dHeight2;
            headerView.frame = frame;
            self.tableView.tableHeaderView = headerView;
            
            if ([self.marrayReqView superview] != nil) {
                CGRect marray = self.marrayReqView.frame;
                marray.origin.y += dHeight2;
                self.marrayReqView.frame = marray;
            }
            
        }];
        [self.moreUserInfoView showMeInView:self.tableView.tableHeaderView
                                    atPoint:CGPointMake(view.frame.origin.x, view.frame.origin.y+view.frame.size.height)
                                   animated:YES];
        
        
        sender.tag = 1;
    } else{
        [self.moreUserInfoView removeMeWithAnimated:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect move1 = self.move1View.frame;
            CGRect move2 = self.move2View.frame;
            move1.origin.y -= dHeight2;
            move2.origin.y -= dHeight2;
            self.move1View.frame = move1;
            self.move2View.frame = move2;
            
            UIView *headerView = self.tableView.tableHeaderView;
            CGRect frame = headerView.frame;
            frame.size.height -= dHeight2;
            headerView.frame = frame;
            self.tableView.tableHeaderView = headerView;
            
            if ([self.marrayReqView superview] != nil) {
                CGRect marray = self.marrayReqView.frame;
                marray.origin.y -= dHeight2;
                self.marrayReqView.frame = marray;
            }
        }];
        sender.tag = 0;
    }
    
}

- (IBAction)friendConditionAction:(UIButton *)sender
{
    
    if (sender.tag == 0) {
        UIView *view = sender.superview;
        [UIView animateWithDuration:0.3 animations:^{
            //            CGRect move1 = self.move1View.frame;
            CGRect move2 = self.move2View.frame;
            //            move1.origin.y += dHeight;
            move2.origin.y += dHeight;
            //            self.move1View.frame = move1;
            self.move2View.frame = move2;
            
            UIView *headerView = self.tableView.tableHeaderView;
            CGRect frame = headerView.frame;
            frame.size.height += dHeight;
            headerView.frame = frame;
            self.tableView.tableHeaderView = headerView;
            
        }];
        [self.marrayReqView showMeInView:self.tableView.tableHeaderView
                                 atPoint:CGPointMake(view.frame.origin.x, view.frame.origin.y+view.frame.size.height)
                                animated:YES];
        
        
        sender.tag = 1;
    } else{
        [self.marrayReqView removeMeWithAnimated:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            //            CGRect move1 = self.move1View.frame;
            CGRect move2 = self.move2View.frame;
            //            move1.origin.y += dHeight;
            move2.origin.y -= dHeight;
            //            self.move1View.frame = move1;
            self.move2View.frame = move2;
            
            UIView *headerView = self.tableView.tableHeaderView;
            CGRect frame = headerView.frame;
            frame.size.height -= dHeight;
            headerView.frame = frame;
            self.tableView.tableHeaderView = headerView;
        }];
        sender.tag = 0;
    }
    
}

#pragma mark - cell delegate
- (void)didChangeStatus:(UITableViewCell *)cell toStatus:(NSString *)status
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"weiyu data: %@", [self.weiyus objectAtIndex:indexPath.row]);
    NSLog(@"status: %@", status);
}

- (IBAction)contractAction
{
    NSLog(@"contract...");
}

- (IBAction)bindingAction
{
    NSLog(@"binding...");
}

- (IBAction)seniorAction
{
   
    SeniorViewController *seniorViewController = [[[SeniorViewController alloc]initWithStyle:UITableViewStylePlain] autorelease];
    [self.navigationController pushViewController:seniorViewController animated:YES];
}

- (IBAction)friendAction
{
    NSLog(@"friend...");
}

- (IBAction)uploadAvatarAction
{
    // upload
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"从资源库",@"拍照",nil];
        actionSheet.tag=kActionChooseImageTag;
        [actionSheet showInView:self.view.window];
        [actionSheet release];
        
    } else {
        
        UIImagePickerController *picker = [[[UIImagePickerController alloc] init]autorelease];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        if (!self.isUploadPhoto) {
            picker.allowsEditing = YES;
        }

        [self presentModalViewController:picker animated:YES];
    }
}

#pragma mark - ActionSheet Delegate Methods
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([actionSheet cancelButtonIndex] == buttonIndex) {
        return;
    }
    
    if (actionSheet.tag==kActionChooseImageTag) {
        UIImagePickerController* imagePickerController = [[[UIImagePickerController alloc] init]autorelease];
        
        if (buttonIndex == 0)
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        else  if(buttonIndex==1)
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        
        imagePickerController.delegate=self;
        if (!self.isUploadPhoto) {
            imagePickerController.allowsEditing = YES;
        }
        [self presentModalViewController: imagePickerController
                                animated: YES];
    }else{
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            NSDictionary *photo = [self.showPhotoView.photos objectAtIndex:actionSheet.tag];
            [Utils deleteImage:photo[@"pid"] block:^{
                [self.showPhotoView removePhotoAt:actionSheet.tag];
            }];
        }
    }
}

#pragma mark –  Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /*添加处理选中图像代码*/
    if (self.isUploadPhoto) {
         NSData *data = UIImagePNGRepresentation([Utils thumbnailWithImage:[info objectForKey:UIImagePickerControllerOriginalImage] size:CGSizeMake(640, 960)]);
        [Utils uploadImage:data type:@"userphoto" block:^(NSMutableDictionary *res){
            if (res) {
                [self.showPhotoView insertPhoto:res atIndex:1];
                [self.showPhotoView selectRoundAt:1];
            }
        }];
        self.isUploadPhoto = NO;
        
    } else{
         NSData *data = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerEditedImage]);
        [Utils uploadImage:data type:@"userface" block:^(NSDictionary *res){

            if (res) {
                self.avatarView.imageView.image = [UIImage imageWithData:data];
            }
        }];
    }

    [picker dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
     self.isUploadPhoto = NO;
}

#pragma mark - show photo delegate
- (void)didTriggerAddPhotoAction:(ShowPhotoView *)view
{
    self.isUploadPhoto = YES;
    [self uploadAvatarAction];
}

- (void)didTriggerDelPhotoAction:(ShowPhotoView *)view at:(NSInteger)index
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"删除照片"
                                  otherButtonTitles:nil];
    actionSheet.tag=index;
    [actionSheet showInView:self.view.window];
    [actionSheet release];
}

@end