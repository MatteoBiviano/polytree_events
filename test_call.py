from julia import Main
Main.include("polytree_events.jl")

Main.event_analysis("nodes.csv", "edges.csv")
