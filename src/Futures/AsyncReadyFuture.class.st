"
A future that is immediately ready with a value.
"
Class {
	#name : 'AsyncReadyFuture',
	#superclass : 'Object',
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'value'
	],
	#category : 'Futures-Future'
}

{ #category : 'instance creation' }
AsyncReadyFuture class >> value: anObject [
	^ self new value: anObject
]

{ #category : 'api - future' }
AsyncReadyFuture >> poll: anAsynchronousContext [
	| aValue |

	self
		assert: [ value notNil ]
		description: [ 'Value already polled' ].

	aValue := value.
	value := nil.

	^ AsyncPoll ready: aValue
]

{ #category : 'initialization' }
AsyncReadyFuture >> value: anObject [
	value := anObject
]
