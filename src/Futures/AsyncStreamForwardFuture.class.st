"
#Forward Stream Future
A {{gtClass:TAsyncFuture}} that completes after the given {{gtClass:TAsyncStream}} has been fully processed into the sink and the {{gtClass:TAsyncSink}} has been flushed and closed.
This future will drive the stream to keep producing items until it is exhausted, sending each item to the sink. It will complete once the stream is exhausted, the sink has received and flushed all items, and the sink is closed.

#Example
{{gtExample:AsyncStreamExamples>>#forward}}
"
Class {
	#name : #AsyncStreamForwardFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream',
		'sink',
		'bufferedItem'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncStreamForwardFuture class >> forStream: anAsynStream sink: anAsyncSink [
	^ self new stream: anAsynStream sink: anAsyncSink
]

{ #category : #'api - future' }
AsyncStreamForwardFuture >> poll: anAsynchronousContext [
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

		stream
			ifSome: [ :aStream | 
				(aStream pollNext: anAsynchronousContext)
					ifReady: [ :aReadyPoll |
						aReadyPoll value
							ifSome: [ :anItem | bufferedItem := AsyncOptionalValue some: anItem ]
							ifNone: [
								(aWeakSink pollClose: anAsynchronousContext)
									ifReady: [ :aReadyClosePoll |
										sink := AsyncOptionalValue none.
										stream := AsyncOptionalValue none.
										bufferedItem := AsyncOptionalValue none.
										^ AsyncPoll ready: true ]
									ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] ]
					ifPending: [ :aPendingPoll |
						aWeakSink pollFlush: anAsynchronousContext.
						^ aPendingPoll ] ]
			ifNone: [ ^ AsyncPoll ready: true ].
	] repeat
]

{ #category : #'api - future copy' }
AsyncStreamForwardFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self error: 'Stream forward future does not support #asyncSimilarCopy'
]

{ #category : #initialization }
AsyncStreamForwardFuture >> stream: anAsynStream sink: anAsyncSink [
	stream := AsyncOptionalValue some: anAsynStream.
	sink := AsyncOptionalValue some: (AsyncWeakSink forSink: anAsyncSink).
	bufferedItem := AsyncOptionalValue none
]
