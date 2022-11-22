Extension { #name : #TAsyncFuture }

{ #category : #'*Futures-Extra' }
TAsyncFuture >> debugWait [
	"Debug only! Polls the future until its completion without using worker threads.
	It might be useful for profiling streams and futures with Tally."
	| aWaitTime aContext |
	
	aWaitTime := 1 milliSecond.
	
	aContext := AsyncFutureExecutionContext new
		waker: AsyncFutureDummyWaker new.
	
	[
		(self poll: aContext)
			ifReady: [ :aReadyPoll | ^ aReadyPoll value ]
			ifPending: [
				aWaitTime wait.
				aWaitTime := aWaitTime * 2 ].
			
		aWaitTime > 1 minute
			ifTrue: [ self error: 'Time out!' ].
	] repeat
]
