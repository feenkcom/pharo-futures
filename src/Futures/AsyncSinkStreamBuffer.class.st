Class {
	#name : #AsyncSinkStreamBuffer,
	#superclass : #Object,
	#instVars : [
		'announcer',
		'monitor',
		'stream',
		'bufferSink',
		'outputSinks',
		'loadingPromise',
		'pendingScanPromises',
		'preloadAmount',
		'preloadDuration',
		'loadSinglesUntil',
		'executionConfiguration'
	],
	#category : #'Futures-Buffer'
}

{ #category : #'instance creation' }
AsyncSinkStreamBuffer class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> amountOfLoadedItems [
	^ bufferSink collection size
]

{ #category : #'api - announcer' }
AsyncSinkStreamBuffer >> announce: anAnnouncement [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#announceTemplate'>
	announcer ifNotNil: [ :anAnnouncer | anAnnouncer announce: anAnnouncement ].
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> at: anIndex [
	| requestedItem |

	requestedItem := bufferSink collection at: anIndex.

	(stream isDone not and: [ anIndex = self amountOfLoadedItems ])
		ifTrue: [ self privateLoadNewItems ].

	^ requestedItem
]

{ #category : #'api - loading' }
AsyncSinkStreamBuffer >> bufferLoadingPromise [
	"Return a promise that will be fulfilled when the buffer finishes preloading items"
	<return: #TAsyncPromise>

	^ monitor critical: [ 
		loadingPromise
			ifNil: [ true asAsyncPromise ]
			ifNotNil: [ loadingPromise then: [ true ] ] ]
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> bufferSnapshot [
	"Returns a snapshot copy of the current loaded items in the buffer"
	<return: #Collection>

	^ bufferSink collection copy
]

{ #category : #initialization }
AsyncSinkStreamBuffer >> defaultExecutionConfiguration [
	^ AsyncFutureExecutionConfiguration default
]

{ #category : #private }
AsyncSinkStreamBuffer >> defaultLoadSinglesUntil [
	^ 0
]

{ #category : #initialization }
AsyncSinkStreamBuffer >> defaultPreloadAmount [
	^ 20
]

{ #category : #initialization }
AsyncSinkStreamBuffer >> defaultPreloadDuration [
	^ 300 milliSeconds
]

{ #category : #'api - enumeration' }
AsyncSinkStreamBuffer >> detect: aBlock ifFound: foundBlock ifNone: exceptionBlock [
	self do: [ :each | (aBlock value: each) ifTrue: [ ^ foundBlock cull: each ] ].
	^ exceptionBlock value
]

{ #category : #'api - enumeration' }
AsyncSinkStreamBuffer >> do: aBlock [
	"Iterates over the collection trying to preload the items, stops as soon as it reaches
	the last loaded item."
	| aCurrentIndex |
	
	aCurrentIndex := 1.
	[ aCurrentIndex <= self size ]
		whileTrue: [			
			aBlock value: (self at: aCurrentIndex).
			aCurrentIndex := aCurrentIndex + 1 ]
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> executionConfiguration [

	^ executionConfiguration
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> executionConfiguration: anObject [

	executionConfiguration := anObject
]

{ #category : #initialization }
AsyncSinkStreamBuffer >> initialize [
	super initialize.
	
	monitor := Monitor new.
	stream := nil.

	bufferSink := AsyncCollectionSink forCollection: AsyncSharedOrderedCollection new.
	outputSinks := #().

	loadingPromise := nil.
	pendingScanPromises := OrderedCollection new.

	preloadAmount := self defaultPreloadAmount.
	preloadDuration := self defaultPreloadDuration.
	executionConfiguration := self defaultExecutionConfiguration.
	loadSinglesUntil := self defaultLoadSinglesUntil
]

{ #category : #testing }
AsyncSinkStreamBuffer >> isDone [
	"Return true if there are no more items to poll"

	^ monitor critical: [ stream isDone ]
]

{ #category : #accessing }
AsyncSinkStreamBuffer >> loadSinglesUntil [
	^ loadSinglesUntil
]

{ #category : #accessing }
AsyncSinkStreamBuffer >> loadSinglesUntil: aNumber [
	loadSinglesUntil := aNumber
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> preloadAmount [
	"Return the maximum amount of items to be preloaded by the buffer"
	<return:  #Number>

	^ preloadAmount
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> preloadAmount: aNumber [
	preloadAmount := aNumber
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> preloadDuration [
	"Returns the amount of time the buffer should wait for new
	items before stopping pre-loading. It is useful when it takes a lot of
	time to fetch one item, which would result in a long delay before
	#preloadAmount of items are ready"
	<return: #Duration>

	^ preloadDuration
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> preloadDuration: anObject [
	preloadDuration := anObject
]

{ #category : #'api - loading' }
AsyncSinkStreamBuffer >> preloadUntilFoundSuchThat: aBlock [
	<return: #TAsyncPromise>

	monitor critical: [
		| aPendingScanPromise |
		
		bufferSink collection critical: [
			| eachIndex |
			eachIndex := 0.
			"first let's try to find among existing buffered items"
			bufferSink collection do: [ :eachItem | 
				eachIndex := eachIndex + 1.
				(aBlock cull: eachItem cull: eachIndex)
					ifTrue: [ ^ (AsyncStreamBufferItem new item: eachItem; index: eachIndex) asAsyncPromise ] ] ].

		"the value was not found, let's register a pending scan"
		aPendingScanPromise := AsyncPendingPromise new.
		pendingScanPromises add: (aPendingScanPromise -> aBlock).
		"and request the loading of new items"
		self privateLoadNewItems.

		^ aPendingScanPromise ]
]

{ #category : #private }
AsyncSinkStreamBuffer >> privateLoadNewItems [
	<return: #TAsyncPromise>
	| toLoad |
	^ monitor critical: [ 
		| aSink |
		
	 	loadingPromise ifNotNil: [ ^ loadingPromise ].
		stream isDone ifTrue: [ ^ true asAsyncPromise ].

		toLoad := self amountOfLoadedItems < loadSinglesUntil
			ifTrue: [ 1 ]
			ifFalse: [ preloadAmount ].
		
		aSink := AsyncSpreadSink forSinks: { 
			bufferSink.
			AsyncStreamBufferFlushedSink new streamBuffer: self.
			AsyncStreamBufferScanningSink new streamBuffer: self.
			AsyncSpreadSink forSinks: outputSinks }.

		"Watch out! We must first assign the promise and only then handle then:otherwise:"
		((self startLoadingFuture: (aSink sendAll: ((stream for: preloadDuration) take: toLoad)))
			then: [ :newItems |
				stream isDone
					ifTrue: [ aSink close await: executionConfiguration ].
				self setLoadingPromise: nil ]
			otherwise: [ :anException | 
				  monitor critical: [ "Logging the error on the transcript only shows the exception, not where it came from.
				Emit the exception as well so that it can be found with a beacon logger (which includes the stack)."
					  anException emit.
					  Smalltalk logStdOutDuring: [ :aLogger | 
						  aLogger
							  nextPutAll: '*** EXCEPTION ***';
							  cr;
							  nextPutAll: anException printString;
							  cr;
							  nextPutAll: (String streamContents: [ :aStream | 
										   anException signalerContext errorReportOn: aStream ]);
							  cr ] ].

				  self setLoadingPromise: nil ])
						then: [ "all good!" ]
						otherwise: [ :anException | anException debug ] ]
]

{ #category : #private }
AsyncSinkStreamBuffer >> privateOnScannedItemLoaded: anItem at: anIndex [
	monitor critical: [
		pendingScanPromises := pendingScanPromises reject: [ :eachPendingScanAssociation |
			| eachScanPromise eachScanBlock eachItemFound |

			eachScanPromise := eachPendingScanAssociation key.
			eachScanBlock := eachPendingScanAssociation value.
			
			eachItemFound := false.

			(eachScanBlock cull: anItem cull: anIndex)
					ifTrue: [
						eachItemFound := true.
						eachScanPromise fulfillWithValue: (AsyncStreamBufferItem new item: anItem; index: anIndex) ].

			eachItemFound ] ]
]

{ #category : #private }
AsyncSinkStreamBuffer >> setLoadingPromise: aPromise [

	monitor critical: [ 
		loadingPromise := aPromise.
		stream isDone ifTrue: [ self announce: AsyncStreamBufferDone new ].
		(aPromise isNil and: [ pendingScanPromises isNotEmpty ]) ifTrue: [ self privateLoadNewItems ] ].

	^ aPromise
]

{ #category : #'api - accessing' }
AsyncSinkStreamBuffer >> sinks [
	^ outputSinks
]

{ #category : #'api - enumeration' }
AsyncSinkStreamBuffer >> size [
	"Return the current buffer length"
	| aBufferSize |
	
	aBufferSize := self amountOfLoadedItems.

	(stream isDone not and: [ aBufferSize isZero ])
		ifTrue: [ self privateLoadNewItems ].

	^ aBufferSize
]

{ #category : #private }
AsyncSinkStreamBuffer >> startLoadingFuture: aFuture [
	| aPromise anInitialAmountOfItems |
		
	anInitialAmountOfItems := self amountOfLoadedItems.
	aPromise := self setLoadingPromise: (aFuture await: executionConfiguration).

	self announce: (AsyncStreamBufferStartedLoading new
		bufferLoadingPromise: aPromise;
		initialAmountOfItems: anInitialAmountOfItems).

	^ aPromise
]

{ #category : #initialization }
AsyncSinkStreamBuffer >> stream: aStream [

	self
		stream: aStream
		sinks: #()
]

{ #category : #initialization }
AsyncSinkStreamBuffer >> stream: aStream sinks: aCollectionOfSinks [

	self
		assert: [ stream isNil ]
		description: [ 'Stream must not be already initialized' ].

	stream := AsyncFuseStream forStream: aStream.
	outputSinks := aCollectionOfSinks
]

{ #category : #'api - announcer' }
AsyncSinkStreamBuffer >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"

	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#unsubscribeTemplate'>
	^ announcer ifNotNil: [ :anAnnouncer | anAnnouncer unsubscribe: anObject ]
]

{ #category : #'api - loading' }
AsyncSinkStreamBuffer >> wait [
	"Synchronously wait for the current loading to finish"
	| aSemaphore |
	
	aSemaphore := Semaphore new.
	monitor critical: [
		loadingPromise ifNotNil: [ :aPromise |
			aPromise
				then: [ aSemaphore signal ]
				otherwise: [ aSemaphore signal ] ] ].
			
	aSemaphore wait
]

{ #category : #'api - announcer' }
AsyncSinkStreamBuffer >> when: anAnnouncementClass do: aBlock [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#whenDoTemplate'>
	^ (announcer ifNil: [ announcer := Announcer new ])
		when: anAnnouncementClass do: aBlock
]

{ #category : #'api - announcer' }
AsyncSinkStreamBuffer >> when: anAnnouncementClass do: aBlock for: aSubscriber [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#whenDoForTemplate'>
	^ (self when: anAnnouncementClass do: aBlock)
		subscriber: aSubscriber;
		yourself
]

{ #category : #'api - announcer' }
AsyncSinkStreamBuffer >> when: anAnnouncementClass send: aSelector to: anObject [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#whenSendToTemplate'>
	^ (announcer ifNil: [ announcer := Announcer new ]) weak
		when: anAnnouncementClass send: aSelector to: anObject
]
