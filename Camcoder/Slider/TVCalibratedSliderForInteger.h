//
//  TVCalibratedSliderForInteger.h
//  Camcoder
//
//  Created by Nikunj Modi on 24/12/12.
//  Copyright (c) 2012 Nikunj Modi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    short int minimumValue;
    short int maximumValue;
} TVCalibratedSliderRangeInteger;


typedef enum {
    TVCalibratedSliderStyleDefaultInteger ,
    TavicsaStyleInteger
} TVCalibratedSliderStyleInteger;

typedef void (^TVSliderValueChangedBlockInteger)(id sender);

@protocol TVCalibratedSliderIntegerDelegate;

/**
 A control used to select a value from a bunch of values.
 This control is drawn as horizontal bar with scale below it.
 
 USAGE :
 
 TVCalibratedSlider *programmaticallyCreatedTVSlider = [[TVCalibratedSlider alloc] initWithFrame:CGRectMake(..,..,..,..) withStyle:TavicsaStyle];
 
 [programmaticallyCreatedTVSlider setRange:range];
 
 [programmaticallyCreatedTVSlider setDelegate:self] ;
 
 */
@interface TVCalibratedSliderForInteger : UIView
@property (nonatomic, retain) id<TVCalibratedSliderIntegerDelegate> delegate;

@property (nonatomic, copy) TVSliderValueChangedBlockInteger tvSliderValueChangedBlock;

@property (nonatomic, strong) UIColor *markerValueColor;

@property (nonatomic) TVCalibratedSliderStyleInteger style;

/**
 @abstract Initialize the slider with a frame and style.
 
 @param frame The frame rectangle of the TVCalibratedSlider.
 @param style Constant indicating slider style.
 @return TVScaledSlider or nil.
 */
- (id)initWithFrame:(CGRect)frame withStyle:(TVCalibratedSliderStyleInteger)style;

/**
 @abstract Sets the current value.
 
 @param value The new value to assign to the value property
 */
- (void)setValue:(float)value;

/**
 @abstract Returns the current value of the slider.
 @return Value The value of the position where the slider is currently positioned.
 */
- (float)value;

/**
 @abstract Set the slider range.
 
 @param range TVCalibratedSliderRange.
 */
- (void)setRange:(TVCalibratedSliderRangeInteger)range;

/**
 @return Slider range.
 */
- (TVCalibratedSliderRangeInteger)range;

/**
 @abstract Assigns a maximum track image to the specified control states.
 
 @param imageName The minimum track image name to associate with the specified states.
 @param capInsets  The values to use for the cap insets.
 @param state The control state with which to associate the image.
 */
- (void)setMaximumTrackImage:(NSString *)imageName withCapInsets:(UIEdgeInsets)capInsets forState:(UIControlState)state;

/**
 @abstract Assigns a minimum track image to the specified control states.
 
 @param imageName The minimum track image name to associate with the specified states.
 @param capInsets  The values to use for the cap insets.
 @param state The control state with which to associate the image
 */
- (void)setMinimumTrackImage:(NSString *)imageName withCapInsets:(UIEdgeInsets)capInsets forState:(UIControlState)state;

/**
 @abstract Sets the image as the thumb image of the slider for the specified state.
 
 @param imageName  The thumb image to associate with the specified states.
 @param state      The control state with which to associate the image.
 */
- (void)setThumbImage:(NSString *)imageName forState:(UIControlState)state;

/**
 @abstract Sets the thumb image with offset relative to the center of the track.
 
 @discussion Offset is needed when using a custom thumb image to position it relative to track (not complusory).
 @param imageName The thumb image to associate with the specified states.
 @param state The control state with which to associate the image.
 @param offset The offset point relative to the track.
 */
- (void)setThumbImage:(NSString *)imageName forState:(UIControlState)state withOffsetRelativeToCenterOfTrack:(CGPoint)offset;

/**
 @abstract Set the marker image.
 @param imageName Image Name for the marker image.
 */
- (void)setScaleMarkerImage:(NSString *)imageName;

/**
 @abstract Set the text color on the highlighted thumb image.
 @param color Text color on the highlighted thumb image.
 */
- (void)setTextColorForHighlightedState:(UIColor *)color;

/**
 @abstract Set the text font on the highlighted thumb image.
 @param font Text font on the highlighted thumb image.
 */
- (void)setTextFontForHighlightedState:(UIFont *)font;

/**
 @abstract Set position of the text on the highlighted thumb image.
 @param position Text postion on the highlighted thumb image.
 */
- (void)setTextPositionForHighlightedStateRelativeToThumbImage:(CGPoint)position;

/**
 @abstract Set offset of marker Image from the center of slider.
 @param offset offset from the center of the slider.
 */
- (void)setMarkerImageOffsetFromSlider:(float)offset;

/**
 @abstract Set offset of marker value from the marker image .
 @param offset offset from the marker image.
 */
- (void)setMarkerValueOffsetFromSlider:(float)offset;
@end


@protocol TVCalibratedSliderIntegerDelegate <NSObject>

/**
 @abstract This method will be called by the TVScaledSlider when the value of slider changes.
 @param tvScaledSlider TVScaledSlider, object indicating that value has changed.
 */
- (void)valueChangedforInteger:(TVCalibratedSliderForInteger *)tvScaledSlider;
@end
