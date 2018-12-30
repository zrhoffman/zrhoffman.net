table! {
    posts (id) {
        id -> Int4,
        title -> Varchar,
        body -> Text,
        published -> Bool,
        post_type -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}
