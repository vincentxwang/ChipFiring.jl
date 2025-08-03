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
        "Reference" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/vincentwang/ChipFiring.jl",
    devbranch = "main"
)