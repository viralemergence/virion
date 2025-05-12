
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

    # Remove blast names
    filter!(row -> row.class != NCBITaxonomy.class_blast_name, namelist)

    # Get the names from the correct column (usually `Name` but we can change it with the `names` argument)
    synonyms = unique(uppercasefirst.(df[:, names]))

    # Prepare a dataframe from every thread
    results = DataFrame(;
        Original=String[],
        Rank=Symbol[],
        TaxId=Union{Missing,Int64}[],
        Species=Union{Missing,String}[],
        Genus=Union{Missing,String}[],
        Order=Union{Missing,String}[],
        Class=Union{Missing,String}[],
        Family=Union{Missing,String}[],
    )

    # Prepare the progressbar
    n = length(synonyms)

    # GO BR
    for i in 1:n
        try
            nm = taxon(namelist, synonyms[i]; casesensitive=false, preferscientific=true)
            df_row = _prepare_name_tuple(synonyms[i], nm)
            push!(results, df_row)
        catch err
            if isa(err, NameHasNoDirectMatch)
                continue
            end
            if isa(err, NameHasMultipleMatches)
                for nm in err.taxa
                    df_row = _prepare_name_tuple(synonyms[i], nm)
                    push!(results, df_row)
                end
            end
            continue
        end
    end

    out = transform(results, :Original => ByRow(x -> lowercasefirst(x)) => :Original)
    return out
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
