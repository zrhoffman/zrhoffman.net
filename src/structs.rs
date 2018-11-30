use super::models::*;
use rocket::{outcome::Outcome::Success, request::FromRequest, Request};
use std::cell::RefCell;
use {
    chrono::{NaiveDateTime, TimeZone},
    chrono_tz::US::Central,
};

#[derive(Serialize)]
pub struct DisplayPost {
    pub content: Post,
    pub created_at_formatted: String,
    pub updated_at_formatted: String,
}

impl DisplayPost {
    pub fn create_from_post(post: &Post) -> DisplayPost {
        DisplayPost {
            content: post.clone(),
            created_at_formatted: DisplayPost::format_date(&post.created_at),
            updated_at_formatted: DisplayPost::format_date(&post.updated_at),
        }
    }

    fn format_date(date: &NaiveDateTime) -> String {
        Central
            .from_utc_datetime(date)
            .format("%A, %B %e, %Y %l:%M%p %Z")
            .to_string()
    }
}

#[derive(Serialize)]
pub struct TemplateContext<'a> {
    pub uri: String,
    pub menu: Vec<MenuItem<'a>>,
    pub posts: Vec<DisplayPost>,
}

pub struct Menu<'a> {
    pub uri: RefCell<String>,
    pub items: Vec<MenuItem<'a>>,
}

unsafe impl<'a> Sync for Menu<'a> {}

impl<'a, 'b, 'c> FromRequest<'a, 'b> for Menu<'c> {
    type Error = !;

    fn from_request(request: &'a Request<'b>) -> rocket::request::Outcome<Self, Self::Error> {
        Success(Menu {
            uri: RefCell::new(request.uri().to_normalized().path().to_string()),
            items: vec![
                MenuItem {
                    title: "Posts",
                    uri: "/blog",
                },
                MenuItem {
                    title: "Projects",
                    uri: "/projects",
                },
                MenuItem {
                    title: "Me",
                    uri: "/me",
                },
            ],
        })
    }
}

#[derive(Serialize)]
pub struct MenuItem<'a> {
    pub title: &'a str,
    pub uri: &'a str,
}
