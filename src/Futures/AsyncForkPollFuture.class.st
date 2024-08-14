"
An alternative to {{gtClass:AsyncPollFuture}} but executes a {{gtClass:BlockClosure}} in its own forked process.
##Error handling
{{gtClass:Error}}  that happen within an executed block closure are handled, wrapped as {{gtClass:AsyncForkedFutureError}} and signalled from within future's worker process. An error handler of can be changed using {{gtMethod:AsyncForkPollFuture>>#errorHandler:}} or {{gtMethod:AsyncForkPollFuture>>#withPassExceptionHandler}}. Initially, a default global event handler is used.
"
Class {
	#name : #AsyncForkPollFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'pollBlock',
		'executedBlock',
		'computationProcess',
		'computationValue',
		'waker',
		'computationError',
		'errorHandler'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncForkPollFuture class >> pollBlock: aBlock [
	^ self new pollBlock: aBlock
]

{ #category : #accessing }
AsyncForkPollFuture >> errorHandler: anErrorHandler [
	errorHandler := anErrorHandler
]

{ #category : #accessing }
AsyncForkPollFuture >> initialize [
	super initialize.

	computationValue := AsyncMutex for: AsyncOptionalValue none.
	computationError := AsyncMutex for: AsyncOptionalValue none.
	computationProcess := AsyncMutex for: AsyncOptionalValue none.
	errorHandler := AsyncFutureExecutionConfiguration defaultErrorHandler.
	waker := AsyncFutureExecutionAtomicWaker new
]

{ #category : #'api - future' }
AsyncForkPollFuture >> poll: anAsynchronousContext [
	computationValue lock: [ :aValueOption |
		aValueOption
			ifSome: [ :aValue |
				computationValue value: AsyncOptionalValue none.
				^ AsyncPoll ready: aValue ] ].

	computationError lock: [ :anErrorOption |
		anErrorOption
			ifSome: [ :anError |
				computationError value: AsyncOptionalValue none.
				anError signal.
				^ AsyncPoll ready: nil ] ].

	computationProcess lock: [ :aProcessOption |
		aProcessOption
			ifSome: [ :aProcess |
				waker register: anAsynchronousContext waker.
				^ AsyncPoll pending ] ].

	self
		assert: [ pollBlock notNil ]
		description: [ 'Block already polled' ].

	executedBlock := pollBlock.
	pollBlock := nil.
	computationProcess value: (AsyncOptionalValue some: [
		[
			computationValue value: (AsyncOptionalValue some: executedBlock value).
			computationProcess value: (AsyncOptionalValue none).
			waker wakeUp
		] on: Error do: [ :anError |
			| anExceptionCopy |
			
			"we freeze a copy of the error in order to still be able to handle a live error later"
			anExceptionCopy := anError copy.
			anExceptionCopy signalContext
				ifNotNil: [ anExceptionCopy freeze ].

			computationError value: (AsyncOptionalValue some: (AsyncForkedFutureError new sourceError: anExceptionCopy)).
			computationProcess value: (AsyncOptionalValue none).
			waker wakeUp.
			errorHandler handleError: anError ].
	] newProcess).

	waker register: anAsynchronousContext waker.
	computationProcess value value resume.
	^ AsyncPoll pending
]

{ #category : #initialization }
AsyncForkPollFuture >> pollBlock: aBlock [
	pollBlock := aBlock.
	executedBlock := nil
]

{ #category : #'api - future copy' }
AsyncForkPollFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"

	computationValue := AsyncMutex for: AsyncOptionalValue none.
	computationProcess := AsyncMutex for: AsyncOptionalValue none.
	waker := AsyncFutureExecutionAtomicWaker new.
	
	executedBlock ifNotNil: [ pollBlock := executedBlock ].
	executedBlock := nil
]

{ #category : #'api - future' }
AsyncForkPollFuture >> withPassExceptionHandler [
	"Allow errors in a forked process to pass and raise a debugger if not caught."
	
	errorHandler := AsyncPassExceptionHandler new
]
