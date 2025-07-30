Class {
	#name : #BaselineOfFuturesTelemetry,
	#superclass : #BaselineOf,
	#category : #BaselineOfFuturesTelemetry
}

{ #category : #'as yet unclassified' }
BaselineOfFuturesTelemetry class >> gtDependencyAnalysisPreloadedBaselines [
	^ super gtDependencyAnalysisPreloadedBaselines
		, {BaselineOfBrick.
				BaselineOfGToolkitPhlow.
				BaselineOfGToolkitVisualizer}
]

{ #category : #baseline }
BaselineOfFuturesTelemetry >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'Futures' with: [
				spec repository: 'github://feenkcom/pharo-futures:v0.6.145/src' ].

		spec package: 'Futures-Telemetry' with: [
			spec requires: #(#Futures) ].
	]
]
