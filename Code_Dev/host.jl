using NCBITaxonomy
using DataFrames
import CSV
using ProgressMeter

"""
    taxonomizer(df::DataFrame, type::Symbol=:hosts; names::Symbol=:Name)
Returns a dataframe of cleaned names for either hosts or pathogens, where the
original names are stored in the `names` column of the first argument (to be
given as a `Symbol`).
Example:
~~~ julia
df = DataFrame(CSV.File("MyTaxonomy.csv))
clean = taxonomizer(df, :pathogens; names=Symbol("species name"))
~~~
If the name is not found using a strict match, this function will then attempt a
fuzzy match. By default, the function uses threading, the number of which can be
changed in Julia configuration file, on the command line when calling julia
(`julia -t 8`), or in the Julia VSCode extension.
"""
function taxonomizer(df::DataFrame, type::Symbol=:hosts; names::Symbol=:Name)

    # Check that the name type is either hosts or pathogens
    @assert type ∈ [:hosts, :pathogens]

    # And build the appropriate nametype
    namelist = isequal(:hosts)(type) ? vertebratefilter() : virusfilter()

    # Get the names from the correct column (usually `Name` but we can change it with the `names` argument)
    synonyms = unique(uppercasefirst.(df[:,names]))

    # Prepare a dataframe from every thread
    results = [DataFrame(name = String[], matched = Bool[], match = Union{Missing,String}[], taxid = Union{Missing,Int64}[]) for i in 1:Threads.nthreads()]

    # Prepare the progressbar
    n = length(synonyms)
    p = Progress(n)

    # GO BR
    Threads.@threads for i in 1:n
        nm = taxon(namelist, synonyms[i])
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

hosts = DataFrame(CSV.File("C:/Users/cjcar/Documents/Github/virion/Code_Dev/TaxonomyTempIn.csv"))
reconciled_hosts = taxonomizer(hosts, :hosts; names=:Name)
CSV.write("C:/Users/cjcar/Documents/Github/virion/Code_Dev/TaxonomyTempOut.csv", leftjoin(lowercasefirst.(hosts), reconciled_hosts, on=:Name => :name))
