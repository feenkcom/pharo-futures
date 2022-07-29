Class {
	#name : #AsyncBehaviorClassTraitedMethodsStream,
	#superclass : #AsyncBehaviorClassMethodsStream,
	#category : #'Futures-Extra-Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorClassTraitedMethodsStream >> behavior: aBehavior [
	super behavior: aBehavior.
	stream := AsyncSequenceStream
			forCollection: [ behavior classSide visibleMethods collect: #selector ] asAsyncFuture
]
