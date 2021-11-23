"
#Flatten Future
Flattens the execution of a future when the output of that future is itself another future. This can be useful when combining futures together to flatten the computation out the final result.
 
##Example
{{gtExample:AsyncFutureExamples>>#flatten}}
"
Class {
	#name : #AsyncFlattenFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'state',
		'future'
	],
	#classVars : [
		'Empty',
		'First',
		'Second'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncFlattenFuture class >> forFuture: anAsyncFuture [
	^ self new future: anAsyncFuture
]

{ #category : #initialization }
AsyncFlattenFuture class >> initialize [
	First := #first.
	Second := #second.
	Empty := #empty.
]

{ #category : #initialization }
AsyncFlattenFuture >> future: anAsyncFuture [
	future := anAsyncFuture.
	state := First -> anAsyncFuture
]

{ #category : #'api - future' }
AsyncFlattenFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	[ state key = First
		ifTrue: [
			(state value poll: anAsynchronousContext)
				ifReady: [ :aReadyPoll | state := Second -> aReadyPoll value asAsyncFuture ]
				ifPending: [ :aPendingPoll | ^ aPendingPoll ] ]
		ifFalse: [
			state key = Second
				ifTrue: [
					(state value poll: anAsynchronousContext)
						ifReady: [ :aReadyPoll |
							state := Empty -> nil.
							^ aReadyPoll ]
						ifPending: [ :aPendingPoll | ^ aPendingPoll ] ]
				ifFalse: [ self error: 'Flatten polled after completion' ] ]
	] repeat
]

{ #category : #'api - future copy' }
AsyncFlattenFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	future := future asyncSimilarCopy.
	state := First -> future
]
