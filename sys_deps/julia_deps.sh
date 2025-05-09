julia -e 'using Pkg; Pkg.activate("."); Pkg.add("CSV"); Pkg.add("DataFrames")'
julia -e 'using Pkg; Pkg.activate("."); Pkg.add(PackageSpec(name="NCBITaxonomy", rev="main"))'