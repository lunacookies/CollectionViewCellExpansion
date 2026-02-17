#import "ViewController.h"
#import "Layout.h"

@interface Cell : UICollectionViewListCell
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
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
		Cell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
		cell.expanded = !cell.expanded;
		[self.collectionView.collectionViewLayout invalidateLayout];
		[self.collectionView layoutIfNeeded];
	}];

	[animator startAnimation];
}


@end

@interface Cell ()
@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong, readonly) NSLayoutConstraint *bottomConstraint;
@end

@implementation Cell

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (!self) return nil;

	_label = [[UILabel alloc] init];
	_label.backgroundColor = UIColor.redColor;

	UIView *wrapper = [[UIView alloc] init];

	self.label.translatesAutoresizingMaskIntoConstraints = NO;
	wrapper.translatesAutoresizingMaskIntoConstraints = NO;
	[wrapper addSubview:self.label];
	[self.contentView addSubview:wrapper];

	_bottomConstraint = [wrapper.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor];
	_bottomConstraint.priority = UILayoutPriorityRequired - 1;

	[NSLayoutConstraint activateConstraints:@[
		[self.label.topAnchor constraintEqualToAnchor:wrapper.topAnchor],
		[self.label.leadingAnchor constraintEqualToAnchor:wrapper.leadingAnchor],
		[self.label.trailingAnchor constraintEqualToAnchor:wrapper.trailingAnchor],
		[self.label.bottomAnchor constraintEqualToAnchor:wrapper.bottomAnchor],

		[wrapper.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
		[wrapper.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
		[wrapper.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
		self.bottomConstraint,
	]];

	self.expanded = NO;

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

- (void)setExpanded:(BOOL)expanded
{
	_expanded = expanded;
	self.bottomConstraint.constant = expanded ? -100 : 0;
}

@end
