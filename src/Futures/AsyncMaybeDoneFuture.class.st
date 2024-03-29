Class {
	#name : #AsyncMaybeDoneFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'state'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncMaybeDoneFuture class >> forFuture: aFuture [
	^ self new setFuture: aFuture
]

{ #category : #accessing }
AsyncMaybeDoneFuture >> borrowOutput: aBlock ifNone: aNoneBlock [
	^ state key = #done
		ifTrue: [ aBlock value: state value ]
		ifFalse: aNoneBlock
]

{ #category : #'api - future' }
AsyncMaybeDoneFuture >> poll: anAsynchronousContext [
	state key = #gone
		ifTrue: [ self error: ('{1} is polled after being taken' format: { self printString }) ].

	state key = #future
		ifTrue: [
			(state value poll: anAsynchronousContext)
				ifReady: [ :aReadyPoll | self setDone: aReadyPoll value ]
				ifPending: [ :aPendingPoll | ^ aPendingPoll ] ].
			
	^ AsyncPoll ready: self
]

{ #category : #initialization }
AsyncMaybeDoneFuture >> setDone: anObject [
	state := #done -> anObject
]

{ #category : #initialization }
AsyncMaybeDoneFuture >> setFuture: aFuture [
	state := #future -> aFuture
]

{ #category : #initialization }
AsyncMaybeDoneFuture >> setGone [
	state := #gone -> nil
]

{ #category : #accessing }
AsyncMaybeDoneFuture >> takeOutput [
	^ self
		takeOutput: [ :aValue | aValue ]
		ifNone: [ self error: 'The future is not done or the output is already taken' ]
]

{ #category : #accessing }
AsyncMaybeDoneFuture >> takeOutput: aBlock ifNone: aNoneBlock [
	^ state key = #done
		ifTrue: [
			| aValue |
			
			aValue := state value.
			self setGone.
			aBlock value: aValue ]
		ifFalse: aNoneBlock
]
