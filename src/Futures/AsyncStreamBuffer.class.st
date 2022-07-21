"
#Async stream buffer
Loads more items from the supplied stream  when sender asks for an item {{gtMethod:AsyncStreamBuffer>>#at:}} a position close to the end of the buffered collection. In addition, it is possible to request the buffer to preload the items until an item matching the condition is found or the end of the stream is reached.

##Announcements
When new items are loaded, the buffer announces {{gtClass:AsyncStreamBufferChanged}} which indicates that new items were added to the buffer. It is useful when the UI should be notified when new items are ready to be displayed.
"
Class {
	#name : #AsyncStreamBuffer,
	#superclass : #Object,
	#instVars : [
		'announcer',
		'monitor',
		'stream',
		'buffer',
		'loadingPromise',
		'pendingScanPromises',
		'preloadAmount',
		'preloadDuration',
		'executionConfiguration',
		'loadSinglesUntil',
		'loadedItems'
	],
	#category : #'Futures-Buffer'
}

{ #category : #'instance creation' }
AsyncStreamBuffer class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #'api - announcer' }
AsyncStreamBuffer >> announce: anAnnouncement [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#announceTemplate'>
	announcer ifNotNil: [ :anAnnouncer | anAnnouncer announce: anAnnouncement ].
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> at: anIndex [
	^ monitor critical: [ 
		| requestedItem |

		requestedItem := buffer at: anIndex.

		(stream isDone not and: [ anIndex = buffer size ])
			ifTrue: [ self privateLoadNewItems ].

		requestedItem ]
]

{ #category : #'api - loading' }
AsyncStreamBuffer >> bufferLoadingPromise [
	"Return a promise that will be fulfilled when the buffer finishes preloading items"
	<return: #TAsyncPromise>

	^ monitor critical: [ 
		loadingPromise
			ifNil: [ true asAsyncPromise ]
			ifNotNil: [ loadingPromise then: [ true ] ] ]
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> bufferSnapshot [
	"Returns a snapshot copy of the current loaded items in the buffer"
	<return: #Collection>

	^ monitor critical: [ buffer copy ]
]

{ #category : #initialization }
AsyncStreamBuffer >> defaultExecutionConfiguration [
	^ AsyncFutureExecutionConfiguration default
]

{ #category : #initialization }
AsyncStreamBuffer >> defaultLoadSinglesUntil [
	^ 0
]

{ #category : #initialization }
AsyncStreamBuffer >> defaultPreloadAmount [
	^ 20
]

{ #category : #initialization }
AsyncStreamBuffer >> defaultPreloadDuration [
	^ 300 milliSeconds
]

{ #category : #'api - enumeration' }
AsyncStreamBuffer >> do: aBlock [
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
AsyncStreamBuffer >> executionConfiguration [

	^ executionConfiguration
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> executionConfiguration: anObject [

	executionConfiguration := anObject
]

{ #category : #initialization }
AsyncStreamBuffer >> initialize [
	super initialize.
	
	monitor := Monitor new.
	buffer := OrderedCollection new.
	stream := nil.
	loadingPromise := nil.
	pendingScanPromises := OrderedCollection new.
	preloadAmount := self defaultPreloadAmount.
	preloadDuration := self defaultPreloadDuration.
	executionConfiguration := self defaultExecutionConfiguration.
	loadSinglesUntil := self defaultLoadSinglesUntil.
	loadedItems := 0.
]

{ #category : #testing }
AsyncStreamBuffer >> isDone [
	"Return true if there are no more items to poll"

	^ monitor critical: [ stream isDone ]
]

{ #category : #accessing }
AsyncStreamBuffer >> loadSinglesUntil [
	^ loadSinglesUntil
]

{ #category : #accessing }
AsyncStreamBuffer >> loadSinglesUntil: aNumber [
	loadSinglesUntil := aNumber
]

{ #category : #accessing }
AsyncStreamBuffer >> loadedItems [
	^ loadedItems
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> preloadAmount [
	"Return the maximum amount of items to be preloaded by the buffer"
	<return:  #Number>

	^ preloadAmount
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> preloadAmount: aNumber [
	preloadAmount := aNumber
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> preloadDuration [
	"Returns the amount of time the buffer should wait for new
	items before stopping pre-loading. It is useful when it takes a lot of
	time to fetch one item, which would result in a long delay before
	#preloadAmount of items are ready"
	<return: #Duration>

	^ preloadDuration
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> preloadDuration: anObject [
	preloadDuration := anObject
]

{ #category : #'api - loading' }
AsyncStreamBuffer >> preloadUntilFoundSuchThat: aBlock [
	<return: #TAsyncPromise>

	monitor critical: [
		| aPendingScanPromise |
		"first let's try to find among existing buffered items"
		buffer withIndexDo: [ :eachItem :eachIndex | 
			(aBlock cull: eachItem cull: eachIndex)
				ifTrue: [ ^ (AsyncStreamBufferItem new item: eachItem; index: eachIndex) asAsyncPromise ] ].

		"the value was not found, let's register a pending scan"
		aPendingScanPromise := AsyncPendingPromise new.
		pendingScanPromises add: (aPendingScanPromise -> aBlock).
		"and request the loading of new items"
		self privateLoadNewItems.

		^ aPendingScanPromise ]
]

{ #category : #private }
AsyncStreamBuffer >> privateLoadNewItems [
	<return: #TAsyncPromise>
	| toLoad |
	^ monitor critical: [ 
		  loadingPromise ifNotNil: [ ^ loadingPromise ].

		  "Watch out! We must first assign the promise and only then handle then:otherwise:"
		  toLoad := loadedItems < loadSinglesUntil
			            ifTrue: [ 1 ]
			            ifFalse: [ preloadAmount ].
		  ((self setLoadingPromise: (((stream for: preloadDuration) take: toLoad) toArray await: executionConfiguration))
			  then: [ :newItems | 
				  loadedItems := loadedItems + newItems size.
				  newItems
					  ifNotEmpty: [ self privateOnItemsLoaded: newItems ]
					  ifEmpty: [ self setLoadingPromise: nil ] ]
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
AsyncStreamBuffer >> privateOnItemsLoaded: theNewItems [
	monitor critical: [
		| aPreviousBufferSize |
		
		aPreviousBufferSize := buffer size.

		buffer addAll: theNewItems.
		
		self setLoadingPromise: nil.

		pendingScanPromises := pendingScanPromises reject: [ :eachPendingScanAssociation |
			| eachScanPromise eachScanBlock eachItemFound eachItemIndex |

			eachScanPromise := eachPendingScanAssociation key.
			eachScanBlock := eachPendingScanAssociation value.
			
			eachItemFound := false.
			eachItemIndex := aPreviousBufferSize .

			[ eachItemFound not and: [ eachItemIndex < buffer size  ] ] whileTrue: [
				eachItemIndex := eachItemIndex + 1.
				(eachScanBlock cull: (buffer at: eachItemIndex) cull: eachItemIndex)
					ifTrue: [
						eachItemFound := true.
						eachScanPromise fulfillWithValue: (AsyncStreamBufferItem new item: (buffer at: eachItemIndex); index: eachItemIndex) ] ].

			eachItemFound ].
		pendingScanPromises ifNotEmpty: [ self privateLoadNewItems ].
		self announce: (AsyncStreamBufferChanged new newItems: theNewItems; index: aPreviousBufferSize + 1) ]
]

{ #category : #private }
AsyncStreamBuffer >> setLoadingPromise: aPromise [

	monitor critical: [ 
		loadingPromise := aPromise.
		aPromise ifNotNil: [ self announce: (AsyncStreamBufferStartedLoading new bufferLoadingPromise: aPromise) ].
		stream isDone ifTrue: [ self announce: AsyncStreamBufferDone new ] ].

	^ aPromise
]

{ #category : #'api - enumeration' }
AsyncStreamBuffer >> size [
	"Return the current buffer length"
	| aBufferSize |
	
	aBufferSize := monitor critical: [ buffer size ].

	(stream isDone not and: [ aBufferSize isZero ])
		ifTrue: [ self privateLoadNewItems ].

	^ aBufferSize
]

{ #category : #initialization }
AsyncStreamBuffer >> stream: aStream [

	self
		assert: [ stream isNil ]
		description: [ 'Stream must not be already initialized' ].

	stream := AsyncFuseStream forStream: aStream
]

{ #category : #'api - announcer' }
AsyncStreamBuffer >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"

	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#unsubscribeTemplate'>
	^ announcer ifNotNil: [ :anAnnouncer | anAnnouncer unsubscribe: anObject ]
]

{ #category : #'api - loading' }
AsyncStreamBuffer >> wait [
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
AsyncStreamBuffer >> when: anAnnouncementClass do: aBlock [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#whenDoTemplate'>
	^ (announcer ifNil: [ announcer := Announcer new ])
		when: anAnnouncementClass do: aBlock
]

{ #category : #'api - announcer' }
AsyncStreamBuffer >> when: anAnnouncementClass do: aBlock for: aSubscriber [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#whenDoForTemplate'>
	^ (self when: anAnnouncementClass do: aBlock)
		subscriber: aSubscriber;
		yourself
]

{ #category : #'api - announcer' }
AsyncStreamBuffer >> when: anAnnouncementClass send: aSelector to: anObject [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#whenSendToTemplate'>
	^ (announcer ifNil: [ announcer := Announcer new ]) weak
		when: anAnnouncementClass send: aSelector to: anObject
]
