using NCBITaxonomy
using DataFrames
import CSV

include(joinpath(pwd(), "Code/Code_Dev/taxonomizer.jl"))

names = DataFrame(CSV.File(joinpath(pwd(), "Code/Code_Dev/TaxonomyTempIn.csv"); delim=';'))
reconciled_names = taxonomizer(names, :hosts; names=:Name)
CSV.write(joinpath(pwd(), "Code/Code_Dev/TaxonomyTempOut.csv"), leftjoin(names, reconciled_names, on=:Name => :Original))
