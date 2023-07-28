Class {
	#name : #AsyncOverriddenMethodsStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'compiledMethod'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncOverriddenMethodsStream class >> forCompiledMethod: aCompiledMethod [
	^ self new compiledMethod: aCompiledMethod
]

{ #category : #initialization }
AsyncOverriddenMethodsStream >> compiledMethod: aCompiledMethod [
	compiledMethod := aCompiledMethod.
	stream := ((AsyncBehaviorSuperclassesStream forBehavior: compiledMethod methodClass)
		collect: [ :eachBehavior | eachBehavior compiledMethodAt: compiledMethod selector ifAbsent: [ nil ] ])
			select: [ :eachMethod | eachMethod notNil ]
]

{ #category : #'api - stream copy' }
AsyncOverriddenMethodsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self compiledMethod: compiledMethod
]
