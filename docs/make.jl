using Documenter, ChipFiring

makedocs(;
    modules=[ChipFiring],
    sitename="ChipFiring.jl",
    format=Documenter.HTML(;
        canonical="https://vincentxwang.github.io/ChipFiring.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Background and conventions" => "bg.md",
        "Examples" => "examples.md",
        "Performance tips" => "performance.md", 
        "Reference" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/vincentxwang/ChipFiring.jl",
    devbranch = "main",
    push_preview = true
)