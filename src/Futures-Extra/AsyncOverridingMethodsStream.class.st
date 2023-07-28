Class {
	#name : #AsyncOverridingMethodsStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'compiledMethod'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncOverridingMethodsStream class >> forCompiledMethod: aCompiledMethod [
	^ self new compiledMethod: aCompiledMethod
]

{ #category : #initialization }
AsyncOverridingMethodsStream >> compiledMethod: aCompiledMethod [
	compiledMethod := aCompiledMethod.
	stream := ((AsyncBehaviorAllSubclassesStream forBehavior: compiledMethod methodClass)
		collect: [ :eachBehavior | eachBehavior compiledMethodAt: compiledMethod selector ifAbsent: [ nil ] ])
			select: [ :eachMethod | eachMethod notNil ]
]

{ #category : #'api - stream copy' }
AsyncOverridingMethodsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self compiledMethod: compiledMethod
]
