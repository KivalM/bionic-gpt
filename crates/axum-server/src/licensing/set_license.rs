use crate::authentication::Authentication;
use crate::errors::CustomError;
use axum::{
    extract::{Extension, Form},
    response::IntoResponse,
};
use db::authz;
use db::queries::licenses;
use db::Pool;
use serde::Deserialize;
use ui_pages::routes::licenses::index_route;
use validator::Validate;

#[derive(Deserialize, Validate, Default, Debug)]

pub struct SetTier {
    pub team_id: i32,
    pub tier: i8,
}

pub async fn set_license_tier(
    current_user: Authentication,
    Extension(pool): Extension<Pool>,
    Form(tier_form): Form<SetTier>,
) -> Result<impl IntoResponse, CustomError> {
    let mut client = pool.get().await?;
    let transaction = client.transaction().await?;

    let _rbac =
        authz::get_permissions(&transaction, &current_user.into(), tier_form.team_id).await?;

    let valid = true;

    if valid {
        licenses::set_license_tier()
            .bind(&transaction, &tier_form.tier.into(), &tier_form.team_id)
            .await?;
    }

    transaction.commit().await?;

    if valid {
        crate::layout::redirect_and_snackbar(&index_route(tier_form.team_id), "License tier set")
    } else {
        crate::layout::redirect_and_snackbar(
            &index_route(tier_form.team_id),
            "License tier not set",
        )
    }
}
