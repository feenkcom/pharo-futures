Extension { #name : #TestExecutionEnvironment }

{ #category : #'*Futures-SUnit' }
TestExecutionEnvironment >> asyncFutureThreadPool [
	"Answer the thread pool of the running test or example (see AsyncFutureThreadPoolTestService).
	Fall back to the global pool if the service is not registered or disabled"

	<return: #AsyncFutureThreadPool>
	| aService |
	aService := self
			findService: AsyncFutureThreadPoolTestService
			ifAbsent: [ ^ super asyncFutureThreadPool ].

	^ aService isEnabled
		ifTrue: [ aService threadPool ]
		ifFalse: [ super asyncFutureThreadPool ]
]
