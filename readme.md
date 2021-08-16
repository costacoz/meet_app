# Meet app
This is an elaborated version of "Get to know Firebase for Flutter" codelab project's result.
[Link to original codelab.](https://firebase.google.com/codelabs/firebase-get-to-know-flutter#0)
Additionally implemented:
- Delete own message
- Password reset
- Push notifications (Cloud Messaging)

# How to Use
Generate your own google-services.json file and put into /android/app folder.

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
            && "timestamp" in request.resource.data;
          allow delete:
            if request.auth.uid
            == get(/databases/$(database)/documents/guestbook/$(entry)).data.userId;

        }
        match /attendees/{userId} {
            allow read;
          allow write: if request.auth.uid == userId
                && "attending" in request.resource.data;
        }
      }
    }
