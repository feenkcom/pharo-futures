Class {
	#name : #AsyncPendingFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#category : #'Futures-Base - Futures'
}

{ #category : #'api - future' }
AsyncPendingFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	^ AsyncPoll pending
]
