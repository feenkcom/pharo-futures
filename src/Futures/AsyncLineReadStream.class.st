"
#Line break stream

Given a stream of characters emits lines by splitting a stream by CR, LF or CRLF.s
It is possible to control whether a line break as a last character emits an empty line using {{gtMethod:AsyncLineReadStream>>#emitEmptyLastLine}}.
##Example
{{gtExample: AsyncLineReadStreamExamples>>#streamWithCrInTheMiddle}}
"
Class {
	#name : #AsyncLineReadStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'currentLine',
		'lf',
		'cr',
		'previousChar',
		'shouldEmitEmptyLastLine'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncLineReadStream class >> stream: aStream [
	^ self new stream: aStream
]

{ #category : #accessing }
AsyncLineReadStream >> emitEmptyLastLine [
	shouldEmitEmptyLastLine := true
]

{ #category : #initialization }
AsyncLineReadStream >> initialize [
	super initialize.
	
	cr := Character cr.
	lf := Character lf.
	currentLine := nil.
	shouldEmitEmptyLastLine := false
]

{ #category : #'api - stream' }
AsyncLineReadStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."

	<return: #AsyncPoll>
	[ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll | 
			aReadyPoll value
				ifSome: [ :aNextChar | 
					currentLine ifNil: [ currentLine := WriteStream on: (String new: 10) ].

					aNextChar = cr
						ifTrue: [ previousChar := aNextChar.
							^ self privatePollCurrentLine ]
						ifFalse: [ aNextChar = lf
								ifTrue: [ previousChar == cr
										ifTrue: [ previousChar := aNextChar ]
										ifFalse: [ previousChar := aNextChar.
											^ self privatePollCurrentLine ] ]
								ifFalse: [ currentLine nextPut: aNextChar.
									previousChar := aNextChar ] ] ]
				ifNone: [ previousChar := nil.
					^ currentLine
						ifNil: [ AsyncPoll ready: AsyncOptionalValue none ]
						ifNotNil: [
							| aLine |
							aLine := currentLine contents.
							currentLine := nil.
							(shouldEmitEmptyLastLine or: [ aLine isNotEmpty ])
								ifTrue: [ AsyncPoll ready: (AsyncOptionalValue some: aLine)  ]
								ifFalse: [ AsyncPoll ready: AsyncOptionalValue none ] ] ] ]
		ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] repeat
]

{ #category : #'api - stream copy' }
AsyncLineReadStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	currentLine := nil.
	stream := stream asyncSimilarCopy
]

{ #category : #private }
AsyncLineReadStream >> privatePollCurrentLine [
	"Return the contents of a current line as a ready poll and prepare for the next line"
	| aLine |
	aLine := currentLine contents.
	currentLine reset.
	^ AsyncPoll ready: (AsyncOptionalValue some: aLine)
]

{ #category : #initialization }
AsyncLineReadStream >> stream: aStream [
	stream := aStream
]
