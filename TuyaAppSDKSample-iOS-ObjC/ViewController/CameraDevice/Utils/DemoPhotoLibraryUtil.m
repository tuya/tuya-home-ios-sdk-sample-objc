//
//  DemoPhotoLibraryUtil.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoPhotoLibraryUtil.h"
#import <Photos/Photos.h>

@implementation DemoPhotoLibraryUtil

+ (BOOL)saveImageToPhotoLibrary:(UIImage *)image {
    if (!image) {
        return NO;
    }
    NSError *error = nil;
    __block PHObjectPlaceholder *placeHolder = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        placeHolder = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
    } error:&error];
    if (error) {
        return NO;
    }
    PHAssetCollection *assetCollection = [self currentAppAssetCollection];
    if (!assetCollection) {
        return NO;
    }
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        [request insertAssets:@[placeHolder] atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    if (error) {
        return NO;
    }
    return YES;
}

+ (PHAssetCollection *)currentAppAssetCollection {
    static PHAssetCollection *assetCollection = nil;
    if (assetCollection) {
        return assetCollection;
    }
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [collections enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL *stop) {
        if ([title isEqualToString:obj.localizedTitle]) {
            assetCollection = obj;
            *stop = YES;
        }
    }];
    if (assetCollection == nil) {
        NSError *error = nil;
        __block NSString *retCollectionID = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            retCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
        } error:&error];
        if (error) {
        }
        assetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[retCollectionID] options:nil].firstObject;
    }
    return assetCollection;
}

@end
