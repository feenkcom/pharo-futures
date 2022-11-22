"
#Counter Sink
A {{gtClass:TAsyncSink}} that counts how many items were sent into it.

##Example

{{gtExample:AsyncSinkExamples>>#counterSink}}
"
Class {
	#name : #AsyncCounterSink,
	#superclass : #Object,
	#traits : 'TAsyncSink',
	#classTraits : 'TAsyncSink classTrait',
	#instVars : [
		'count'
	],
	#category : #'Futures-Base - Sinks'
}

{ #category : #'api - sink' }
AsyncCounterSink >> cleanSink [
	"Resets the sink to its original state"
	
	count := 0
]

{ #category : #'api - accessing' }
AsyncCounterSink >> count [
	^ count
]

{ #category : #initialization }
AsyncCounterSink >> counter: anInitialvalue [
	count := anInitialvalue
]

{ #category : #initialization }
AsyncCounterSink >> initialize [
	super initialize.
	
	count := 0
]

{ #category : #'api - sink' }
AsyncCounterSink >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	
	count := count + 1
]
