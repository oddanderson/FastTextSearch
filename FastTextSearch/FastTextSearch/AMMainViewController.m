//
//  AMMainViewController.m
//  Dictionary
//
//  Created by Todd Anderson on 9/22/14.
//

#import "AMMainViewController.h"
#import "AMDictionaryReader.h"
#import "TATrie.h"

@implementation AMMainViewController
{
    TATrie *_tree;
    NSArray *_words;
    UISearchDisplayController *_searchVC;
    NSMutableArray *_bruteForceWords;
    UIActivityIndicatorView *_indicatorView;
}

- (id)init {
    self = [super init];
    if (self) {
        _bruteForceWords = [NSMutableArray new];
        self.title = @"Dictionary";
    }
    
    return self;
}

- (void)loadWords {
    _tree = [[TATrie alloc] init];
    AMDictionaryReader *reader = [[AMDictionaryReader alloc] init];
    NSString *word = [reader nextWord];
    while (word) {
        [_tree addWord:word];
//        [_bruteForceWords addObject:word];
        word = [reader nextWord];
    }
    [_tree removeWord:@""];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicatorView stopAnimating];
        self.tableView.tableFooterView = nil;
        [self.tableView reloadData];
    });
}

// Just using a tableviewcontroller and uisearchbar as the header view
- (void)viewDidLoad {
    [super viewDidLoad];
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.color = [UIColor purpleColor];
    _indicatorView.frame = CGRectMake(0, 0, 40, 40);
    [_indicatorView startAnimating];
    self.tableView.tableFooterView = _indicatorView;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadWords];
    });
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, 300, 50);
    searchBar.delegate = self;
    searchBar.showsCancelButton = YES;
    self.navigationItem.titleView = searchBar;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _words.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *word = _words[indexPath.row];
    cell.textLabel.text = word;
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //clear search if no text.  No reason for data structure to handle this case
    if (!searchText.length) {
        _words = @[];
        [self.tableView reloadData];
        return;
    }
//    NSString *lowercaseText = [searchText lowercaseString];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSRange spaceCharRange = [searchText rangeOfString:@" "];
        if (spaceCharRange.location != NSNotFound) {
            NSString *exactWord = [searchText substringToIndex:spaceCharRange.location];
            if ([_tree containsWord:exactWord]) {
                _words = @[searchText];
            } else {
                _words = @[];
            }
        } else {
            _words = [_tree wordsThatStartWith:searchText];
//          _words = [self wordsThatMatch:lowercaseText];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (NSArray *)wordsThatMatch:(NSString *)substring {
//    NSString *lowercaseString = [substring lowercaseString];
    NSMutableArray *foundWords = [NSMutableArray new];
    for (NSString *word in _bruteForceWords) {
        if ([[word lowercaseString] rangeOfString:substring].location == 0) {
            [foundWords addObject:word];
        }
    }
    return foundWords;
}



@end