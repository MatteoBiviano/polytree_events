# Dynamic Community Discovery - Check community events after Instant Optimal approach
### Getting Started

### Install Julia packages
```
add CSV
add DataFrames
add JSON
```
### Run
### Install Python packages
```
pip install Julia
```

### Run from python
```
python test_call.py
```
or include this in your code
```python
from julia import Main
Main.include("polytree_events.jl")
Main.event_analysis("nodes.csv", "edges.csv")
```
Examples of nodes and edges can be found in the nodes.csv and edges.csv files

### Clone the repo
Get a copy of this repo using git clone
```
git clone https://github.com/MatteoBiviano/polytree_events.git
```
