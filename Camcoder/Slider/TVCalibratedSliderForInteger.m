//
//  TVCalibratedSliderForInteger.m
//  Camcoder
//
//  Created by Nikunj Modi on 24/12/12.
//  Copyright (c) 2012 Nikunj Modi. All rights reserved.
//

#import "TVCalibratedSliderForInteger.h"
#import "TVSlider.h"

@interface TVCalibratedSliderForInteger () {
    TVSlider *_tvSliderView;
    UIImage  *_markerImage;
    UIColor  *_markerValueColor;
    float    _markerImageOffsetFromSlider;
    float    _markerValueOffsetFromSlider;
}
@end

@implementation TVCalibratedSliderForInteger
@synthesize delegate = _delegate, tvSliderValueChangedBlock = _tvSliderValueChangedBlock, markerValueColor = _markerValueColor, style = _style;
#pragma mark - Initializing the Views

- (id)init {
    self = [super init];
    if(self) {
        [self initializeSlider];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSlider];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self initializeSlider];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withStyle:(TVCalibratedSliderStyleInteger)style {
    self = [self initWithFrame:frame];
    if(self){
        self.style = style;
    }
    return self;
}

- (void)initializeSlider {
    //_markerImage = [UIImage imageNamed:@"marker.png"];
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    //_markerValueColor = [UIColor blackColor];
    
    _tvSliderView = [[TVSlider alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2, self.frame.size.width,0)];
    _tvSliderView.continuous = NO;
    [_tvSliderView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_tvSliderView];
}

- (void)drawRect:(CGRect)rect {
    UIImage *thumbImage = [_tvSliderView thumbImageForState:UIControlStateNormal];
    float scaleFactor = (_tvSliderView.frame.size.width - thumbImage.size.width) / (_tvSliderView.maximumValue - _tvSliderView.minimumValue);
    scaleFactor = 0.01f;
    [_markerValueColor set];
    
    for(int index = 0 ; index + _tvSliderView.minimumValue <= _tvSliderView.maximumValue ; index ++){
        float x = (scaleFactor * index) + thumbImage.size.width/2;
        float y = _tvSliderView.center.y + _markerImage.size.height +_markerImageOffsetFromSlider;
        
        UIImageView *markerImageView  = [[UIImageView alloc] initWithImage:_markerImage];
        markerImageView.frame = CGRectMake(x, y, _markerImage.size.width, _markerImage.size.height);
        
        [self insertSubview:markerImageView belowSubview:_tvSliderView];
        
        NSString *value = [NSString stringWithFormat:@"%0.0lf",index + _tvSliderView.minimumValue];
        CGSize size = [value sizeWithFont:[UIFont systemFontOfSize:10]];
        [markerImageView release];
        //[value drawAtPoint:CGPointMake(markerImageView.frame.origin.x - (size.width/2), markerImageView.frame.origin.y + markerImageView.frame.size.height + _markerValueOffsetFromSlider) withFont:[UIFont systemFontOfSize:12]];
    }
}

#pragma mark - Setting the frame
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self redrawScale];
}

- (void)setStyle:(TVCalibratedSliderStyleInteger)style {
    _style = style;
    if(style == TavicsaStyleInteger) {
        [self setMaximumTrackImage:@"slider_solid_base.png" withCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) forState:UIControlStateNormal];
        [self setMinimumTrackImage:@"slider_solid_fill_emphasized.png" withCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) forState:UIControlStateNormal];
        [self setThumbImage:@"Cam-slider_thumb_overlaybar" forState:UIControlStateNormal withOffsetRelativeToCenterOfTrack:CGPointMake(0, 0)];
        [self setThumbImage:@"Cam-slider_thumb_overlaybar" forState:UIControlStateHighlighted withOffsetRelativeToCenterOfTrack:CGPointMake(0, -15)];
    }
}

#pragma mark - Refreshing the view

- (void)redrawScale {
    for(UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    [self addSubview:_tvSliderView];
    [self setNeedsDisplay];
}

#pragma mark - Slider's Track and Thumb Images Method

- (void)setMaximumTrackImage:(NSString *)imageName withCapInsets:(UIEdgeInsets)capInsets forState:(UIControlState)state {
    [_tvSliderView setMaximumTrackImage:[[UIImage imageNamed:imageName] resizableImageWithCapInsets:capInsets] forState:state];
}

- (void)setMinimumTrackImage:(NSString *)imageName withCapInsets:(UIEdgeInsets)capInsets forState:(UIControlState)state {
    [_tvSliderView setMinimumTrackImage:[[UIImage imageNamed:imageName] resizableImageWithCapInsets:capInsets] forState:state];
}

- (void)setThumbImage:(NSString *)imageName forState:(UIControlState)state {
    [_tvSliderView setThumbImage:[UIImage imageNamed:imageName] forState:state withOffsetRelativeToCenterOfTrack:CGPointMake(0, 0)];
}

- (void)setThumbImage:(NSString *)imageName forState:(UIControlState)state withOffsetRelativeToCenterOfTrack:(CGPoint)offset {
    [_tvSliderView setThumbImage:[UIImage imageNamed:imageName] forState:state withOffsetRelativeToCenterOfTrack:offset];
}

- (void)setScaleMarkerImage:(NSString *)imageName {
    _markerImage = [UIImage imageNamed:imageName];
    [self redrawScale];
}

#pragma mark - Calback Method

- (void)valueChanged:(id)sender {
    double value =_tvSliderView.value;
    float calculatedValue = value;
    [_tvSliderView setValue:calculatedValue];
    if(self.tvSliderValueChangedBlock != nil) {
        self.tvSliderValueChangedBlock(self);
    }
    [_delegate valueChangedforInteger:self];
}

#pragma mark - setting and getting the value of slider

- (void)setValue:(float)value {
    [_tvSliderView setValue:value];
}

- (float)value {
    return _tvSliderView.value;
}

- (void)setRange:(TVCalibratedSliderRangeInteger)range {
    if(range.maximumValue > range.minimumValue){
        _tvSliderView.maximumValue = range.maximumValue;
        _tvSliderView.minimumValue = range.minimumValue;
    }
    [self redrawScale];
}

- (TVCalibratedSliderRangeInteger)range {
    TVCalibratedSliderRangeInteger range;
    range.maximumValue = _tvSliderView.maximumValue;
    range.minimumValue = _tvSliderView.minimumValue;
    return range;
}

#pragma mark - Indicator color

- (void)setTextColorForHighlightedState:(UIColor *)color {
    [_tvSliderView setTextColorForHighlightedState:color];
}

-(void)setTextFontForHighlightedState:(UIFont *)font {
    [_tvSliderView setTextFontForHighlightedState:font];
}

- (void)setTextPositionForHighlightedStateRelativeToThumbImage:(CGPoint)position {
    [_tvSliderView setTextPositionForHighlightedStateRelativeToThumbImage:position];
}

- (void)setMarkerImageOffsetFromSlider:(float)offset {
    _markerImageOffsetFromSlider = offset;
    [self redrawScale];
}

-(void)setMarkerValueOffsetFromSlider:(float)offset {
    _markerValueOffsetFromSlider = offset;
    [self redrawScale];
}


@end
