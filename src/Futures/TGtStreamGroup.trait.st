Trait {
	#name : #TGtStreamGroup,
	#category : #'Futures-Base - Streams'
}

{ #category : #accessing }
TGtStreamGroup >> asArray [
	^ self stream asArray
]

{ #category : #accessing }
TGtStreamGroup >> asAsyncObservable [
	^ self stream asAsyncObservable
]

{ #category : #accessing }
TGtStreamGroup >> asAsyncObservable: anAsyncFutureExecutionConfiguration [
	^ self stream asAsyncObservable: anAsyncFutureExecutionConfiguration
]

{ #category : #accessing }
TGtStreamGroup >> asAsyncStream [
	^ self
]

{ #category : #accessing }
TGtStreamGroup >> asyncSimilarCopy [
	^ self explicitRequirement
]

{ #category : #accessing }
TGtStreamGroup >> cached [
	self stream: self stream cached
]

{ #category : #accessing }
TGtStreamGroup >> chunks: aCapacity [
	self stream: (self stream chunks: aCapacity)
]

{ #category : #accessing }
TGtStreamGroup >> collect: aBlock [
	self stream: (self map: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> debounce: aDuration [
	self stream: (self stream debounce: aDuration)
]

{ #category : #accessing }
TGtStreamGroup >> do: aBlock [
	self stream: (self stream do: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> ephemerous [
	self stream: self stream ephemerous
]

{ #category : #accessing }
TGtStreamGroup >> filter: aBlock [
	self stream: (self stream filter: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> flatCollect: aBlock [
	self stream: (self stream flatCollect: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> flatten [
	self stream: self stream flatten
]

{ #category : #accessing }
TGtStreamGroup >> for: aBlock [
	self stream: (self stream for: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> forEach: aBlock [
	self stream: (self stream forEach: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> forward: aBlock [
	self stream: (self stream forward: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> fuse [
	self stream: self stream fuse
]

{ #category : #accessing }
TGtStreamGroup >> hasNext [
	^ self stream hasNext
]

{ #category : #accessing }
TGtStreamGroup >> inject: anInitialValue into: aBlock [
	self stream: (self stream inject: anInitialValue into: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> isAsyncStream [
	^ true
]

{ #category : #testing }
TGtStreamGroup >> isEmpty [

	^ self stream isEmpty
]

{ #category : #testing }
TGtStreamGroup >> isNotEmpty [

	^ self stream isNotEmpty
]

{ #category : #accessing }
TGtStreamGroup >> map: aBlock [
	self stream: (self stream map: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> map: aBlock cache: aCache [
	self stream: (self stream map: aBlock cache: aCache)
]

{ #category : #accessing }
TGtStreamGroup >> map: aBlock key: aKeyBlock cache: aCache [
	self
		stream: (self stream
				map: aBlock
				key: aKeyBlock
				cache: aCache)
]

{ #category : #accessing }
TGtStreamGroup >> merge: aStream [
	self stream: (self stream merge: aStream)
]

{ #category : #accessing }
TGtStreamGroup >> next [
	^ self stream next
]

{ #category : #accessing }
TGtStreamGroup >> on: anException do: anExceptionHandler [
	self stream: (self stream on: anException do: anExceptionHandler)
]

{ #category : #accessing }
TGtStreamGroup >> pollNext: aContext [
	^ self stream pollNext: aContext
]

{ #category : #accessing }
TGtStreamGroup >> relay: aBlock [
	self stream: (self stream relay: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> select: aBlock [
	self stream: (self stream select: aBlock)
]

{ #category : #accessing }
TGtStreamGroup >> size [
	^ self stream size
]

{ #category : #accessing }
TGtStreamGroup >> sizeHint [
	^ self stream sizeHint
]

{ #category : #accessing }
TGtStreamGroup >> stream [
	^ self explicitRequirement
]

{ #category : #accessing }
TGtStreamGroup >> stream: aStream [
	^ self explicitRequirement
]

{ #category : #accessing }
TGtStreamGroup >> take: anAmount [
	self stream: (self stream take: anAmount)
]

{ #category : #accessing }
TGtStreamGroup >> terminatable [
	self stream: self stream terminatable
]

{ #category : #accessing }
TGtStreamGroup >> to: aClass [
	^ self stream to: aClass
]

{ #category : #accessing }
TGtStreamGroup >> weak [
	self stream: self stream weak
]

{ #category : #accessing }
TGtStreamGroup >> withIndexCollect: aMapBlock [
	self stream: (self stream withIndexCollect: aMapBlock) F
]

{ #category : #accessing }
TGtStreamGroup >> withIndexMap: aMapBlock [
	self stream: (self stream withIndexMap: aMapBlock)
]

{ #category : #accessing }
TGtStreamGroup >> withoutDuplicates [
	self stream: self stream withoutDuplicates
]

{ #category : #accessing }
TGtStreamGroup >> withoutDuplicatesBasedOn: aBlock [
	self stream: (self stream withoutDuplicatesBasedOn: aBlock)
]
