using DataFrames
import CSV
using SparseArrays

vkmers = DataFrame(CSV.File("viral_accessions.csv"))
# Not the most beautiful part but hey
filter!(r -> !contains(r.virus_name, "phage"), vkmers)
filter!(r -> !contains(r.virus_name, "Marine virus"), vkmers)
GC.gc()

hkmers = DataFrame(CSV.File("host_accessions.csv"))
GC.gc()

sort!(vkmers, :acc)
sort!(hkmers, :acc)

valid_ssrs = intersect(unique(vkmers.acc), unique(hkmers.acc))

# Host sparse matrix
#red = select(hkmers, :acc, :host_name, :host_p)
red = hkmers
red_s = combine(groupby(red, :acc), :host_p => sum => :host_s)
red2 = leftjoin(red, red_s, on=:acc)
red2.score = red2.host_p ./ red2.host_s
#H = select(red2, :acc, :host_name, :score => :host_score)
H = red2
rename!(H, :score => :host_score)
CSV.write("H.dat", H)
GC.gc()

# Virus sparse matrix
#red = select(vkmers, :acc, :virus_name, :virus_p)
red = vkmers
df_ssrs = DataFrame(acc=valid_ssrs)
red = rightjoin(red, df_ssrs; on=:acc)
red_s = combine(groupby(red, :acc), :virus_p => sum => :virus_s)
red2 = leftjoin(red, red_s, on=:acc)
red2.score = red2.virus_p ./ red2.virus_s
#V = select(red2, :acc, :virus_name, :score => :virus_score)
V = red2
rename!(V, :score => :virus_score)
CSV.write("V.dat", V)
GC.gc()

vnames = sort(unique(V.virus_name))
hnames = sort(unique(H.host_name))
Base.Threads.@threads for h in hnames
    @info h
    th = H[H.host_name.==h,:]
    tj = innerjoin(th, V; on=:acc)
    if size(tj,1) > 0
        tj.score = tj.virus_score .* tj.host_score
        hfile = joinpath("edges", replace(h, " " => "_")*".csv")
        #=
        edges = combine(groupby(tj, :virus_name), :score => minimum => 
        :min, :score => maximum => :max, :score => length => :n)
        =#
        edges = tj
	sort!(edges, :virus_name)
        CSV.write(hfile, edges, writeheader=false)
    end
    GC.gc()
end
