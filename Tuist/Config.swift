import ProjectDescription

let config = Config(
    plugins: [
        .git(url: "https://github.com/lordcodes/swiftformat-tuist", tag: "v0.3.0"),
        .git(url: "https://github.com/lordcodes/swiftlint-tuist", tag: "v0.1.0"),
    ]
)
