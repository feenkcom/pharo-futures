Class {
	#name : #AsyncStreamEphemeronForwardFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'ephemeronRegistry',
		'sink',
		'bufferedItem',
		'weakEphemeron'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncStreamEphemeronForwardFuture class >> forStream: anAsynStream sink: anAsyncSink [
	^ self new stream: anAsynStream sink: anAsyncSink
]

{ #category : #'api - future' }
AsyncStreamEphemeronForwardFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>
	| aWeakSink |
	
	aWeakSink := sink
		ifSome: #yourself
		ifNone: [ self error: 'Polled Forward after completion' ].

	[
		aWeakSink isAlive
			"Sink was garbage collected"
			ifFalse: [
				bufferedItem := AsyncOptionalValue none.
				sink := AsyncOptionalValue none.
				^ AsyncPoll ready: true ].

		"If we've got an item buffered already, we need to write it to the sink before we can do anything else"
		bufferedItem ifSome: [ :anItem |
			(aWeakSink pollReady: anAsynchronousContext)
				ifPending: [ :aPendingPoll | ^ aPendingPoll ].
			bufferedItem := AsyncOptionalValue none.
			aWeakSink startSend: anItem ].

		(weakEphemeron at: 1)
			ifNotNil: [ :anEphemeron | 
				anEphemeron value
					ifNotNil: [ :aStream |
						(aStream pollNext: anAsynchronousContext)
							ifReady: [ :aReadyPoll |
								aReadyPoll value
									ifSome: [ :anItem | bufferedItem := AsyncOptionalValue some: anItem ]
									ifNone: [
										(aWeakSink pollClose: anAsynchronousContext)
											ifReady: [ :aReadyClosePoll |
												sink := AsyncOptionalValue none.
												anEphemeron mourn.
												bufferedItem := AsyncOptionalValue none.
												^ AsyncPoll ready: true ]
											ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] ]
						ifPending: [ :aPendingPoll |
							aWeakSink pollFlush: anAsynchronousContext.
							^ aPendingPoll ] ]
					ifNil: [ ^ AsyncPoll ready: true ] ]
			ifNil: [ ^ AsyncPoll ready: true ].
	] repeat
]

{ #category : #'api - future copy' }
AsyncStreamEphemeronForwardFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self error: 'Stream forward future does not support #asyncSimilarCopy'
]

{ #category : #initialization }
AsyncStreamEphemeronForwardFuture >> stream: anAsynStream sink: anAsyncSink [
	ephemeronRegistry := AsyncEphemeronRegistry new.
	weakEphemeron := (ephemeronRegistry
		at: anAsyncSink
		put: anAsynStream ephemerous) asWeakReference.
	sink := AsyncOptionalValue some: (AsyncWeakSink forSink: anAsyncSink).

	bufferedItem := AsyncOptionalValue none
]
