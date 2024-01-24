pub mod index;
pub mod set_license;
use ui_pages::routes::licenses::{INDEX, SET_LICENSE};

use axum::{
    routing::{get, post},
    Router,
};

// use ui_pages::routes::api_keys::{DELETE, INDEX, NEW};

pub fn routes() -> Router {
    Router::new()
        .route(INDEX, get(index::index))
        .route(SET_LICENSE, post(set_license::set_license_tier))
}
