Class {
	#name : #AsyncStreamBufferExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #examples }
AsyncStreamBufferExamples >> bufferOnLargeStream [
	<gtExample>
	| aBuffer theAnnouncements |

	aBuffer := self defaultStreamBuffer stream: (1 to: 10000) asAsyncStream.
	
	theAnnouncements := AsyncSharedOrderedCollection new.
	aBuffer when: Announcement do: [ :anAnnouncement | theAnnouncements add: anAnnouncement ] for: self.
	
	self assert: aBuffer size equals: 0.
	"buffer tries to load the first batch of items only after accessing the #size or #at:"
	aBuffer wait.
	aBuffer unsubscribe: self.
	
	self assert: aBuffer size equals: 20.
	
	self assert: theAnnouncements size equals: 2.
	self assert: (theAnnouncements at: 1) class equals: AsyncStreamBufferStartedLoading.
	self assert: (theAnnouncements at: 2) class equals: AsyncStreamBufferChanged.
	self assert: (theAnnouncements at: 2) index equals: 1.
	self assert: (theAnnouncements at: 2) amountOfLoadedItems equals: 20.
	
	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> defaultStreamBuffer [
	<gtExample>
	| aBuffer |
	
	aBuffer := AsyncSinkStreamBuffer new.

	self assert: aBuffer preloadAmount equals: 20.
	self assert: aBuffer preloadDuration equals: 300 milliSeconds.
	self assert: aBuffer loadSinglesUntil equals: 0.
	
	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> getAtLast [
	<gtExample>
	| aBuffer theLastIndex |

	aBuffer := self bufferOnLargeStream.
	theLastIndex := aBuffer size.
	
	self assert: (aBuffer at: theLastIndex) equals: theLastIndex.
	
	"asking for the last items triggers a preloading"
	aBuffer wait.

	self assert: aBuffer size equals: 40.
	
	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> preloadUntilFound [
	<gtExample>
	| aBuffer theItem |

	aBuffer := self bufferOnLargeStream.
	theItem := (aBuffer preloadUntilFoundSuchThat: [ :each | each = 510 ]) wait.
	
	self assert: theItem index equals: 510.
	self assert: theItem item equals: 510.
	self assert: aBuffer size >= 510.

	^ aBuffer
]
