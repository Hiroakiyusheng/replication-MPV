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
u_size = 11
asset_size = 510
total_periods = 200

con_io = open("con-101hold.bin","w+")
ass_io = open("ass-101hold.bin","w+")
assi_io = open("assi-101hold.bin","w+")
val_io = open("val-101hold.bin","w+")
choice_io = open("choice-101hold.bin","w+")
inc_io = open("inc-101hold.bin","w+")

con = Mmap.mmap(con_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
ass = Mmap.mmap(ass_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
assi = Mmap.mmap(assi_io,Array{Int64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
val = Mmap.mmap(val_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
choice = Mmap.mmap(choice_io,Array{Int64,6},(delta_size,160,asset_size,u_size,state_count,a_size))
inc = Mmap.mmap(inc_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))

D1 = jldopen("solve_delta_0-50_grid_51_lam_e_67_lam_n_76.jld2","r",mmaparrays=true)
D2 = jldopen("solve_delta_51-100_grid_50_lam_e_67_lam_n_76.jld2","r",mmaparrays=true)


con[1:51,:,:,:,:,:] = D1["con"]
ass[1:51,:,:,:,:,:] = D1["ass"]
assi[1:51,:,:,:,:,:] = D1["assi"]
val[1:51,:,:,:,:,:] = D1["val"]
choice[1:51,:,:,:,:,:] = D1["choice"]
inc[1:51,:,:,:,:,:] = D1["inc"]

con[52:101,:,:,:,:,:] = D2["con"]
ass[52:101,:,:,:,:,:] = D2["ass"]
assi[52:101,:,:,:,:,:] = D2["assi"]
val[52:101,:,:,:,:,:] = D2["val"]
choice[52:101,:,:,:,:,:] = D2["choice"]
inc[52:101,:,:,:,:,:] = D2["inc"]

dg1 = D1["delta_grid"]
dg2 = D2["delta_grid"]

delta_grid = cat(dg1,dg2;dims=1)

Mmap.sync!(con)
Mmap.sync!(ass)
Mmap.sync!(assi)
Mmap.sync!(val)
Mmap.sync!(choice)
Mmap.sync!(inc)

save_solve_dg_output(delta_grid,con, ass, assi, val, choice, inc)

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
