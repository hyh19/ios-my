//
//  FBTestProtocolViewController.m
//  LiveShow
//
//  Created by chenfanshun on 23/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBTestProtocolViewController.h"
#import "FBLiveProtocolManager.h"

@interface FBTestProtocolViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)NSArray*        items;

@end

//rtmp：内部服务器rtmp协议
//soup：内部服务器soup协议
//hls：内部服务器hls协议
//aws-hls：亚马逊cdn的hls协议
//akamai-rtmp：阿卡麦cdn的rtmp协议

@implementation FBTestProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = @[@"rtmp", @"hls", @"aws-hls", @"cnc-hls", @"akamai-rtmp"];
    
    [self configUI];
}

-(void)configUI
{
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate & datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* uniqueCellID = @"uniqueCellID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:uniqueCellID];
    if(nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:uniqueCellID];
    }
    NSInteger row = indexPath.row;
    if(row < [self.items count]) {
        NSString* protocol = self.items[row];
        if([protocol isEqualToString:[[FBLiveProtocolManager sharedInstance] getFroceProtocol]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = self.items[row];
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if(row < [self.items count]) {
        NSString* protocol = self.items[row];
        [[FBLiveProtocolManager sharedInstance] setForceProtocol:protocol];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
