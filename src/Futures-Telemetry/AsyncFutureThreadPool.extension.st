Extension { #name : #AsyncFutureThreadPool }

{ #category : #'*Futures-Telemetry' }
AsyncFutureThreadPool >> gtEnableTelemetryActionFor: anAction [
	<gtAction>
	| aTelemetry |
	
	aTelemetry := self telemetryDo: #yourself.
 
	^ anAction button
		tooltip: 'Enable telemetry';
		priority: 30;
		icon: BrGlamorousVectorIcons signal;
		action: [ self telemetryDo: #yourself ifNone: [ self telemetry: (aTelemetry := AsyncFutureThreadPoolTelemetry new) ] ]
]
