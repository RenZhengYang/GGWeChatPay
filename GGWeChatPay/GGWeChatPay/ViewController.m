//
//  ViewController.m
//  LQQWeChatDemo
//
//  Created by Artron_LQQ on 16/2/29.
//  Copyright © 2016年 Artup. All rights reserved.
//

#import "ViewController.h"
#import "WechatPayViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (retain,nonatomic)UITableView *myTableView;
@property (retain,nonatomic)NSMutableArray *myDataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _myTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    
    [self.view addSubview:_myTableView];
    
    _myDataArray = [[NSMutableArray alloc]init];
    
    [_myDataArray addObject:@"wechatPay"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.myDataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    
    cell.textLabel.text = [self.myDataArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        WechatPayViewController *pay = [[WechatPayViewController alloc]init];
        
        [[[UIApplication sharedApplication]delegate]window].rootViewController = pay;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
