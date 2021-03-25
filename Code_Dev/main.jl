using NCBITaxonomy
using DataFrames
import CSV
using ProgressMeter

## Part 1 - hosts

name_file = "CLOVERT_HostswSyns_forNCBITaxonomy.csv"
names = DataFrame(CSV.File(name_file))
synonyms = unique(uppercasefirst.(names.Name))

# The name finder functions have been removed to instead use a DF passed as a first argument to taxon
vert = verterbratefilter()

results = [DataFrame(name = String[], matched = Bool[], match = Union{Missing,String}[], taxid = Union{Missing,Int64}[]) for i in 1:Threads.nthreads()]

n = length(synonyms)
p = Progress(n)
Threads.@threads for i in 1:n
    # New syntax is taxon(df, name)
    nm = taxon(vert, synonyms[i])
    if !isnothing(nm)
        push!(results[Threads.threadid()], (lowercase(synonyms[i]), true, lowercase(nm.name), nm.id))
    else
        push!(results[Threads.threadid()], (lowercase(synonyms[i]), false, missing, missing))
    end
    next!(p)
end

cleanup = vcat(results...)
clovirion_tax = leftjoin(names, cleanup, on = :Name => :name)

CSV.write("CLOVERT_hostchek.csv", clovirion_tax)

## Part 2 - pathogens

name_file = "CLOVERT_Pathogens_forNCBITaxonomy.csv"
names = DataFrame(CSV.File(name_file))
synonyms = unique(uppercasefirst.(names.Name))

# We can build a namefilter from an array of division codes
# This should probably be an enumerated type but hey
pathogens = namefilter([:BCT, :INV, :VRL, :PLN])

results = [DataFrame(name = String[], matched = Bool[], match = Union{Missing,String}[], taxid = Union{Missing,Int64}[]) for i in 1:Threads.nthreads()]

n = length(synonyms)
p = Progress(n)
Threads.@threads for i in 1:n
    nm = taxon(pathogens, synonyms[i])
    if !isnothing(nm)
        push!(results[Threads.threadid()], (lowercase(synonyms[i]), true, lowercase(nm.name), nm.id))
    else
        push!(results[Threads.threadid()], (lowercase(synonyms[i]), false, missing, missing))
    end
    next!(p)
end

cleanup = vcat(results...)
clovirion_tax = leftjoin(names, cleanup, on = :Name => :name)

CSV.write("CLOVERT_pathchek.csv", clovirion_tax)
