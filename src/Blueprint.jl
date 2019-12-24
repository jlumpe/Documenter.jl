"""
Defines [`DocumentBlueprint`](@ref)
"""
module Blueprint

"""
Should contain all the information that is necessary to build a document.
"""
struct DocumentBlueprint
    pages :: Dict{String, Page} # Markdown files only.
    modules :: Set{Module} # Which modules to check for missing docs?
end

end
