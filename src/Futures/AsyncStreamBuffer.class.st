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
		'preloadAmount',
		'loadSinglesUntil',
		'executionConfiguration',
		'stream',
		'bufferSink',
		'outputSinks',
		'pausableSink',
		'streamLoadingPromise',
		'pendingScanPromises',
		'chunkLoadingPromise'
	],
	#category : #'Futures-Buffer'
}

{ #category : #'instance creation' }
AsyncStreamBuffer class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #'private - accessing' }
AsyncStreamBuffer >> amountOfLoadedItems [
	^ bufferSink collection size
]

{ #category : #'api - announcer' }
AsyncStreamBuffer >> announce: anAnnouncement [
	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#announceTemplate'>
	announcer ifNotNil: [ :anAnnouncer | anAnnouncer announce: anAnnouncement ].
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> at: anIndex [
	| requestedItem |

	requestedItem := bufferSink collection at: anIndex.

	(stream isDone not and: [ anIndex = self amountOfLoadedItems ])
		ifTrue: [ self continue ].

	^ requestedItem
]

{ #category : #'private - accessing' }
AsyncStreamBuffer >> bufferLoadingPromise [
	"Return a promise that will be fulfilled when the buffer finishes preloading items"
	<return: #TAsyncPromise>

	^ chunkLoadingPromise
]

{ #category : #'private - accessing' }
AsyncStreamBuffer >> bufferSnapshot [
	"Returns a snapshot copy of the current loaded items in the buffer"
	<return: #Collection>

	^ bufferSink collection copy
]

{ #category : #'api - loading' }
AsyncStreamBuffer >> continue [
	<return: #TAsyncPromise>
	| anInitialAmountOfItems aLoadingPromise |
	self privateEnsureLoading.
	
	anInitialAmountOfItems := self amountOfLoadedItems.
	aLoadingPromise := self privateContinueLoading.
	
	self notifyStartedLoading: aLoadingPromise initialAmountOfItems: anInitialAmountOfItems.

	^ aLoadingPromise
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

{ #category : #'api - enumeration' }
AsyncStreamBuffer >> detect: aBlock ifFound: foundBlock ifNone: exceptionBlock [
	self do: [ :each | (aBlock value: each) ifTrue: [ ^ foundBlock cull: each ] ].
	^ exceptionBlock value
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

{ #category : #'gt - extensions' }
AsyncStreamBuffer >> gtBufferedItemsFor: aView [
	<gtView>
	
	^ aView list
		title: 'Buffered';
		priority: 5;
		items: [ bufferSink collection asArray ];
		updateWhen: Announcement in: (announcer ifNil: [ announcer := Announcer new ]);
		actionUpdateButton
]

{ #category : #'api - enumeration' }
AsyncStreamBuffer >> indexOf: anObject [
	1 to: self size do: [ :i | (self at: i) = anObject ifTrue: [ ^ i ] ].
	^0
]

{ #category : #initialization }
AsyncStreamBuffer >> initialize [
	super initialize.

	monitor := Monitor new.
	stream := nil.

	bufferSink := AsyncCollectionSink forCollection: AsyncSharedOrderedCollection new.
	pausableSink := nil.
	outputSinks := nil.

	streamLoadingPromise := nil.
	chunkLoadingPromise := true asAsyncPromise.
	pendingScanPromises := OrderedCollection new.

	preloadAmount := self defaultPreloadAmount.
	executionConfiguration := self defaultExecutionConfiguration.
	loadSinglesUntil := self defaultLoadSinglesUntil
]

{ #category : #testing }
AsyncStreamBuffer >> isDone [
	"Return true if there are no more items to poll"

	^ monitor critical: [ stream isDone ]
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> loadSinglesUntil [
	^ loadSinglesUntil
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> loadSinglesUntil: aNumber [
	loadSinglesUntil := aNumber
]

{ #category : #'private - notifying' }
AsyncStreamBuffer >> notifyItemsLoaded: anAmountOfItems at: anIndex [
	self announce: (AsyncStreamBufferChanged new newItems: (Array new: anAmountOfItems); index: anIndex)
]

{ #category : #'private - notifying' }
AsyncStreamBuffer >> notifyStartedLoading: aPromise initialAmountOfItems: anInitialAmountOfItems [
	self announce: (AsyncStreamBufferStartedLoading new
		bufferLoadingPromise: aPromise;
		initialAmountOfItems: anInitialAmountOfItems)
]

{ #category : #'private - notifying' }
AsyncStreamBuffer >> notifyStreamDone [
	self announce: AsyncStreamBufferDone new
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
AsyncStreamBuffer >> preloadDuration: anObject [
]

{ #category : #'api - loading' }
AsyncStreamBuffer >> preloadUntilFoundSuchThat: aBlock [
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
		streamLoadingPromise ifNotNil: [ self continue ].

		^ aPendingScanPromise ]
]

{ #category : #'private - loading' }
AsyncStreamBuffer >> privateContinueLoading [
	<return: #TAsyncPromise>
	| toLoad |

	toLoad := self amountOfLoadedItems < loadSinglesUntil
		ifTrue: [ 1 ]
		ifFalse: [ preloadAmount ].

	^ chunkLoadingPromise := pausableSink resume: toLoad
]

{ #category : #'private - loading' }
AsyncStreamBuffer >> privateEnsureLoading [
	monitor critical: [ 
	 	streamLoadingPromise ifNotNil: [ ^ self ].
	
		"Watch out! We must first assign the promise and only then handle then:otherwise:"
		(streamLoadingPromise := (stream forward: pausableSink) await: executionConfiguration)
			then: [ self notifyStreamDone ]
			otherwise: [ :anException | 
				"Logging the error on the transcript only shows the exception, not where it came from.
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
					cr ] ] ]
]

{ #category : #'private - event handling' }
AsyncStreamBuffer >> privateOnItemLoaded: anItem at: anIndex [
	"Is sent after an item was loaded at a given position."
	
	self notifyItemsLoaded: 1 at: anIndex.

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

			eachItemFound ].
		pendingScanPromises ifNotEmpty: [ self continue ] ]
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> sinks [
	^ outputSinks
]

{ #category : #'api - accessing' }
AsyncStreamBuffer >> size [
	"Return the current buffer length"
	| aBufferSize |
	
	aBufferSize := self amountOfLoadedItems.

	(stream isDone not and: [ aBufferSize isZero ])
		ifTrue: [ self continue ].

	^ aBufferSize
]

{ #category : #'api - loading' }
AsyncStreamBuffer >> stop [
	stream stop
]

{ #category : #initialization }
AsyncStreamBuffer >> stream: aStream [

	self
		stream: aStream
		sinks: #()
]

{ #category : #initialization }
AsyncStreamBuffer >> stream: aStream sinks: aCollectionOfSinks [

	self
		assert: [ stream isNil ]
		description: [ 'Stream must not be already initialized' ].

	stream := AsyncFuseStream forStream: aStream.

	outputSinks := aCollectionOfSinks.
	
	pausableSink := AsyncPausableSink forSink: (AsyncSpreadSink forSinks:
		{ 
			bufferSink.
			AsyncStreamBufferSentSink new streamBuffer: self.
		},
		outputSinks)
]

{ #category : #'api - announcer' }
AsyncStreamBuffer >> unsubscribe: anObject [
	"Unsubscribe all subscriptions of anObject from the receiver"

	<generatedFrom: #'TGtRobocoderAnnouncerTemplate>>#unsubscribeTemplate'>
	^ announcer ifNotNil: [ :anAnnouncer | anAnnouncer unsubscribe: anObject ]
]

{ #category : #'api - loading' }
AsyncStreamBuffer >> wait [
	"! Debugging and testing only !"
	"Synchronously wait for the current loading to finish"
	| aSemaphore |
	
	aSemaphore := Semaphore new.
	monitor critical: [
		chunkLoadingPromise 
			then: [ aSemaphore signal ]
			otherwise: [ aSemaphore signal ] ].

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
