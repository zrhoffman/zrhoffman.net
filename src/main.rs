#![feature(proc_macro_hygiene, decl_macro, never_type)]

#[macro_use]
extern crate rocket;
#[macro_use]
extern crate rocket_contrib;
#[macro_use]
extern crate serde_derive;
#[macro_use]
extern crate diesel;
extern crate openssl;
extern crate serde_json;

pub mod models;
pub mod schema;
pub mod structs;

use self::{models::*, structs::*};
use std::collections::HashMap;
use {
    rocket::{handler::Outcome, response::Redirect, Data, Request},
    rocket_contrib::templates::Template,
};

fn handler<'r>(request: &'r Request, _data: Data) -> Outcome<'r> {
    Outcome::from(request, "Hello, world!")
}

#[get("/")]
fn index() -> Redirect {
    Redirect::to(uri!(blog))
}

#[get("/blog")]
fn blog(connection: PostsDbConnection, menu: Menu) -> Template {
    let mut display_posts: Vec<DisplayPost> = vec![];
    for post in Post::get(&connection) {
        display_posts.push(DisplayPost::create_from_post(&post));
    }

    let context = TemplateContext {
        uri: menu.uri.borrow_mut().to_owned(),
        menu: menu.items,
        posts: display_posts,
    };

    Template::render("blog", &context)
}

#[catch(404)]
fn not_found(req: &Request) -> Template {
    let mut map = HashMap::new();
    map.insert("path", req.uri().path());
    Template::render("error/404", &map)
}

#[database("site")]
#[derive(Serialize, Deserialize, Debug)]
struct PostsDbConnection(rocket_contrib::databases::diesel::PgConnection);

fn rocket() -> rocket::Rocket {
    rocket::ignite()
        .mount("/", routes![index, blog])
        .attach(Template::fairing())
        .attach(PostsDbConnection::fairing())
        .register(catchers![not_found])
}

fn main() {
    rocket().launch();
}
