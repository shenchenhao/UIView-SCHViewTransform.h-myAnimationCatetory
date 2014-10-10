//
//  UIView+SCHViewTransform.h
//  me
//
//  Created by 沈 晨豪 on 14-8-17.
//  Copyright (c) 2014年 sch. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface SCHScaleTransformModel : NSObject

@property (nonatomic,strong) NSNumber *from_value;
@property (nonatomic,strong) NSNumber *to_value;
@property (nonatomic,assign) CGFloat   duration;

@end


#pragma mark -
#pragma mark - SCHMovePath

/*
 
 0-----1
 |     |
 |     |
 3-----2
 */

typedef NS_ENUM(NSUInteger, SCHRectPathType)
{
    SCHRectLeftTopPoint = 0,
    SCHRectRightTopPoint,
    SCHRectRightBottomPoint,
    SCHRectLeftBottomPoint
};



@interface UIView (SCHMovePath)



/**
 *  开始以rect为路径的动画
 *   0-----1
 *   |     |
 *   |     |
 *   3-----2
 *
 *  @param point_array            经过的点
 *  @param delay                  延后的时间
 *  @param color                  线条颜色
 *  @param is_above               YES: 在view 上面  NO:在view的父view 上面
 *  @param animation_start_block  动画开始 block
 *  @param animation_end_block    动画结束 end
 */
- (void)startRectMovePathAnimationWithPassPoint: (NSArray *) point_array
                                          delay: (CGFloat)delay
                                          color: (UIColor *) color
                                    isAboveView: (BOOL) is_above
                                 animationStart: (void (^)()) animation_start_block
                                   animationEnd: (void (^)()) animation_end_block;


@end


#pragma mark -
#pragma mark - SCHViewScalePathTransform

@interface UIView (SCHViewScalePathTransform)


/**
 *  开始 缩放大小的动画
 *
 *  @param sacle_array            一系列缩放大小的动画
 *  @param scale_animation_start  动画开始的block
 *  @param scale_animation_end    动画结束的block
 */
- (void)startScaleTransformAnimationWithScaleTransformModelArray: (NSArray *) scale_array
                                                  animationStart: (void (^)(id object)) scale_animation_start
                                                    animationEnd: (void (^)(id object)) scale_animation_end;

/**
 *  开始 缩放大小的动画
 *
 *  @param is_up                  YES: 先往上  NO: 先往下
 *  @param scale_animation_start  动画开始的block
 *  @param scale_animation_end    动画结束的block
 */
- (void)startScaleTransformAnimationWithUpOrDown: (BOOL) is_up
                                  animationStart: (void (^)(id object)) scale_animation_start
                                    animationEnd: (void (^)(id object)) scale_animation_end;

@end




#pragma mark -
#pragma mark - SCHViewTurningTransform

@interface SCHTransform3DModel : NSObject

@property (nonatomic,strong) NSValue  *from_value;
@property (nonatomic,strong) NSValue  *to_value;
@property (nonatomic,assign) CGFloat   duration;

@end

/*
 *---0---*
 |       |
 3       1
 |       |
 *---2---*
 */

typedef NS_ENUM(NSUInteger, SCHTurningDirectionType)
{
    SCHTurningDirectionTop = 0,
    SCHTurningDirectionRight,
    SCHTurningDirectionBottom,
    SCHTurningDirectionLeft,
};



@interface UIView(SCHViewTurningTransform)

/**
 *
 *
 *  @param center  相机位置
 *  @param z       距离 z方向的位置
 *
 *  @return 返回变换后的 形态
 */
- (CATransform3D)SCHTransform3DMakePerspective: (CGPoint) center :(CGFloat) z;

- (CATransform3D)SCHTransform3DPerspect: (CATransform3D) transform  : (CGPoint) center :(CGFloat)z;

/**
 *  对指定点摇摆的动画
 *
 * *---0---*
 * |       |
 * 3       1
 * |       |
 * *---2---*
 *
 *
 *  @param direction_type                    锚点方向
 *  @param is_from_front                     YES: 从前方出现 NO: 从后背出现
 *  @param transform_animation_start_block   动画开始
 *  @param transform_animation_end_block     动画结束
 */
- (void)startTurningTransformAnimationWithAnchorPointDirection: (SCHTurningDirectionType) direction_type
                                                   frontOrBack: (BOOL) is_from_front
                                                animationStart: (void (^)(id object)) transform_animation_start_block
                                                  animationEnd: (void (^)(id object)) transform_animation_end_block;

/**
 * 对指定点摇摆的动画
 *
 *  @param direction_type                    锚点方向
 *  @param array                             摇摆的路径的 array
 *  @param transform_animation_start_block   动画开始
 *  @param transform_animation_end_block     动画结束
 */
- (void)startTurningTransformAnimationWithAnchorPointDirection: (SCHTurningDirectionType) direction_type
                                      transform3DPerspectArray: (NSArray *) array
                                                animationStart: (void (^)(id object)) transform_animation_start_block
                                                  animationEnd: (void (^)(id object)) transform_animation_end_block;

@end



