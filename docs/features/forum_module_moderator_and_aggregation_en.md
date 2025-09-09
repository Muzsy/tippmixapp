# Forum Module – Moderator Controls & Server Aggregation (EN)

## Moderator Workflow
- AppBar menu exposes pin/unpin and lock/unlock for moderators.
- Actions apply optimistically and show success or error snackbars.

## Locked Threads
- Composer becomes disabled immediately when a thread is locked.
- A banner informs users and posting is prevented.

## Server-side Vote Aggregation
- Cloud Functions update `posts/{postId}.votesCount` on vote create/delete.
- UI displays the server value with a lightweight local delta.
