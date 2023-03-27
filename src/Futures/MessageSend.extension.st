Extension { #name : #MessageSend }

{ #category : #'*Futures' }
MessageSend >> asAsyncFuture [
	^ AsyncPollFuture pollBlock: self
]

{ #category : #'*Futures' }
MessageSend >> asAsyncPromise [
	^ AsyncFuturePromise new future: self asAsyncFuture
]

{ #category : #'*Futures' }
MessageSend >> entryPriority [
	"Answer the priority of the receiver when submitted as a task to TaskIt. 0 is highest priority"

	^0
]
