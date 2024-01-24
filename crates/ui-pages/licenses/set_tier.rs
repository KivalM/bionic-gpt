#![allow(non_snake_case)]
use daisy_rsx::*;
use dioxus::prelude::*;

#[inline_props]
pub fn SetTierDrawer<'a>(
    cx: Scope<DrawerProps>,
    team_id: i32,
    tier_name: &'a str,
    tier_value: i32,
    trigger_id: String,
) -> Element {
    cx.render(rsx! {
        Drawer {
            submit_action: crate::routes::licenses::set_license_route(*team_id, *tier_value),
            label: "Choose {tier_name} tier?",
            trigger_id: &trigger_id,
            DrawerBody {
                div {
                    class: "flex flex-col",
                    Alert {
                        alert_color: AlertColor::Warn,
                        class: "mb-3",
                        p {
                            "Are you sure you want to select this tier?"
                        }
                    }
                    input {
                        "type": "hidden",
                        "name": "team_id",
                        "value": "{*team_id}"
                    }
                    input {
                        "type": "hidden",
                        "name": "tier",
                        "value": "{*tier_value}"
                    }
                }
            }
            DrawerFooter {
                Button {
                    button_type: ButtonType::Submit,
                    button_scheme: ButtonScheme::Primary,
                    "Select"
                }
            }
        }
    })
}
