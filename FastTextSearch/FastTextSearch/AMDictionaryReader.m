//
//  AMDictionaryReader.m
//  Dictionary
//
//  Created by Todd Anderson on 9/22/14.
//

#import "AMDictionaryReader.h"

static NSString * kAMDictionaryFileName = @"words";

@interface AMDictionaryReader ()

/**
 * This is the file input stream you will be reading the dictionary from. The stream will consist of UTF8 encoded
 * characters where each word is separated by a newline, '\n'.
 */
@property (nonatomic, strong) NSInputStream *inputStream;

@end

@implementation AMDictionaryReader {
    NSMutableArray *_remainingWords;
    NSString *_lastWord;
}

@synthesize inputStream = inputStream_;

- (id)init {
    if(self = [super init]) {
        //get the dictionary location
        NSString *dictionaryLocation = [[NSBundle mainBundle] pathForResource:kAMDictionaryFileName ofType:@"txt"];
        
        //open up an input stream, make sure to close this when done with it
        self.inputStream = [[NSInputStream alloc] initWithFileAtPath:dictionaryLocation];
        [self.inputStream open];
        _lastWord = @"";
        _remainingWords = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark Implement These

/**
 * nextWord uses a primitive queue. As we read from the input stream, we dump the words into a queue. nextWord
 * first looks at the queue to see if anything is in there.  If so, we pop and return.  If not, we read from stream 
 * and start over. We handle edge case of word getting broken up by inputstream via _lastWord
 */
- (NSString *)nextWord {
    // I didn't really like having nextWord access inputstream directly, since there isn't a great way to read a new line
    
    // If anything left in queue, pop and return
    if (_remainingWords.count) {
        NSString *nextWord = _remainingWords[0];
        [_remainingWords removeObjectAtIndex:0];
        return nextWord;
    }
    
    // Otherwise grab next chunk
    NSString *nextChunk = [self nextChunk];
    if (!nextChunk) {
        // In case last word happened to be a full word. Statistically unlikely.
        if (_lastWord.length) {
            return _lastWord;
        }
        return nil;
    }
    // Break chunk into words
    NSArray *chunkWords = [nextChunk componentsSeparatedByString:@"\n"];
    [_remainingWords addObjectsFromArray:chunkWords];
    if (!_remainingWords.count) {
        return nil;
    }
    // If we had a piece left over from the last call, prepend it to our first word
    if (_lastWord.length) {
        NSString *newWord = [_lastWord stringByAppendingString:_remainingWords[0]];
        [_remainingWords replaceObjectAtIndex:0 withObject:newWord];
    }
    _lastWord = [_remainingWords lastObject];
    [_remainingWords removeLastObject];
    return [self nextWord];
}

- (NSString *)nextChunk {
    if (self.inputStream.hasBytesAvailable) {
        static NSUInteger bufferLength = 100;
        uint8_t charBuffer[bufferLength];
        NSInteger bytesRead = [self.inputStream read:charBuffer maxLength:bufferLength];
        if (bytesRead > 0) {
            return [[NSString alloc] initWithBytes:charBuffer length:bytesRead encoding:NSUTF8StringEncoding];
        } else {
            //nothing left to read, close the stream
            [self.inputStream close];
            return nil;
        }
    }
    return nil;
}



@end