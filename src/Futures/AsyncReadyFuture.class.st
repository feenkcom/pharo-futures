"
A future that is immediately ready with a value.
"
Class {
	#name : #AsyncReadyFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'value',
		'takenValue'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncReadyFuture class >> value: anObject [
	^ self new value: anObject
]

{ #category : #'api - testing' }
AsyncReadyFuture >> isReadyFuture [
	"Return true if a future is a ready future, meaning that the value can be taken synchronously"
	<return: #Boolean>

	^ true
]

{ #category : #'api - future' }
AsyncReadyFuture >> poll: anAsynchronousContext [
	| aValue |

	self
		assert: [ value isSome ]
		description: [ 'Value already polled' ].

	aValue := value value.
	takenValue := value.

	value := AsyncOptionalValue none.

	^ AsyncPoll ready: aValue
]

{ #category : #'api - future copy' }
AsyncReadyFuture >> postSimilarCopy [

	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"

	takenValue isSome ifTrue: [ value := takenValue ].
	value := value map: [ :anObject | anObject asyncSimilarCopy ].
	takenValue := AsyncOptionalValue none
]

{ #category : #printing }
AsyncReadyFuture >> printOn: aStream [

	"Append a sequence of characters to aStream that identify the receiver."

	super printOn: aStream.
	aStream
		nextPutAll: ' value: ';
		print: value
]

{ #category : #'api - future' }
AsyncReadyFuture >> takeOutput [
	^ self
		takeOutput: [ :aValue | aValue ]
		ifNone: [ self error: 'The future is not done or the outout is already taken' ]
]

{ #category : #'api - future' }
AsyncReadyFuture >> takeOutput: aBlock ifNone: aNoneBlock [
	^ value
		ifSome: [ :aValue |
			value := AsyncOptionalValue none.
			aBlock value: aValue
		] ifNone: aNoneBlock
]

{ #category : #initialization }
AsyncReadyFuture >> value: anObject [
	value := AsyncOptionalValue some: anObject.
	takenValue := AsyncOptionalValue none
]
