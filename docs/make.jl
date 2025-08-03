using Documenter, ChipFiring

makedocs(;
    modules=[ChipFiring],
    authors="Vincent X. Wang <vw12@rice.edu>",
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
    repo = "github.com/vincentxwang/ChipFiring.jl.git",
)