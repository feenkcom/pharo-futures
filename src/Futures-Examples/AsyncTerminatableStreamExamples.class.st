Class {
	#name : #AsyncTerminatableStreamExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Streams'
}

{ #category : #examples }
AsyncTerminatableStreamExamples >> terminateNewStream [
	<gtExample>
	<return: #AsyncFuturePromise>
	| future stream next futureCalled |
	futureCalled := false.
	future := AsyncDelayedFuture
			forFuture: [ futureCalled := true.
				42 ] asAsyncFuture
			delay: 1 minute.
	stream := AsyncTerminatableStream
			forStream: (AsyncOnceStream forFuture: future).
	stream terminate.

	next := stream next await.

	self assert: next wait equals: AsyncOptionalValue none.
	self assert: futureCalled not.

	^ next
]

{ #category : #examples }
AsyncTerminatableStreamExamples >> terminatePendingStream [
	<gtExample>
	<return: #AsyncFuturePromise>
	| future stream next futureCalled |
	futureCalled := false.
	future := AsyncDelayedFuture
			forFuture: [ futureCalled := true.
				42 ] asAsyncFuture
			delay: 1 minute.
	stream := AsyncTerminatableStream
			forStream: (AsyncOnceStream forFuture: future).

	next := stream next await.

	[ 50 milliSeconds wait.
	(stream instVarNamed: #waker) hasWaker ] whileFalse.

	stream terminate.

	self assert: next wait equals: AsyncOptionalValue none.
	self assert: futureCalled not.

	^ next
]
