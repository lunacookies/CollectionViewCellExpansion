#import "ViewController.h"

@interface Cell : UICollectionViewListCell
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL expanded;
@end

@interface ViewController ()
@property (nonatomic, strong) UICollectionViewDiffableDataSource<NSNumber *, NSNumber *> *dataSource;
@end

@implementation ViewController

- (instancetype)init
{
	UICollectionLayoutListConfiguration *configuration =
		[[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearancePlain];
	UICollectionViewCompositionalLayout *layout =
		[UICollectionViewCompositionalLayout layoutWithListConfiguration:configuration];
	return [super initWithCollectionViewLayout:layout];
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

	UISpringTimingParameters *timingParameters = [[UISpringTimingParameters alloc] initWithDuration:0.3 bounce:0.3];
	UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0 timingParameters:timingParameters];

	[animator addAnimations:^{
		Cell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
		cell.expanded = !cell.expanded;
		[self.collectionView.collectionViewLayout invalidateLayout];
		[self.collectionView layoutIfNeeded];
	}];
	
	[animator startAnimation];
}


@end

@interface Cell ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@end

@implementation Cell

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (!self) return nil;

	self.label = [[UILabel alloc] init];
	self.label.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:self.label];

	self.heightConstraint = [self.contentView.heightAnchor constraintEqualToConstant:0];
	self.heightConstraint.priority = UILayoutPriorityRequired - 1;

	[NSLayoutConstraint activateConstraints:@[
		[self.label.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
		[self.label.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
		[self.label.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
		[self.label.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
		self.heightConstraint,
	]];

	self.expanded = NO;

	return self;
}

- (void)setExpanded:(BOOL)expanded
{
	_expanded = expanded;
	self.heightConstraint.constant = expanded ? 100 : 44;
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
