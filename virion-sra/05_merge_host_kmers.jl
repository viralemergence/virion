using DataFrames
import CSV
using Query

csvs = joinpath.("host_acc/", readdir("host_acc/"))

df = DataFrame(CSV.File(csvs[1]))
for i in 2:length(csvs)
    @info "Processing file $(csvs[i])"
    ndf = DataFrame(CSV.File(csvs[i]))
    append!(df, ndf)
end

@info "counting reads"
function count_df(df)
    return @from i in df begin
        @group i by i.acc into g
        @select {acc=key(g),total=maximum(g.total_count),hits=length(g.total_count)}
        @collect DataFrame
    end
end

host_tax = DataFrame(CSV.File("taxonomy_hosts.csv"))

df = join(df, count_df(df); on=:acc)
df = join(df, host_tax; on=:tax_id)
df.p = df.total_count./df.total

#select!(df, [:acc, :tax_id, :p, :hits, :total_count])

for n in names(df)
    if n != "acc"
        rename!(df, n => Symbol("host_"*String(n)))
    end
end

CSV.write("host_accessions.csv", df)