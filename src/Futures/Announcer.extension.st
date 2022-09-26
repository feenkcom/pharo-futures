Extension { #name : #Announcer }

{ #category : #'*Futures' }
Announcer >> stream [
	^ self streamOn: Announcement
]

{ #category : #'*Futures' }
Announcer >> streamOn: anAnnouncement [
	^ AsyncAnnouncementStream forAnnouncer: self on: anAnnouncement
]
