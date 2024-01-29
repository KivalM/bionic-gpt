use crate::authentication::Authentication;
use crate::errors::CustomError;
use axum::extract::{Extension, Path};
use axum::response::Html;
use db::authz;

use db::{queries, Pool};
use ui_pages::licenses;

pub async fn index(
    Path(team_id): Path<i32>,
    current_user: Authentication,
    Extension(pool): Extension<Pool>,
) -> Result<Html<String>, CustomError> {
    let mut client = pool.get().await?;
    let transaction = client.transaction().await?;

    let rbac = authz::get_permissions(&transaction, &current_user.into(), team_id).await?;

    if !rbac.can_use_api_keys() {
        return Err(CustomError::Authorization);
    }

    let licenses = queries::licenses::license()
        .bind(&transaction, &team_id)
        .all()
        .await?;

    Ok(Html(licenses::index(licenses::index::PageProps {
        rbac,
        license: *licenses.get(0).unwrap(),
        team_id,
    })))
}
