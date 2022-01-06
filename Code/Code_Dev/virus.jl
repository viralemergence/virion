using NCBITaxonomy
using DataFrames
import CSV

include(joinpath(@__DIR__, "/Code/Code_Dev/taxonomizer.jl"))

names = DataFrame(CSV.File(joinpath(@__DIR__, "/Code/Code_Dev/TaxonomyTempIn.csv"); delim=';'))
reconciled_names = taxonomizer(names, :pathogens; names=:Name)
CSV.write(joinpath(@__DIR__, "/Code/Code_Dev/TaxonomyTempOut.csv"), leftjoin(names, reconciled_names, on=:Name => :Original))