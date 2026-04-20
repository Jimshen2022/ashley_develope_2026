from graphviz import Digraph


def create_flowchart():
    dot = Digraph(format='png')

    dot.node('A', '供应商到达公司')
    dot.node('B', '门卫Check In (ATYARD2)')
    dot.node('C', '柜子停放在ATYARD2')
    dot.node('D', '需要卸货')
    dot.node('E', 'Undirected Yard Move (ATYARD2 → ATYARD)')
    dot.node('F', '柜子在ATYARD卸货')

    dot.edge('A', 'B')
    dot.edge('B', 'C')
    dot.edge('C', 'D', label='等待卸货')
    dot.edge('D', 'E')
    dot.edge('E', 'F')

    return dot


flowchart = create_flowchart()
flowchart.render('/mnt/data/yard_move_flowchart')
