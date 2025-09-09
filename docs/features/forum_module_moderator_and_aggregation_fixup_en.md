# Forum Module – Moderator & Aggregation Fixup

This document describes incremental updates to the forum module:

- Moderator status derives from Firebase Auth custom claims (`roles.moderator`).
- Quoted posts render as tappable cards that navigate to the referenced post.
- Posts display an "edited" label when they were modified.
- Composer is disabled on locked threads with a banner notification.

These changes finalize the moderator workflow and improve forum UX.
