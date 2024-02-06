use crate::authentication::Authentication;
use crate::errors::CustomError;
use axum::{
    extract::{Extension, Path},
    response::Html,
};
use db::authz;
use db::queries;
use db::Pool;

pub async fn switch(
    Path(team_id): Path<i32>,
    Extension(pool): Extension<Pool>,
    current_user: Authentication,
) -> Result<Html<String>, CustomError> {
    // Create a transaction and setup RLS
    let mut client = pool.get().await?;
    let transaction = client.transaction().await?;
    let email = current_user.email.clone();
    let rbac = authz::get_permissions(&transaction, &current_user.into(), team_id).await?;

    let team = queries::teams::team()
        .bind(&transaction, &team_id)
        .one()
        .await?;

    let teams = queries::teams::get_teams()
        .bind(&transaction, &rbac.user_id)
        .all()
        .await?;

    let invites_meta =
        queries::invitations::get_invitations_by_email_with_invite_name_and_team_name()
            .bind(&transaction, &email)
            .all()
            .await?;

    Ok(Html(ui_pages::teams::teams(
        teams,
        invites_meta,
        team.id,
        rbac,
    )))
}
