//
//  MainViewController.m
//  DaiLive2DPlayground
//
//  Created by DaidoujiChen on 2015/12/31.
//  Copyright © 2015年 DaidoujiChen. All rights reserved.
//

#import "MainViewController.h"
#import "CustomViewController.h"
#import "OfficalViewController.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainViewController

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Custom - Haru";
            break;
            
        case 1:
            cell.textLabel.text = @"Custom - Wanko";
            break;
            
        case 2:
            cell.textLabel.text = @"Custom - Miku";
            break;
            
        case 3:
            cell.textLabel.text = @"Offical - Haru";
            break;
            
        case 4:
            cell.textLabel.text = @"Offical - Haru01";
            break;
            
        case 5:
            cell.textLabel.text = @"Offical - Haru02";
            break;
            
        case 6:
            cell.textLabel.text = @"Offical - Wanko";
            break;
            
        case 7:
            cell.textLabel.text = @"Offical - Shizuku";
            break;
            
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            CustomViewController *customViewController = [CustomViewController new];
            customViewController.type = CustomTypeHaru;
            [self.navigationController pushViewController:customViewController animated:YES];
            break;
        }
            
        case 1:
        {
            CustomViewController *customViewController = [CustomViewController new];
            customViewController.type = CustomTypeWanko;
            [self.navigationController pushViewController:customViewController animated:YES];
            break;
        }
            
        case 2:
        {
            CustomViewController *customViewController = [CustomViewController new];
            customViewController.type = CustomTypeMiku;
            [self.navigationController pushViewController:customViewController animated:YES];
            break;
        }
            
        case 3:
        {
            OfficalViewController *officalViewController = [OfficalViewController new];
            officalViewController.type = OfficalTypeHaru;
            [self.navigationController pushViewController:officalViewController animated:YES];
            break;
        }
            
        case 4:
        {
            OfficalViewController *officalViewController = [OfficalViewController new];
            officalViewController.type = OfficalTypeHaru01;
            [self.navigationController pushViewController:officalViewController animated:YES];
            break;
        }
            
        case 5:
        {
            OfficalViewController *officalViewController = [OfficalViewController new];
            officalViewController.type = OfficalTypeHaru02;
            [self.navigationController pushViewController:officalViewController animated:YES];
            break;
        }
            
        case 6:
        {
            OfficalViewController *officalViewController = [OfficalViewController new];
            officalViewController.type = OfficalTypeWanko;
            [self.navigationController pushViewController:officalViewController animated:YES];
            break;
        }
            
        case 7:
        {
            OfficalViewController *officalViewController = [OfficalViewController new];
            officalViewController.type = OfficalTypeShizuku;
            [self.navigationController pushViewController:officalViewController animated:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Live Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

@end
