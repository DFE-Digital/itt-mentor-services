# Data model

> [!NOTE]
> This is a _draft_ document. It will change as we develop our understanding of the services that this application encapsulates.

This application will power two user-facing services: 'Manage school placements' and 'Claim funding for mentors' (a.k.a. Track & Pay). Some data entities will be used by both services – for example, Mentors, Providers and Schools. Others will only be relevant to one service – for example, Funding Claims and School Placements.

## Entity Relationship Diagram (ERD)

This diagram represents our current understanding of the data models that will exist within this application.

There are a few things to bear in mind when reading this:

- This diagram attempts to bridge the gap between a 'high level' list of entities, and a 'low level' database schema. It sits somewhere in between.
- It is incomplete. As we continue developing our services, this diagram will undoubtedly change and grow.

```mermaid
erDiagram
  Placement {
    uuid id PK
    uuid mentor_id FK
    uuid trainee_id FK
    uuid school_id FK
    date start_date
    date end_date
  }

  School {
    uuid id PK
    string urn FK "Primary key for schools in GIAS"
  }

  Mentor {
    uuid id PK
    string trn FK "Primary key for people in DQT"
  }

  Provider {
    uuid id PK
    string accredited_provider_id FK "Primary key for providers in the Teacher Training Courses API"
  }

  MentorTraining {
    uuid id PK
    uuid provider_id FK
    uuid mentor_id FK
    enum training_type "Refresher or Initial"
    int hours_completed
    date date_completed
  }

  Claim {
    uuid id PK
    uuid school_id FK
  }

  Trainee {
    uuid id PK
    uuid provider_id FK
    string trn FK "Primary key for people in DQT"
  }

  School ||--|{ Mentor : "has many"
  Provider ||--|{ School : "has many"
  Trainee }|--|| Provider : "belongs to"

  Placement }|--|| Mentor : "has many"
  Placement }|--|| Trainee : "has many"
  Placement }|--|| School : "has many"

  Mentor }|--|{ MentorTraining : "has many"
  Provider }|--|{ MentorTraining : "has many"

  School ||--|{ Claim : "has many"
  Claim }|--|{ MentorTraining : "has and belongs to many"
```
