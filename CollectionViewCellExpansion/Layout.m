#import "Layout.h"

@interface Layout ()
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) NSArray<UICollectionViewLayoutAttributes *> *previousAttributes;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *currentAttributes;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSIndexPath *, NSNumber *> *preferredCellHeights;
@end

@implementation Layout

- (instancetype)init
{
	self = [super init];
	if (!self) return nil;
	_preferredCellHeights = [NSMutableDictionary dictionary];
	return self;
}

- (void)prepareLayout
{
	[super prepareLayout];

	self.previousAttributes = self.currentAttributes;
	self.currentAttributes = [NSMutableArray array];
	self.contentSize = (CGSize){0};

	if (self.collectionView.numberOfSections)
	{
		NSUInteger itemCount = [self.collectionView numberOfItemsInSection:0];
		CGFloat width = self.collectionView.bounds.size.width;
		CGFloat y = 0;
		
		for (NSUInteger itemIndex = 0; itemIndex < itemCount; itemIndex++)
		{
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
			UICollectionViewLayoutAttributes *attributes =
			[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
			
			NSNumber *preferredHeight = self.preferredCellHeights[indexPath];
			CGRect frame = {0};
			frame.origin.y = y;
			frame.size.width = width;
			frame.size.height = preferredHeight ? preferredHeight.doubleValue : 44;
			attributes.frame = frame;
			
			[self.currentAttributes addObject:attributes];
			y += frame.size.height;
		}
		
		self.contentSize = (CGSize){width, y};
	}
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return self.currentAttributes[indexPath.item];
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray<UICollectionViewLayoutAttributes *> *result = [NSMutableArray array];
	for (UICollectionViewLayoutAttributes *attributes in self.currentAttributes)
	{
		if (CGRectIntersectsRect(rect, attributes.frame))
		{
			[result addObject:attributes];
		}
	}
	return result;
}

- (CGSize)collectionViewContentSize
{
	return self.contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return self.collectionView.bounds.size.width != newBounds.size.width;
}

- (BOOL)shouldInvalidateLayoutForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes
									withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
	return preferredAttributes.size.height != originalAttributes.size.height;
}

- (UICollectionViewLayoutInvalidationContext *)
		invalidationContextForPreferredLayoutAttributes:(UICollectionViewLayoutAttributes *)preferredAttributes
								 withOriginalAttributes:(UICollectionViewLayoutAttributes *)originalAttributes
{
	UICollectionViewLayoutInvalidationContext *invalidationContext =
			[super invalidationContextForPreferredLayoutAttributes:preferredAttributes
											withOriginalAttributes:originalAttributes];

	for (NSUInteger index = [self.currentAttributes indexOfObject:originalAttributes];
		 index < self.currentAttributes.count;
		 index++)
	{
		UICollectionViewLayoutAttributes *attributes = self.currentAttributes[index];
		[invalidationContext invalidateItemsAtIndexPaths:@[attributes.indexPath]];
	}

	CGSize contentSizeAdjustment = {0};
	contentSizeAdjustment.height = preferredAttributes.size.height - originalAttributes.size.height;
	invalidationContext.contentSizeAdjustment = contentSizeAdjustment;

	self.preferredCellHeights[preferredAttributes.indexPath] = @(preferredAttributes.size.height);
	return invalidationContext;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)indexPath
{
	return self.previousAttributes[indexPath.item];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)indexPath
{
	return [self layoutAttributesForItemAtIndexPath:indexPath];
}

@end
