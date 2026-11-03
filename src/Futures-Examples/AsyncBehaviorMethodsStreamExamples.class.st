"
Examples for the method streams of a behavior: {{gtClass:AsyncBehaviorClassMethodsStream}}, {{gtClass:AsyncBehaviorClassSortedMethodsStream}}, {{gtClass:AsyncBehaviorInstanceLocalMethodsStream}}, {{gtClass:AsyncBehaviorInstanceLocalSortedMethodsStream}} and {{gtClass:AsyncBehaviorInstanceTraitedSortedMethodsStream}}. They cover a selector from the stream's list of selectors that no longer has a method in the behavior by the time the stream reaches it. Same problem as in {{gtClass:AsyncImageBehaviorsStreamExamples}}, see https://github.com/feenkcom/gtoolkit/issues/5249.
"
Class {
	#name : #AsyncBehaviorMethodsStreamExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Extra'
}

{ #category : #private }
AsyncBehaviorMethodsStreamExamples >> assertMissingSelectorIsSkippedBy: aStreamClass classSide: aBoolean [
	"Walk `Object` (or its class side) with a list of selectors where the middle one has no method. The stream has to finish within 5 seconds and answer only the methods that exist."

	<return: #Array>
	| aBehavior someExistingSelectors aStream aResult |
	aBehavior := aBoolean ifTrue: [ Object classSide ] ifFalse: [ Object ].
	someExistingSelectors := aBehavior localSelectors asArray sorted first: 2.
	aStream := self
			streamOf: aStreamClass
			over: Object
			selectors: {someExistingSelectors first.
					#asyncBehaviorMethodsStreamRemovedSelector.
					someExistingSelectors second}.

	aResult := self resultOf: aStream withinSeconds: 5.

	self
		assert: aResult isNotNil
		description: 'The stream did not finish within 5 seconds'.
	self
		assert: aResult
		equals: (someExistingSelectors
				collect: [ :aSelector | aBehavior compiledMethodAt: aSelector ]).
	^ aResult
]

{ #category : #examples }
AsyncBehaviorMethodsStreamExamples >> classMethodsSkipMissingSelector [
	"Reproduces the stall in `AsyncBehaviorClassMethodsStream>>#pollNext:`, see {{gtMethod:AsyncBehaviorMethodsStreamExamples>>#instanceLocalMethodsSkipMissingSelector}}. The selectors belong to the class side."

	<gtExample>
	<return: #Array>
	^ self
		assertMissingSelectorIsSkippedBy: AsyncBehaviorClassMethodsStream
		classSide: true
]

{ #category : #examples }
AsyncBehaviorMethodsStreamExamples >> classSortedMethodsSkipMissingSelector [
	"Reproduces the stall in `AsyncBehaviorClassSortedMethodsStream>>#pollNext:`, see {{gtMethod:AsyncBehaviorMethodsStreamExamples>>#instanceLocalMethodsSkipMissingSelector}}. The selectors belong to the class side."

	<gtExample>
	<return: #Array>
	^ self
		assertMissingSelectorIsSkippedBy: AsyncBehaviorClassSortedMethodsStream
		classSide: true
]

{ #category : #examples }
AsyncBehaviorMethodsStreamExamples >> instanceLocalMethodsSkipMissingSelector [
	"Reproduces the stall in `AsyncBehaviorInstanceLocalMethodsStream>>#pollNext:`: a selector without a method makes it answer a pending poll without registering a waker, so nobody polls the stream again and it never finishes."

	<gtExample>
	<return: #Array>
	^ self
		assertMissingSelectorIsSkippedBy: AsyncBehaviorInstanceLocalMethodsStream
		classSide: false
]

{ #category : #examples }
AsyncBehaviorMethodsStreamExamples >> instanceLocalSortedMethodsSkipMissingSelector [
	"Reproduces the stall in `AsyncBehaviorInstanceLocalSortedMethodsStream>>#pollNext:`, see {{gtMethod:AsyncBehaviorMethodsStreamExamples>>#instanceLocalMethodsSkipMissingSelector}}."

	<gtExample>
	<return: #Array>
	^ self
		assertMissingSelectorIsSkippedBy: AsyncBehaviorInstanceLocalSortedMethodsStream
		classSide: false
]

{ #category : #examples }
AsyncBehaviorMethodsStreamExamples >> instanceTraitedSortedMethodsSkipMissingSelector [
	"Reproduces the stall in `AsyncBehaviorInstanceTraitedSortedMethodsStream>>#pollNext:`, see {{gtMethod:AsyncBehaviorMethodsStreamExamples>>#instanceLocalMethodsSkipMissingSelector}}."

	<gtExample>
	<return: #Array>
	^ self
		assertMissingSelectorIsSkippedBy: AsyncBehaviorInstanceTraitedSortedMethodsStream
		classSide: false
]

{ #category : #private }
AsyncBehaviorMethodsStreamExamples >> resultOf: aStream withinSeconds: aNumberOfSeconds [
	"Collect the methods of the stream into an Array, waiting at most the given number of seconds. Answer nil if the stream did not finish in time, so that a stalled stream fails an example instead of blocking it forever like `wait` does."

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
AsyncBehaviorMethodsStreamExamples >> streamOf: aStreamClass over: aBehavior selectors: aCollectionOfSelectors [
	"Answer a stream of the given class that walks the given fixed list of selectors, as if it was the list of selectors taken from the behavior when the stream started. This lets an example make a selector without a method deterministically."

	<return: #AsyncBehaviorStream>
	| aStream |
	aStream := aStreamClass forBehavior: aBehavior.
	aStream
		instVarNamed: 'stream'
		put: (AsyncSequenceStream forCollection: [ aCollectionOfSelectors ] asAsyncFuture).
	^ aStream
]
