Class {
	#name : #AsyncBehaviorClassTraitedMethodsStream,
	#superclass : #AsyncBehaviorClassMethodsStream,
	#category : #'Futures-Extra-Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorClassTraitedMethodsStream >> initializeStream [
	stream := AsyncSequenceStream
			forCollection: [ behavior classSide visibleMethods collect: #selector ] asAsyncFuture
]
