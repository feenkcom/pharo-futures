"
A future that completes after the given stream has been fully processed into the sink, including flushing.

This future will drive the stream to keep producing items until it is exhausted, sending each item to the sink. It will complete once both the stream is exhausted, the sink has received all items, and the sink has been flushed. Note that the sink is **not** closed. If the stream produces an error, that error will be returned by this future without flushing the sink.

Doing `TAsyncSink>>#sendAll: aStream` is roughly equivalent to `TAsyncStream>>#forward: aSink`. The returned future will exhaust all items from `stream` and send them to `self`.
"
Class {
	#name : #AsyncSinkSendAllFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'sink',
		'stream',
		'buffered'
	],
	#category : #'Futures-Base - Sinks'
}

{ #category : #'instance creation' }
AsyncSinkSendAllFuture class >> forSink: anAsyncSink stream: anAsyncStream [
	^ self new sink: anAsyncSink stream: anAsyncStream
]

{ #category : #'api - future' }
AsyncSinkSendAllFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	"If we've got an item buffered already, we need to write it to the sink before we can do anything else"
	
	buffered ifSome: [ :anObject |
		buffered := AsyncOptionalValue none.
		(self tryStartSend: anObject context: anAsynchronousContext)
			ifPending: [ :aPendingPoll | ^ aPendingPoll ] ].
	
	[ 
		(stream pollNext: anAsynchronousContext)
			ifReady: [ :aReadyPoll |
				aReadyPoll value
					ifSome: [ :anObject |
						(self tryStartSend: anObject context: anAsynchronousContext)
							ifPending: [ :aSendingPendingPoll | ^ aSendingPendingPoll ] ]
					ifNone: [
						(sink pollFlush: anAsynchronousContext)
							ifPending: [ :aFlushPendingPoll | ^ aFlushPendingPoll ].	
						^ AsyncPoll ready: true ]
			]
			ifPending: [ :aPendingPoll |
				sink pollFlush: anAsynchronousContext.
				^ aPendingPoll ]
	] repeat
]

{ #category : #initialization }
AsyncSinkSendAllFuture >> sink: anAsyncSink stream: anAsyncStream [
	sink := anAsyncSink.
	stream := AsyncFuseStream forStream: anAsyncStream.
	buffered := AsyncOptionalValue none
]

{ #category : #private }
AsyncSinkSendAllFuture >> tryStartSend: anObject context: anAsynchronousContext [
	^ (sink pollReady: anAsynchronousContext)
		ifReady: [ :aReadyPoll | 
			sink startSend: anObject.
			AsyncPoll ready: true ]
		ifPending: [ :aPendingPoll |
			buffered := AsyncOptionalValue some: anObject.
			aPendingPoll ]
]
