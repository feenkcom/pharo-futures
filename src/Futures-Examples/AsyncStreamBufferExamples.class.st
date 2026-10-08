Class {
	#name : #AsyncStreamBufferExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Buffer'
}

{ #category : #examples }
AsyncStreamBufferExamples >> announcementsAcrossBatches [
	<gtExample>
	<return: #AsyncStreamBuffer>
	| aBuffer theAnnouncements theLoadingPromises |
	aBuffer := self defaultStreamBuffer stream: (1 to: 10000) asAsyncStream.
	theAnnouncements := AsyncSharedOrderedCollection new.
	theLoadingPromises := OrderedCollection new.
	aBuffer
		when: Announcement
		do: [ :anAnnouncement | theAnnouncements add: anAnnouncement ]
		for: self.

	[
		1 to: 5 do: [ :batch |
			| aLoadingPromise aStartAnnouncement anOffset |
			aLoadingPromise := aBuffer continue.
			aBuffer wait.
			theLoadingPromises add: aLoadingPromise.
			self assert: aBuffer amountOfLoadedItems equals: batch * 20.
			self assert: theAnnouncements size equals: batch * 21.
			anOffset := (batch - 1) * 21.
			aStartAnnouncement := theAnnouncements at: anOffset + 1.
			self assert: aStartAnnouncement class equals: AsyncStreamBufferStartedLoading.
			self assert: aStartAnnouncement initialAmountOfItems equals: (batch - 1) * 20.
			self assert: aStartAnnouncement bufferLoadingPromise == aLoadingPromise.
			self assert: aBuffer bufferLoadingPromise == aLoadingPromise.
			batch > 1 ifTrue: [
				self assert: aLoadingPromise ~~ (theLoadingPromises at: batch - 1) ].
			1 to: 20 do: [ :i |
				| anAnnouncement |
				anAnnouncement := theAnnouncements at: anOffset + i + 1.
				self assert: anAnnouncement class equals: AsyncStreamBufferChanged.
				self assert: anAnnouncement index equals: (batch - 1) * 20 + i.
				self assert: anAnnouncement amountOfLoadedItems equals: 1 ] ]
	] ensure: [ aBuffer unsubscribe: self ].
	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> bufferOnLargeStream [
	<gtExample>
	<return: #AsyncStreamBuffer>
	| aBuffer theAnnouncements |
	aBuffer := self defaultStreamBuffer stream: (1 to: 10000) asAsyncStream.

	theAnnouncements := AsyncSharedOrderedCollection new.
	aBuffer
		when: Announcement
		do: [ :anAnnouncement | theAnnouncements add: anAnnouncement ]
		for: self.

	self assert: aBuffer size equals: 0.	"buffer tries to load the first batch of items only after accessing the #size or #at:"
	aBuffer wait.
	aBuffer unsubscribe: self.

	self assert: aBuffer size equals: 20.

	self assert: theAnnouncements size equals: 21.
	self
		assert: (theAnnouncements at: 1) class
		equals: AsyncStreamBufferStartedLoading.

	1
		to: 20
		do: [ :i | 
			self assert: (theAnnouncements at: i + 1) class equals: AsyncStreamBufferChanged.
			self assert: (theAnnouncements at: i + 1) index equals: i.
			self assert: (theAnnouncements at: i + 1) amountOfLoadedItems equals: 1 ].

	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> completedSmallStream [
	<gtExample>
	| aBuffer aSemaphore |
	aBuffer := self defaultStreamBuffer stream: (1 to: 7) asAsyncStream.
	aBuffer continue.
	aSemaphore := Semaphore new.
	(aBuffer instVarNamed: 'streamLoadingPromise')
		then: [ aSemaphore signal ]
		otherwise: [ aSemaphore signal ].
	self assert: (aSemaphore waitTimeoutSeconds: 5) not.
	self assert: aBuffer isDone.
	self assert: aBuffer amountOfLoadedItems equals: 7.
	^ aBuffer

]

{ #category : #examples }
AsyncStreamBufferExamples >> continueAfterCompletion [
	<gtExample>
	| aBuffer aPromise |
	aBuffer := self completedSmallStream.
	3 timesRepeat: [
		aPromise := aBuffer continue.
		self assert: (self valueOfPromise: aBuffer bufferLoadingPromise) equals: true.
		self assert: (self valueOfPromise: aPromise) equals: true ].
	self assert: aBuffer amountOfLoadedItems equals: 7.
	^ aBuffer

]

{ #category : #examples }
AsyncStreamBufferExamples >> defaultStreamBuffer [
	<gtExample>
	<return: #AsyncStreamBuffer>
	| aBuffer |
	aBuffer := AsyncStreamBuffer new.

	self assert: aBuffer preloadAmount equals: 20.
	self assert: aBuffer loadSinglesUntil equals: 0.

	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> getAtLast [
	<gtExample>
	<return: #AsyncStreamBuffer>
	| aBuffer theLastIndex |
	aBuffer := self bufferOnLargeStream.
	theLastIndex := aBuffer size.

	self assert: (aBuffer at: theLastIndex) equals: theLastIndex.	"asking for the last items triggers a preloading"
	aBuffer wait.

	self assert: aBuffer size equals: 40.

	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> preloadExistingAfterCompletion [
	<gtExample>
	| aBuffer aPromise anItem |
	aBuffer := self completedSmallStream.
	aPromise := aBuffer preloadUntilFoundSuchThat: [ :each :index | each = 4 and: [ index = 4 ] ].
	anItem := self valueOfPromise: aPromise.
	self assert: anItem isFound.
	self assert: anItem item equals: 4.
	self assert: anItem index equals: 4.
	self assert: (aBuffer instVarNamed: 'pendingScanPromises') isEmpty.
	^ aBuffer

]

{ #category : #examples }
AsyncStreamBufferExamples >> preloadMissingAfterCompletion [
	<gtExample>
	| aBuffer aPromise |
	aBuffer := self completedSmallStream.
	aPromise := aBuffer preloadUntilFoundSuchThat: [ :each | each = 99 ].
	self assert: (self valueOfPromise: aPromise) isNotFound.
	self assert: (aBuffer instVarNamed: 'pendingScanPromises') isEmpty.
	^ aBuffer

]

{ #category : #examples }
AsyncStreamBufferExamples >> preloadMissingAfterEmptyCompletion [
	<gtExample>
	| aBuffer aPromise |
	aBuffer := self defaultStreamBuffer stream: #() asAsyncStream.
	self valueOfPromise: aBuffer continue.
	self valueOfPromise: (aBuffer instVarNamed: 'streamLoadingPromise').
	self assert: aBuffer isDone.
	aPromise := aBuffer preloadUntilFoundSuchThat: [ :each | true ].
	self assert: (self valueOfPromise: aPromise) isNotFound.
	self assert: (aBuffer instVarNamed: 'pendingScanPromises') isEmpty.
	self assert: (self valueOfPromise: aBuffer continue) equals: true.
	^ aBuffer

]

{ #category : #examples }
AsyncStreamBufferExamples >> preloadNotFoundUntilEndOfStream [
	<gtExample>
	<return: #AsyncStreamBuffer>
	| aBuffer theItem |
	aBuffer := self bufferOnLargeStream.
	theItem := (aBuffer preloadUntilFoundSuchThat: [ :each | each = 9999999 ]) wait.

	self assert: theItem isNotFound.

	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> preloadUntilFound [
	<gtExample>
	<return: #AsyncStreamBuffer>
	| aBuffer theItem |
	aBuffer := self bufferOnLargeStream.
	theItem := (aBuffer preloadUntilFoundSuchThat: [ :each | each = 510 ]) wait.

	self assert: theItem index equals: 510.
	self assert: theItem item equals: 510.
	self assert: aBuffer size >= 510.

	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> preloadWhileLoading [
	<gtExample>
	| aBuffer anItem aPromise |
	aBuffer := self defaultStreamBuffer
		preloadAmount: 2;
		stream: (1 to: 25) asAsyncStream.
	aPromise := aBuffer preloadUntilFoundSuchThat: [ :each | each = 24 ].
	anItem := self valueOfPromise: aPromise.
	self assert: anItem item equals: 24.
	self assert: anItem index equals: 24.
	aPromise := aBuffer preloadUntilFoundSuchThat: [ :each | each = 99 ].
	self assert: (self valueOfPromise: aPromise) isNotFound.
	self valueOfPromise: (aBuffer instVarNamed: 'streamLoadingPromise').
	self assert: aBuffer isDone.
	self assert: (aBuffer instVarNamed: 'pendingScanPromises') isEmpty.
	^ aBuffer

]

{ #category : #examples }
AsyncStreamBufferExamples >> resumeDuringCompletion [
	<gtExample>
	| aBuffer aPromise |
	100 timesRepeat: [
		aBuffer := self defaultStreamBuffer stream: (1 to: 7) asAsyncStream.
		aPromise := aBuffer continue.
		self valueOfPromise: aPromise.
		aPromise := aBuffer continue.
		self valueOfPromise: aPromise.
		self valueOfPromise: (aBuffer instVarNamed: 'streamLoadingPromise').
		self assert: aBuffer isDone.
		self assert: (self valueOfPromise: aBuffer continue) equals: true.
		self assert: (aBuffer instVarNamed: 'pausableSink') isNotNil ].
	^ aBuffer

]

{ #category : #testing }
AsyncStreamBufferExamples >> runLiveRegressionChecks [
	<gtExample>
	| results |
	results := OrderedCollection new.
	#(defaultStreamBuffer completedSmallStream preloadMissingAfterCompletion preloadExistingAfterCompletion continueAfterCompletion preloadMissingAfterEmptyCompletion preloadWhileLoading resumeDuringCompletion)
		do: [ :selector |
			[ self perform: selector.
				results add: { selector. #success } ]
				on: Error
				do: [ :error | results add: { selector. error class name. error messageText } ] ].
	^ results asArray

]

{ #category : #testing }
AsyncStreamBufferExamples >> valueOfPromise: aPromise [
	| aSemaphore aValue anError |
	aSemaphore := Semaphore new.
	aPromise
		then: [ :value | aValue := value. aSemaphore signal ]
		otherwise: [ :error | anError := error. aSemaphore signal ].
	self assert: (aSemaphore waitTimeoutSeconds: 5) not.
	self assert: anError isNil.
	^ aValue

]
