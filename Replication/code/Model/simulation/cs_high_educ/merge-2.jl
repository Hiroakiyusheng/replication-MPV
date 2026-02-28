using Mmap
using FileIO,JLD2


function save_solve_dg_output(delta_grid,con, ass, assi, val, choice, inc)
    dg_size = size(delta_grid,1)
    tag = string("solve_delta_grid_101_lam_e_67_lam_n_76.jld2")
    tag = replace(tag,"0." => "")
    file_name = string(tag,".jld2")
    println(file_name)
    save(file_name,Dict("delta_grid" => delta_grid,"con" => con, "ass" => ass, "assi" => assi, "val" => val, "choice" => choice, "inc" => inc))
end


state_count = 6
delta_size = 101
a_size = 11
u_size = 61
asset_size = 510
total_periods = 200

con_io = open("./mmap_hold/con-101hold.bin","w+")
ass_io = open("./mmap_hold/ass-101hold.bin","w+")
assi_io = open("./mmap_hold/assi-101hold.bin","w+")
val_io = open("./mmap_hold/val-101hold.bin","w+")
choice_io = open("./mmap_hold/choice-101hold.bin","w+")
inc_io = open("./mmap_hold/inc-101hold.bin","w+")

# con = Mmap.mmap(con_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
# ass = Mmap.mmap(ass_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
# assi = Mmap.mmap(assi_io,Array{Int64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
# val = Mmap.mmap(val_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
# choice = Mmap.mmap(choice_io,Array{Int64,6},(delta_size,160,asset_size,u_size,state_count,a_size))
# inc = Mmap.mmap(inc_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))

con = Mmap.mmap(con_io,Array{Float64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))
ass = Mmap.mmap(ass_io,Array{Float64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))
assi = Mmap.mmap(assi_io,Array{Int64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))
val = Mmap.mmap(val_io,Array{Float64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))
choice = Mmap.mmap(choice_io,Array{Int64,6},(160,asset_size,u_size,state_count,a_size,delta_size))
inc = Mmap.mmap(inc_io,Array{Float64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))

lambda_e = 0.72
lambda_n = 0.82

delta_grid = Array(0:.01:1)

for i = 1:delta_size

    delta = delta_grid[i]

    tag = string("solve_mats_delta_", delta, "_lam_e_", lambda_e, "_lam_n_", lambda_n)
    tag = replace(tag,"0." => "")
    file_name = string("./hold/",tag,".jld2")

    con_i, ass_i, assi_i, val_i, choice_i, inc_i = load(file_name, "con", "ass", "assi", "val", "choice", "inc")

    con[:,:,:,:,:,i] = con_i
    ass[:,:,:,:,:,i] = ass_i
    assi[:,:,:,:,:,i] = assi_i
    val[:,:,:,:,:,i] = val_i
    choice[:,:,:,:,:,i] = choice_i
    inc[:,:,:,:,:,i] = inc_i

end

Mmap.sync!(con)
Mmap.sync!(ass)
Mmap.sync!(assi)
Mmap.sync!(val)
Mmap.sync!(choice)
Mmap.sync!(inc)

# save_solve_dg_output(delta_grid,con, ass, assi, val, choice, inc)

close(con_io)
close(ass_io)
close(assi_io)
close(val_io)
close(choice_io)
close(inc_io)

# rm("con.bin")
# rm("ass.bin")
# rm("assi.bin")
# rm("val.bin")
# rm("choice.bin")
# rm("inc.bin")
