"
#Peak sink
Stores the last received item by the sink. Is useful to keep track of the current item.

##Example
{{gtExample:AsyncSinkExamples>>#peakSink}}
"
Class {
	#name : #AsyncPeakSink,
	#superclass : #Object,
	#traits : 'TAsyncSink',
	#classTraits : 'TAsyncSink classTrait',
	#instVars : [
		'item'
	],
	#category : #'Futures-Base - Sinks'
}

{ #category : #'api - sink' }
AsyncPeakSink >> cleanSink [
	"Resets the sink to its original state"

	item := AsyncOptionalValue none
]

{ #category : #initialization }
AsyncPeakSink >> initialize [
	super initialize.
	
	item := AsyncOptionalValue none
]

{ #category : #'api - accessing' }
AsyncPeakSink >> peak [
	"Return the last received optional value. It is #none if no last value was received."
	<return: #AsyncOptionalValue>

	^ item
]

{ #category : #'api - sink' }
AsyncPeakSink >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."

	item := AsyncOptionalValue some: anObject
]

{ #category : #'api - accessing' }
AsyncPeakSink >> value [
	"Return the last received object or nil if nothing was received yet"
	<return: #Object or: nil>

	^ item
		ifSome: [ :aValue | aValue ]
		ifNone: [ nil ]
]
