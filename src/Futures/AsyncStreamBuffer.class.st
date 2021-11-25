"
#Async stream buffer
Loads more items from the supplied stream  when sender ask for an item {{gtMethod:AsyncStreamBuffer>>#at:}} a position close to the end of the buffered collection. In addition, it is possible to request the buffer to preload the items until an item matching the condition is found or the end of the stream is reached.

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
		'pendingScanPromises'
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

{ #category : #accessing }
AsyncStreamBuffer >> at: anIndex [
	^ monitor critical: [ 
		| requestedItem |

		requestedItem := buffer at: anIndex.

		(stream isDone not and: [ anIndex = buffer size ])
			ifTrue: [ self privateLoadNewItems ].

		requestedItem ]
]

{ #category : #accessing }
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

{ #category : #initialization }
AsyncStreamBuffer >> initialize [
	super initialize.
	
	monitor := Monitor new.
	buffer := OrderedCollection new.
	stream := nil.
	loadingPromise := nil.
	pendingScanPromises := OrderedCollection new.
]

{ #category : #testing }
AsyncStreamBuffer >> isDone [
	"Return true if there are no more items to poll"

	^ monitor critical: [ stream isDone ]
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
	monitor critical: [ 
		loadingPromise
			ifNotNil: [ ^ self ].
		loadingPromise := ((stream for: 300 milliSeconds) take: 20) toArray asAsyncPromise
			then: [ :newItems | newItems ifNotEmpty:  [ self privateOnItemsLoaded: newItems ] ]
			otherwise: [ :anException | monitor critical: [
				"Logging the error on the transcript only shows the exception, not where it came from.
				Emit the exception as well so that it can be found with a beacon logger (which includes the stack)."
				anException emit.
				Smalltalk logStdOutDuring: [ :aLogger |
					aLogger
						nextPutAll: '*** EXCEPTION ***'; cr;
						nextPutAll: anException printString; cr;
						nextPutAll: (String
							streamContents: [ :aStream | anException signalerContext errorReportOn: aStream ]); cr ] ].

				loadingPromise := nil ] ]
]

{ #category : #private }
AsyncStreamBuffer >> privateOnItemsLoaded: theNewItems [
	monitor critical: [
		| aPreviousBufferSize |
		
		aPreviousBufferSize := buffer size.

		buffer addAll: theNewItems.
		loadingPromise := nil.

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

{ #category : #accessing }
AsyncStreamBuffer >> size [
	"Return the current buffer length"

	^ monitor critical: [ buffer size ]
]

{ #category : #initialization }
AsyncStreamBuffer >> stream: aStream [

	self
		assert: [ stream isNil ]
		description: [ 'Stream must not be already initialized' ].

	stream := AsyncFuseStream forStream: aStream.
	self privateLoadNewItems
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
