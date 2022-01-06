
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
results = [DataFrame(
    Original = String[],
    Rank = Symbol[],
    TaxId = Union{Missing,Int64}[],
    Species = Union{Missing,String}[],
    Genus = Union{Missing,String}[],
    Order = Union{Missing,String}[],
    Class = Union{Missing,String}[],
    Family = Union{Missing,String}[]) for i in 1:Threads.nthreads()]

# Prepare the progressbar
n = length(synonyms)

# GO BR
Threads.@threads for i in 1:n
    try
        nm = taxon(namelist, synonyms[i]; casesensitive=false)
        df_row = _prepare_name_tuple(synonyms[i], nm)
        push!(results[i], df_row)
    catch err
        if isa(err, NameHasNoDirectMatch)
            continue
        end
        if isa(err, NameHasMultipleMatches)
            for nm in alternativetaxa(namelist, synonyms[i])
                df_row = _prepare_name_tuple(synonyms[i], nm)
                push!(results[i], df_row)
            end
        end
        continue
    end
end
return vcat(results...)
end

function _prepare_name_tuple(n, taxa; levels=[:species, :genus, :order, :class, :family])
ln = lineage(taxa)
rk = rank.(ln)
match = Any[n, rank(taxa), taxa.id]
for level in levels
    rnk_i = findfirst(isequal(level), rk)
    if isnothing(rnk_i)
        push!(match, missing)
    else
        push!(match, ln[rnk_i].name)
    end
end
return tuple(match...)
end