
#import "ZWSelectAreaView.h"
#import "AppDelegate.h"

#define WINDOW_COLOR                            [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]

#define HIGHT                            263

@interface ZWSelectAreaView ()<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSArray *provinces, *cities, *areas;
}

/**背景视图*/
@property (nonatomic, strong) UIView *backGroundView;

/**选择区域结果回调*/
@property (nonatomic, strong) ZWSelectAreaResultBlock areaResultBlock;

@property (strong, nonatomic) UIPickerView *areaPickerView;

@property (nonatomic, strong)NSString *selectProvince;
@property (nonatomic, strong)NSString *selectCity;
@property (nonatomic, strong)NSString *selectArea;

@end

@implementation ZWSelectAreaView

- (void)initSelectAreaViewWithSelectResult:(ZWSelectAreaResultBlock)areaResult
{
    ZWSelectAreaView *areaView = [super init];
    if (areaView) {
        
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = WINDOW_COLOR;
        self.userInteractionEnabled = YES;
        
        self.areaResultBlock = areaResult;
        
        provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
        cities = [[provinces objectAtIndex:0] objectForKey:@"cities"];
        areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
        self.selectProvince = [[provinces objectAtIndex:0] objectForKey:@"state"];
        self.selectCity = [[cities objectAtIndex:0] objectForKey:@"city"];
        
        areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
        if (areas.count > 0) {
            self.selectArea = [areas objectAtIndex:0];
        } else{
            self.selectArea = @"";
        }
        
        self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.backGroundView.backgroundColor = [UIColor whiteColor];
        [self addButton];
        [self.backGroundView addSubview:[self areaPickerView]];
        [self addSubview:self.backGroundView];
        
         __block  BOOL isPersonWifiOpen=[AppDelegate sharedInstance].isPersonWifeOpen;
        [UIView animateWithDuration:0.25 animations:^{
            [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(isPersonWifiOpen?HIGHT+20:HIGHT), [UIScreen mainScreen].bounds.size.width, HIGHT)];
        } completion:^(BOOL finished) {
        }];
        [self showAreaView];
    }
}

- (UIPickerView *)areaPickerView
{
    if(!_areaPickerView)
    {
        _areaPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
        _areaPickerView.delegate = self;
        _areaPickerView.dataSource = self;
        _areaPickerView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    }
    return _areaPickerView;
}

- (void)addButton
{
    for(int i = 0; i < 2; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button.layer setCornerRadius:5];
        [button.layer setBorderWidth:0.5];
        [button.layer setBorderColor:[COLOR_E7E7E7 CGColor]];
        
        [button setBackgroundColor:[UIColor colorWithHexString:@"#f5f5f5"]];
        
        if(i == 1)
        {
            button.frame = CGRectMake(18 + (SCREEN_WIDTH-18*2 - 18)/2 + 18, HIGHT-20-43, (SCREEN_WIDTH-18*2 - 18)/2, 43);
            [button setTitle:@"确定" forState:UIControlStateNormal];
            [button setTitleColor:COLOR_00BAA2 forState:UIControlStateNormal];
        }
        else
        {
            button.frame = CGRectMake(18, HIGHT-20-43, (SCREEN_WIDTH-18*2 - 18)/2, 43);
            [button setTitle:@"取消" forState:UIControlStateNormal];
            [button setTitleColor:COLOR_848484 forState:UIControlStateNormal];
        }
        
        [button addTarget:self action:@selector(onTouchButonWithSubmit:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.backGroundView addSubview:button];
    }
}

- (void)onTouchButonWithSubmit:(UIButton *)sender
{
    if(sender.tag == 0)
    {
        [self disMissAreaView];
    }
    else
    {
        self.areaResultBlock([NSString stringWithFormat:@"%@%@%@", self.selectProvince, self.selectCity, self.selectArea]);
        [self disMissAreaView];
    }
}

- (void)showAreaView
{
    self.tag = 666;
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
}

- (void)disMissAreaView
{
    ZWSelectAreaView *view =  (ZWSelectAreaView *)[[UIApplication sharedApplication].delegate.window.rootViewController.view viewWithTag:666];
    [UIView animateWithDuration:0.25 animations:^{
        [view.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        view.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [view removeFromSuperview];
        }
    }];
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            return [cities count];
            break;
        case 2:
            return [areas count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [[provinces objectAtIndex:row] objectForKey:@"state"];
            break;
        case 1:
            return [[cities objectAtIndex:row] objectForKey:@"city"];
            break;
        case 2:
            if ([areas count] > 0) {
                return [areas objectAtIndex:row];
                break;
            }
        default:
            return  @"";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            cities = [[provinces objectAtIndex:row] objectForKey:@"cities"];
            [self.areaPickerView reloadComponent:1];
            [self.areaPickerView selectRow:0 inComponent:1 animated:YES];
            
            areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
            [self.areaPickerView reloadComponent:2];
            [self.areaPickerView selectRow:0 inComponent:2 animated:YES];
            
            
                self.selectProvince = [[provinces objectAtIndex:row] objectForKey:@"state"];
                self.selectCity = [[cities objectAtIndex:0] objectForKey:@"city"];
            if ([areas count] > 0) {
                    self.selectArea = [areas objectAtIndex:0];
            } else{
                    self.selectArea = @"";
            }
            break;
        case 1:
            areas = [[cities objectAtIndex:row] objectForKey:@"areas"];
            [self.areaPickerView reloadComponent:2];
            [self.areaPickerView selectRow:0 inComponent:2 animated:YES];
            
            
                self.selectCity = [[cities objectAtIndex:row] objectForKey:@"city"];
            if ([areas count] > 0) {
                    self.selectArea = [areas objectAtIndex:0];
            } else{
                    self.selectArea = @"";
            }
            break;
        case 2:
            if ([areas count] > 0) {
                    self.selectArea = [areas objectAtIndex:row];
            } else{
                    self.selectArea = @"";
            }
            break;
        default:
            break;
    }

}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.minimumScaleFactor = 8.0;
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:14]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


@end
