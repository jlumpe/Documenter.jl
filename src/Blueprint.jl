"""
Defines [`DocumentBlueprint`](@ref)
"""
module Blueprint


"""
A node in a [`DocumentBlueprint`](@ref)'s tree of source files and navbar sections.
"""
struct SourceNode
    file::Union{String, Nothing}   # Source file (nothing if a navbar section)
    title::Union{String, Nothing}  # Override title in navbar
    children::Vector{SourceNode}   # Child nodes
    visible::Bool                  # Whether the node should be visible in the navbar
end

SourceNode(; file=nothing, title=nothing, children=SourceNode[], visible=true) = SourceNode(file, title, children, visible)

# Modify existing node
SourceNode(node::SourceNode; file=node.file, title=node.title, children=node.children, visible=node.visible) = SourceNode(file, title, children, visible)


"""
Recursively build a tree of `SourceNode` objects from the `pages` argument to
[`DocumentBlueprint`](@ref).
"""
make_srctree(node::SourceNode; title=nothing) = title === nothing ? node : SourceNode(node, title=title)
make_srctree(file::AbstractString; title=nothing, visible=true) = SourceNode(file=file, title=title, visible=visible)
make_srctree(p::Pair; visible=true) = make_srctree(p.second, title=p.first, visible=visible)
make_srctree(v::Vector; title=nothing, visible=true) = SourceNode(title=title, children=make_srctree.(v), visible=visible)

# Old tuple representation
function make_srctree(tup::Tuple)
    (visible, title, src, children) = tup
    SourceNode(file=src, title=title, children=make_srctree.(children), visible=visible)
end


"""
$(SIGNATURES)

Allows a page to be hidden in the navigation menu. It will only show up if it happens to be
the current page. The hidden page will still be present in the linear page list that can be
accessed via the previous and next page links. The title of the hidden page can be overriden
using the `=>` operator as usual.

# Usage

```julia
makedocs(
    ...,
    pages = [
        ...,
        hide("page1.md"),
        hide("Title" => "page2.md")
    ]
)
```
"""
hide(page::Pair) = SourceNode(file=pair.second, title=pair.first, visible=false)
hide(page::AbstractString) = SourceNode(file=page, visible=false)

"""
$(SIGNATURES)

Allows a subsection of pages to be hidden from the navigation menu. `root` will be linked
to in the navigation menu, with the title determined as usual. `children` should be a list
of pages (note that it **can not** be hierarchical).

# Usage

```julia
makedocs(
    ...,
    pages = [
        ...,
        hide("Hidden section" => "hidden_index.md", [
            "hidden1.md",
            "Hidden 2" => "hidden2.md"
        ]),
        hide("hidden_index.md", [...])
    ]
)
```
"""
hide(root::Pair, children) = SourceNode(root.second, root.first, make_srctree.(children), false)
hide(root::AbstractString, children) = SourceNode(root, nothing, make_srctree.(children), false)


"""
Should contain all the information that is necessary to build a document.
"""
struct DocumentBlueprint
    pages :: Dict{String, Page} # Markdown files only.
    modules :: Set{Module} # Which modules to check for missing docs?
end

end
