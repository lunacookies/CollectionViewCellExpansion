#import "ViewController.h"
#import "Layout.h"

@interface Cell : UICollectionViewListCell
@property (nonatomic, copy) NSString *text;
@end

@interface ViewController ()
@property (nonatomic, strong) UICollectionViewDiffableDataSource<NSNumber *, NSNumber *> *dataSource;
@property (nonatomic, strong, readonly) Layout *layout;
@end

@implementation ViewController

- (instancetype)init
{
	_layout = [[Layout alloc] init];
	return [super initWithCollectionViewLayout:self.layout];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"Cell"];

	UICollectionViewDiffableDataSourceCellProvider cellProvider = ^(UICollectionView *collectionView, NSIndexPath *indexPath, id item) {
		Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
		cell.text = [NSString stringWithFormat:@"Item %d", ((NSNumber *)item).intValue];
		return cell;
	};

	self.dataSource = [[UICollectionViewDiffableDataSource alloc] initWithCollectionView:self.collectionView
																			cellProvider:cellProvider];

	NSDiffableDataSourceSnapshot<NSNumber *, NSNumber *> *snapshot = [[NSDiffableDataSourceSnapshot alloc] init];
	[snapshot appendSectionsWithIdentifiers:@[ @0 ]];

	for (NSUInteger i = 0; i < 99; i++)
	{
		[snapshot appendItemsWithIdentifiers:@[ @(i) ]];
	}

	[self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];

	UISpringTimingParameters *timingParameters = [[UISpringTimingParameters alloc] initWithDuration:0.4 bounce:0.4];
	UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0 timingParameters:timingParameters];

	[animator addAnimations:^{
		self.layout.selectedCellIndexPath = [self.layout.selectedCellIndexPath isEqual:indexPath] ? nil : indexPath;
		[self.collectionView.collectionViewLayout invalidateLayout];
		[self.collectionView layoutIfNeeded];
	}];

	[animator startAnimation];
}


@end

@interface Cell ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation Cell

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (!self) return nil;

	self.label = [[UILabel alloc] init];
	self.label.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:self.label];

	[NSLayoutConstraint activateConstraints:@[
		[self.label.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
		[self.label.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
		[self.label.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
		[self.label.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
	]];

	return self;
}

- (NSString *)text
{
	return self.label.text;
}

- (void)setText:(NSString *)text
{
	self.label.text = text;
}

@end
