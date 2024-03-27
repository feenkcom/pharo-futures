"
An alternative to {{gtClass:AsyncPollFuture}} but executes a {{gtClass:BlockClosure}} in its own forked process.
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
		'waker'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncForkPollFuture class >> pollBlock: aBlock [
	^ self new pollBlock: aBlock
]

{ #category : #accessing }
AsyncForkPollFuture >> initialize [
	super initialize.

	computationValue := AsyncMutex for: AsyncOptionalValue none.
	computationProcess := AsyncMutex for: AsyncOptionalValue none.
	waker := AsyncFutureExecutionAtomicWaker new
]

{ #category : #'api - future' }
AsyncForkPollFuture >> poll: anAsynchronousContext [
	computationValue lock: [ :aValueOption |
		aValueOption
			ifSome: [ :aValue |
				computationValue value: AsyncOptionalValue none.
				^ AsyncPoll ready: aValue ] ].

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
	computationProcess value: ([
		computationValue value: (AsyncOptionalValue some: executedBlock value).
		computationProcess value: (AsyncOptionalValue none).
		waker wakeUp
	] newProcess).

	waker register: anAsynchronousContext waker.
	computationProcess value resume.
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
