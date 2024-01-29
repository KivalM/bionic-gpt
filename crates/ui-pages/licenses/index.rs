#![allow(non_snake_case)]
use crate::app_layout::{Layout, SideBar};
use assets::files::*;
use daisy_rsx::*;
use db::{authz::Rbac, queries::licenses::License};
use dioxus::prelude::*;

#[inline_props]
pub fn Page(cx: Scope, rbac: Rbac, team_id: i32, license: License) -> Element {
    let tiers = [
        (0, "Free", "This is a Free description"),
        (1, "Basic", "This is a Basic description"),
        (2, "Enterprise", "This is a Enterprise description"),
    ];

    cx.render(rsx! {
        Layout {
            section_class: "normal",
            selected_item: SideBar::License,
            team_id: *team_id,
            rbac: rbac,
            title: "License",
            header: cx.render(rsx!(
                h3 { "License" }
            )),
            // cards with select buttons to select a license tier
            cx.render(rsx!(
                div{
                    id: "licenses",
                    class: "grid grid-cols-3 gap-4 min-w-1/2",
                    tiers.iter().map(|tier| rsx!(
                        div{
                            cx.render(rsx!(
                                super::set_tier::SetTierDrawer {
                                    team_id: *team_id,
                                    tier_value: tier.0,
                                    tier_name: tier.1,
                                    trigger_id: format!("set-tier-trigger-{}-{}", team_id, tier.0),
                                }
                            )),
                            div {
                                class: "mt-4 flex flex-col justify-center items-center",
                                img {
                                    class: "mb-4",
                                    src: empty_api_keys_svg.name,
                                    width: "10%"
                                }
                                h2 {
                                    class: "text-center mb-4  max-w-prose",
                                    "{tier.1}"
                                }
                                p {
                                    class: "mb-4  max-w-prose text-center",
                                    "{tier.2}"
                                }
                                div {
                                    if license.tier == tier.0 {
                                        cx.render(rsx!(
                                            Button {
                                                button_scheme: ButtonScheme::Primary,
                                                "Selected",
                                            }
                                        ))
                                    } else {
                                        cx.render(rsx!(
                                            Button {
                                                button_scheme: ButtonScheme::Primary,
                                                drawer_trigger: "set-tier-trigger-{team_id}-{tier.0}",
                                                "Select",
                                            }
                                        ))
                                    }

                                }
                            }
                        }
                    )),
                }
            ))
        }
    })
}

pub fn index(props: PageProps) -> String {
    crate::render(VirtualDom::new_with_props(Page, props))
}
