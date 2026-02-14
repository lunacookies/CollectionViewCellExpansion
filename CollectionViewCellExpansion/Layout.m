#import "Layout.h"

@interface Layout ()
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) NSArray<UICollectionViewLayoutAttributes *> *previousAttributes;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *currentAttributes;
@end

@implementation Layout

- (void)prepareLayout
{
	[super prepareLayout];

	self.previousAttributes = [self.currentAttributes copy];
	self.contentSize = (CGSize){0};
	self.currentAttributes = [NSMutableArray array];

	if (self.collectionView && self.collectionView.numberOfSections)
	{
		NSUInteger itemCount = [self.collectionView numberOfItemsInSection:0];
		CGFloat width = self.collectionView.bounds.size.width;
		CGFloat y = 0;

		for (NSUInteger itemIndex = 0; itemIndex < itemCount; itemIndex++)
		{
			NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
			UICollectionViewLayoutAttributes *attributes =
				[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

			CGRect frame = {0};
			frame.origin.y = y;
			frame.size.width = width;
			frame.size.height = self.selectedCellIndexPath && itemIndex == self.selectedCellIndexPath.item ? 100 : 44;
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
	return NO;
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
