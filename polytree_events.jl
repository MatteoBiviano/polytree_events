using CSV
using DataFrames
using JSON
function birth(nodes, edges)
    n_birth = 0
    birth_nodes = []
    for node in nodes
        is_birth = true
        for edge in edges
            if node.Id == edge.Target
                is_birth = false
                break
            end
        end
        if is_birth
            n_birth += 1
            push!(birth_nodes, (node.Id))
        end
    end
    return n_birth, birth_nodes
end

function real_birth(birth_nodes)
    #For exclude birth at time 0
    real_b = 0
    for node in birth_nodes
        if split(node, "_")[1] != "0"
            real_b+=1
        end
    end
    return real_b
end

function death(nodes, edges)
    n_death = 0
    death_nodes = []
    last_comm = 0
    for node in nodes
        is_death = true
        for edge in edges
            if node.Id == edge.Source
                is_death = false
                break
            end
        end
        if is_death
            n_death += 1
            comm = parse(Int64, split(node.Id, "_")[1])
            if comm > last_comm
                last_comm = comm
            end
            push!(death_nodes, node.Id)
        end
    end
    return n_death, death_nodes, last_comm
end

function real_death(death_nodes, last_community)
    #For exclude death at last time
    real_d = 0
    for node in death_nodes
        if parse(Int64, split(node, "_")[1]) != last_community
            real_d+=1
        end
    end
    return real_d
end

function merge(nodes, edges)
    n_merge = 0
    merge_nodes = Dict()
    for node in nodes
        tmp_from = []
        n_from = 0
        for edge in edges
            if node.Id == edge.Target
                push!(tmp_from, edge.Source)
                n_from+=1
            end
        end
        if n_from >1
            n_merge+=1
            merge_nodes[node.Id]=tmp_from
        end
    end
    return n_merge, merge_nodes
end

function split_(nodes, edges)
    n_split = 0
    split_nodes = Dict()
    for node in nodes
        tmp_to = []
        n_to = 0
        for edge in edges
            if node.Id == edge.Source
                push!(tmp_to, edge.Target)
                n_to+=1
            end
        end
        if n_to >1
            n_split+=1
            split_nodes[node.Id]=tmp_to
        end
    end
    return n_split, split_nodes
end

function continue_(nodes, edges)
    n_continue = 0
    continue_nodes = []
    for node in nodes
        n_to = 0
        tmp_to = ""
        for edge in edges
            if node.Id == edge.Source
                tmp_to=edge.Target
                n_to+=1
            end
        end
        if n_to ==1
            n_in = 0
            for edge in edges
                if edge.Target == tmp_to
                    n_in+=1
                end
            end
            if n_in ==1
                n_continue+=1
                push!(continue_nodes, (node.Id, tmp_to))
            end
        end
    end
    return n_continue, continue_nodes
end

function event_analysis(node_file, edge_file)
    node_csv = CSV.File(node_file, header=1, delim=",")
    edge_csv = CSV.File(edge_file, header=1, delim=",")
    d = Dict()

    n_birth, birth_nodes = birth(node_csv, edge_csv)
    println("Number of Birth event: $n_birth")
    d["Birth"] = Dict("NumberOf" => n_birth, "Nodes" => birth_nodes)

    r_birth = real_birth(birth_nodes)
    println("Number of Real Birth event (exclude first community): $r_birth")
    d["RealBirth"] = Dict("NumberOf" => r_birth)

    n_death, death_nodes, last_community = death(node_csv, edge_csv)
    println("Number of Death event: $n_death")
    d["Death"] = Dict("NumberOf" => n_death, "Nodes" => death_nodes)

    r_death = real_death(death_nodes, last_community)
    println("Number of Real Death event (exclude last community): $r_death")
    d["RealDeath"] = Dict("NumberOf" => n_death, "Nodes" => death_nodes)

    n_merge, merge_nodes = merge(node_csv, edge_csv)
    println("Number of Merge event: $n_merge")
    d["Merge"] = Dict("NumberOf" => n_merge, "Nodes" => merge_nodes)

    n_split, split_nodes = split_(node_csv, edge_csv)
    println("Number of Split event: $n_split")
    d["Merge"] = Dict("NumberOf" => n_split, "Nodes" => split_nodes)

    n_continue, continue_nodes = continue_(node_csv, edge_csv)
    println("Number of Continue event: $n_continue")
    d["Continue"] = Dict("NumberOf" => n_continue, "Nodes" => continue_nodes)

    open("polytree_event.json","w") do f
        JSON.print(f, d)
    end

end
