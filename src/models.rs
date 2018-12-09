use super::schema::{posts, posts::dsl::*};
use chrono::NaiveDateTime;
use diesel::prelude::*;

#[derive(Queryable, Serialize, Deserialize, Debug, Clone)]
pub struct Post {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
    pub post_type: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

impl Post {
    pub fn get(connection: &diesel::PgConnection) -> Vec<Post> {
        posts
            .filter(published.eq(true))
            .order(created_at.desc())
            .load::<Post>(connection)
            .expect("Error loading posts")
    }
}

#[derive(Insertable, Serialize, Deserialize, Debug, Clone)]
#[table_name = "posts"]
pub struct NewPost<'a> {
    pub title: &'a str,
    pub body: &'a str,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}
