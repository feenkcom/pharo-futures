Class {
	#name : #AsyncBehaviorClassTraitedSortedMethodsStream,
	#superclass : #AsyncBehaviorClassSortedMethodsStream,
	#category : #'Futures-Extra-Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorClassTraitedSortedMethodsStream >> initializeStream [
	stream := AsyncSequenceStream
			forCollection: [ (behavior classSide visibleMethods collect: #selector)
					sorted: GtMethodsSortFunction new ] asAsyncFuture
]
