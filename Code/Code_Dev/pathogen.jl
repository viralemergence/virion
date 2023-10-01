using DataFrames
using NCBITaxonomy
import CSV
using ProgressMeter

function taxonomizer(df::DataFrame, type::Symbol=:hosts; names::Symbol=:Name)

    # Check that the name type is either hosts or pathogens
    @assert type ∈ [:hosts, :pathogens]

    # And build the appropriate nametype
    namelist = isequal(:hosts)(type) ? vertebratefilter() : namefilter([:BCT, :INV, :VRL, :PLN])

    # Get the names from the correct column (usually `Name` but we can change it with the `names` argument)
    synonyms = unique(uppercasefirst.(df[:,names]))

    # Prepare a dataframe from every thread
    results = [DataFrame(name = String[], matched = Bool[], match = Union{Missing,String}[], taxid = Union{Missing,Int64}[]) for i in 1:Threads.nthreads()]

    # Prepare the progressbar
    n = length(synonyms)
    p = Progress(n)

    # GO BR
    Threads.@threads for i in 1:n
        nm = taxon(namelist, synonyms[i]; casesensitive=false)
        if !isnothing(nm)
            push!(results[Threads.threadid()], (lowercase(synonyms[i]), true, nm.name, nm.id))
        else
            nm = taxon(namelist, synonyms[i]; strict=false)
            push!(results[Threads.threadid()], (lowercase(synonyms[i]), false, nm.name, nm.id))
        end
        next!(p)
    end
    return vcat(results...)
end

# TODO IMPORTANT USE THE FILES YOU WANT HERE
pathogens = DataFrame(CSV.File("C:/Users/cjcar/Documents/Github/virion/Code/Code_Dev/TaxonomyTempIn.csv"; delim=';'))
reconciled_pathogens = taxonomizer(pathogens, :pathogens; names=:Name)
CSV.write("C:/Users/cjcar/Documents/Github/virion/Code/Code_Dev/TaxonomyTempOut.csv", leftjoin(lowercasefirst.(pathogens), reconciled_pathogens, on=:Name => :name))
