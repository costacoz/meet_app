# Meet app
This is a "Get to know Firebase for Flutter" codelab. [Link.](https://firebase.google.com/codelabs/firebase-get-to-know-flutter#0)

# Goals
Get to know how to make Authentication and data sync using Firebase Cloud Firestore.

# Security rules
On firebase side:

    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /guestbook/{entry} {
          allow read: if request.auth.uid != null;
          allow write:
            if request.auth.uid == request.resource.data.userId
            && "name" in request.resource.data
            && "text" in request.resource.data
            && "timestamp" in request.resource.data
            ;
        }
        match /attendees/{userId} {
            allow read;
          allow write: if request.auth.uid == userId
                && "attending" in request.resource.data;
        }
      }
    }
