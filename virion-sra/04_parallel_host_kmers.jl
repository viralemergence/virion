# Locate the files
tax_analysis_path = joinpath("..", "sra_tax_analysis_tool", "tax_analysis")
tax_files = joinpath.(tax_analysis_path, readdir(tax_analysis_path))
id_of_file_to_run = parse(Int64, get(ENV, "SLURM_ARRAY_TASK_ID", "1"))
taxonomy_file = tax_files[id_of_file_to_run]

@info "tax read"

# The packages we need
using Parquet
using DelimitedFiles
using Query
using DataFrames
import CSV

# Get the taxonomic IDs of viruses
hosts = vec(DelimitedFiles.readdlm("hosts.ids", '\t', Int64))
viral_accessions = DataFrame(CSV.File("viral_accessions.csv"))
accessions = Symbol.(unique(viral_accessions.acc))

@info "Previous files read"

# Read the parquet file
parquet_file = Parquet.File(taxonomy_file)

@info "Parquet read"

# Generate the chunks for the processing
chunk_size = 500_000
start_at = 1
ranges = [start_at:(start_at+chunk_size-1)]
while last(last(ranges)) < parquet_file.meta.num_rows
    start_at = last(last(ranges))+1
    end_at = min(start_at + chunk_size - 1, parquet_file.meta.num_rows)
    push!(ranges, start_at:end_at)
end

@info "Ranges done"

# Create the array of cursors
cursors = [RecordCursor(parquet_file; rows=r, colnames=[["acc"], ["tax_id"], ["self_count"], ["total_count"]]) for r in ranges]

@info "Ready to go"

Base.Threads.@threads for cursor = cursors
    out_name = "hosts-$(id_of_file_to_run)-$(string(hash(cursor))).csv"
    @info "$(Threads.threadid()) is working on $(out_name)"
    records = collect(cursor)
    filter!(r -> !ismissing(r.acc), records)
    filter!(r -> !ismissing(r.self_count), records)
    filter!(r -> !ismissing(r.total_count), records)
    filter!(r -> !ismissing(r.tax_id), records)
    filter!(r -> r.tax_id in hosts, records)
    filter!(r -> Symbol(r.acc) in accessions, records) # Symbol lookup is >>>> faster than string lookup
    df = DataFrame(records)
    select!(df, :acc, :tax_id, :self_count, :total_count)
    CSV.write(joinpath("host_acc", out_name), df)
end
