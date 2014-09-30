//
//  AMDictionaryReader.h
//  Dictionary
//
//  Implement this class.
//
//  Created by Todd Anderson on 9/22/14.
//

#import <Foundation/Foundation.h>

@interface AMDictionaryReader : NSObject

/**
 * Implement this so that it either returns the next word in the dictionary or nil to signify that all of the words
 * have been read in. The NSString returned should be an auto-released NSString, however take care in handling the
 * returned NSString as there are a quarter million words in the dictionary.
 */
- (NSString *)nextWord;

@end
