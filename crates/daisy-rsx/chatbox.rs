#![allow(non_snake_case)]
#![allow(unused_braces)]

use dioxus::prelude::*;

#[derive(Props)]
pub struct ChatboxProps<'a> {
    image_src: &'a str,
    name: &'a str,
    text: &'a str,
}

pub fn Chatbox<'a>(cx: Scope<'a, ChatboxProps<'a>>) -> Element {
    // let clipboard = use_clipboard(cx.scope);

    // let oncopy = {
    //     to_owned![clipboard];
    //     move |_| match clipboard.set(cx.props.text.to_owned()) {
    //         Ok(_) => println!("Copied to clipboard: {}", cx.props.text),
    //         Err(err) => println!("Error on copy: {err:?}"),
    //     }
    // };

    // tailwindcss
    cx.render(rsx!(
        div {
            class: "px-4 py-2 justify-center text-base md:gap-6 m-auto w-full max-w-2xl text-gray-700",
            div {
                class: "flex flex-row items-center justify-start",
                    img {
                        class: "rounded-full w-6 h-6",
                        src: "{cx.props.image_src}"
                    }
                div {
                    class: "flex flex-col items-start justify-center ml-2",
                    div {
                        class: "text-md font-bold",
                        "{cx.props.name}"
                    },
                    div {
                        class: "flex flex-row items-center justify-start text-sm",
                        div {
                            class: "flex flex-col items-start justify-center ml-1",
                            div {
                                class: "text-sm",
                                "{cx.props.text}",
                            }
                        },
                    },
                    div {
                        button {
                            // onclick: oncopy,
                            class: "btn-circle mr-2 p-1",
                            svg{
                                fill: "none",
                                stroke: "currentColor",
                                class: "w-4 h-4",
                                view_box: "0 0 24 24",
                                path {
                                    d: "M15.666 3.888A2.25 2.25 0 0 0 13.5 2.25h-3c-1.03 0-1.9.693-2.166 1.638m7.332 0c.055.194.084.4.084.612v0a.75.75 0 0 1-.75.75H9a.75.75 0 0 1-.75-.75v0c0-.212.03-.418.084-.612m7.332 0c.646.049 1.288.11 1.927.184 1.1.128 1.907 1.077 1.907 2.185V19.5a2.25 2.25 0 0 1-2.25 2.25H6.75A2.25 2.25 0 0 1 4.5 19.5V6.257c0-1.108.806-2.057 1.907-2.185a48.208 48.208 0 0 1 1.927-.184"
                                }
                            }
                        }
                    },
                }
            },
            // copy response button
            div {
                class: "flex flex-row items-center justify-start ml-2",
            }
        }
    ))
}