Class {
	#name : #AsyncWeakStreamExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Streams'
}

{ #category : #examples }
AsyncWeakStreamExamples >> weakStream [
	<gtExample>
	<return: #AsyncWeakStream>
	| stream hasNext semaphore weakStream promise |
	stream := AsyncPendingStream new.

	semaphore := Semaphore new.
	hasNext := nil.
	promise := (weakStream := AsyncWeakStream forStream: stream) hasNext await.
	promise
		then: [ :aResult | 
			hasNext := aResult.
			semaphore signal ]
		otherwise: [ :anError | 
			hasNext := anError.
			semaphore signal ].

	stream := nil.
	Smalltalk garbageCollect.
	Smalltalk garbageCollect.

	self assert: (semaphore waitTimeoutSeconds: 30) not.
	self assert: hasNext equals: false.

	^ weakStream
]
