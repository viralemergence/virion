using NCBITaxonomy
using DataFrames
import CSV
using ProgressMeter

## Part 2 - pathogens

name_file = "C:/Users/cjcar/Documents/Github/virion/Code_Dev/TaxonomyTempIn.csv"
names = DataFrame(CSV.File(name_file))
synonyms = unique(uppercasefirst.(names.Name))

nf = NCBITaxonomy._divisionfinder([:BCT, :INV, :VRL, :PLN])

results = [DataFrame(name = String[], matched = Bool[], match = Union{Missing,String}[], taxid = Union{Missing,Int64}[]) for i in 1:Threads.nthreads()]

n = length(synonyms)
p = Progress(n)
Threads.@threads for i in 1:n
    nm = nf(synonyms[i])
    if !isnothing(nm)
        push!(results[Threads.threadid()], (lowercase(synonyms[i]), true, lowercase(nm.name), nm.id))
    else
        push!(results[Threads.threadid()], (lowercase(synonyms[i]), false, missing, missing))
    end
    next!(p)
end

cleanup = vcat(results...)
clovirion_tax = leftjoin(lowercasefirst.(names), cleanup, on = :Name => :name)

CSV.write("C:/Users/cjcar/Documents/Github/virion/Code_Dev/TaxonomyTempOut.csv", clovirion_tax)
