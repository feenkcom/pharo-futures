"
Examples for {{gtClass:AsyncImageBehaviorsStream}}. They cover the stream when a class name from its snapshot of `classNames` no longer exists in the environment by the time the stream reaches it.
"
Class {
	#name : #AsyncImageBehaviorsStreamExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Extra'
}

{ #category : #examples }
AsyncImageBehaviorsStreamExamples >> existingClasses [
	<gtExample>
	<return: #Array>
	| aStream aResult |
	aStream := self streamOverClassNames: #(#Object #String).

	aResult := self resultOf: aStream withinSeconds: 5.

	self
		assert: aResult
		equals: {Object.
				String}.
	^ aResult
]

{ #category : #examples }
AsyncImageBehaviorsStreamExamples >> missingClassIsSkipped [
	"Reproduces the stall: a name from the snapshot that is no longer in the environment makes `pollNext:` answer a pending poll without registering a waker, so nobody polls the stream again and it never finishes. Jenkins builds of gtoolkit 13325 and 13328 hung forever in `GtSearchClassFilterExamples>>#groupResultForClassesInImageFilter` that way."

	<gtExample>
	<return: #Array>
	| aStream aResult |
	aStream := self
			streamOverClassNames: #(#Object #AsyncImageBehaviorsStreamRemovedClass #String).

	aResult := self resultOf: aStream withinSeconds: 5.

	self
		assert: aResult isNotNil
		description: 'The stream did not finish within 5 seconds'.
	self
		assert: aResult
		equals: {Object.
				String}.
	^ aResult
]

{ #category : #private }
AsyncImageBehaviorsStreamExamples >> resultOf: aStream withinSeconds: aNumberOfSeconds [
	"Collect the behaviors of the stream into an Array, waiting at most the given number of seconds. Answer nil if the stream did not finish in time, so that a stalled stream fails an example instead of blocking it forever like `wait` does."

	<return: #Array>
	| aSemaphore aResult |
	aSemaphore := Semaphore new.
	aStream toArray await
		then: [ :anArray | 
			aResult := anArray.
			aSemaphore signal ]
		otherwise: [ :anError | 
			aResult := anError.
			aSemaphore signal ].
	(aSemaphore waitTimeoutSeconds: aNumberOfSeconds) ifTrue: [ ^ nil ].
	^ aResult
]

{ #category : #private }
AsyncImageBehaviorsStreamExamples >> streamOverClassNames: aCollectionOfNames [
	"Answer an AsyncImageBehaviorsStream that walks the given fixed list of class names, as if it was the snapshot of `classNames` taken from the environment. This lets an example make a name disappear deterministically."

	<return: #AsyncImageBehaviorsStream>
	| aStream |
	aStream := AsyncImageBehaviorsStream new.
	aStream
		instVarNamed: 'stream'
		put: (AsyncSequenceStream forCollection: [ aCollectionOfNames ] asAsyncFuture).
	^ aStream
]
