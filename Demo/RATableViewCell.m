
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RATableViewCell.h"
#import "UIImageView+WebCache.h"
#import "RADataObject.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface RATableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberItemLabel;


@property (strong, nonatomic) RADataObject *dataObject;

@end

@implementation RATableViewCell

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  self.selectedBackgroundView = [UIView new];
  self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
  
}

- (void)prepareForReuse
{
  [super prepareForReuse];

}

- (void) setUpWithObject:(RADataObject *) dataObject {
    self.dataObject = dataObject;
    self.titleLabel.text = dataObject.name;
    
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:dataObject.imageLink]
                                                        options:0
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             [self.titleImageView setImage:image];
         }
     }];
    
    
    
    self.numberItemLabel.text = [NSString stringWithFormat:@"%d", [dataObject.children count]];
    
    
    [self switchExpandIcon:dataObject.expanded];
    

    [self.expandButton setHidden:NO];
    if ([dataObject.children count] < 1) {
        [self.expandButton setHidden:YES];
        [self.numberItemLabel setHidden:YES];
    }
    
    if (dataObject.level == 0) {
        self.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    if (dataObject.level == 0) {
        self.backgroundColor = UIColorFromRGB(0xF7F7F7);
    } else if (dataObject.level == 1) {
        self.backgroundColor = UIColorFromRGB(0xD1EEFC);
    } else if (dataObject.level >= 2) {
        self.backgroundColor = UIColorFromRGB(0xE0F8D8);
    }
    
    CGFloat left = 15 + 15 * dataObject.level;
    
    CGRect detailsFrame = self.titleImageView.frame;
    detailsFrame.origin.x = left;
    self.titleImageView.frame = detailsFrame;
    
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin.x = detailsFrame.origin.x + detailsFrame.size.width/(dataObject.level+1) + left;
    self.titleLabel.frame = titleFrame;
    
}


#pragma mark - Properties



#pragma mark - Actions
- (IBAction)expandButtonTouch:(id)sender {
    self.expandButtonTapAction(self.dataObject);
    
}


- (void) switchExpandIcon:(BOOL) isExpanded {
    
    NSString *expandImageName = @"plus_icon";
    
    if (isExpanded) {
        expandImageName = @"minus_icon";
    }
    
    [self.expandButton setImage:[UIImage imageNamed:expandImageName] forState:UIControlStateNormal];
}

@end
