Extension { #name : #ExecutionEnvironment }

{ #category : #'*Futures' }
ExecutionEnvironment >> asyncFutureThreadPool [
	"Answer the thread pool used for futures scheduled in this environment"

	<return: #AsyncFutureThreadPool>
	^ AsyncFutureThreadPool current
]
